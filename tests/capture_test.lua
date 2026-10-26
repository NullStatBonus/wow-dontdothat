local H = require("harness")

local function setup(debugOn)
  local ns = {}
  H.load("DontDoThat/Debug/Log.lua", ns)
  H.load("DontDoThat/Debug/Probe.lua", ns)
  H.load("DontDoThat/Debug/Capture.lua", ns)
  ns.Log.Init({}, { printer = function() end })
  ns.Log.SetEnabled(debugOn)
  ns.Capture.Reset()
  return ns, {}
end

local function fakeEnv()
  local env = { hooks = {}, scripts = {} }
  local services = {
    { "Serpent Sting", "Rank 1", "used", 100, 4 },
    { "Serpent Sting", "Rank 2", "available", 200, 10 },
  }
  env.UnitName = function() return "Class Trainer" end
  env.GetNumTrainerServices = function() return #services end
  env.GetTrainerServiceInfo = function(i) return services[i][1], services[i][2], services[i][3] end
  env.GetTrainerServiceCost = function(i) return services[i][4] end
  env.GetTrainerServiceLevelReq = function(i) return services[i][5] end
  env.BuyTrainerService = function() end
  env.hooksecurefunc = function(name, fn) env.hooks[name] = fn end
  env.ClassTrainerTrainButton = {
    HookScript = function(_, script, fn) env.scripts[script] = fn end,
    GetObjectType = function() return "Button" end,
    IsProtected = function() return false, false end,
  }
  env.GetNumTalentTabs = function() return 1 end
  env.GetTalentTabInfo = function() return "Beast Mastery", "icon", 5 end
  return env
end

test("nothing is captured while debug is off", function()
  local ns, saved = setup(false)
  ns.Capture.OnEvent(fakeEnv(), saved, "TRAINER_SHOW")
  eq(saved.captures, nil)
end)

test("TRAINER_SHOW stores a snapshot and notes the rank skip", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "TRAINER_SHOW")
  local tr = saved.captures.trainers["Class Trainer"]
  eq(#tr.services, 2)
  eq(tr.services[2].cost, 200)
  eq(saved.captures.events.TRAINER_SHOW, 1)
  truthy(saved.rankSkips == nil or next(saved.rankSkips) == nil, "rank 2 has rank 1 learned, so no skip")
end)

test("an empty list at TRAINER_SHOW is replaced once TRAINER_UPDATE has data", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  local real = env.GetNumTrainerServices
  env.GetNumTrainerServices = function() return 0 end
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  eq(#saved.captures.trainers["Class Trainer"].services, 0)
  env.GetNumTrainerServices = real
  ns.Capture.OnEvent(env, saved, "TRAINER_UPDATE")
  eq(#saved.captures.trainers["Class Trainer"].services, 2)
end)

test("type filters are recorded, with n/a when the function is absent", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  eq(saved.captures.trainers["Class Trainer"].filters.used, "n/a")
  env.GetTrainerServiceTypeFilter = function(kind) return kind == "used" and 0 or 1 end
  ns.Capture.OnEvent(env, saved, "TRAINER_UPDATE")
  eq(saved.captures.trainers["Class Trainer"].filters, { available = "1", unavailable = "1", used = "0" })
end)

test("hook installation is logged", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "TRAINER_SHOW")
  local text = {}
  for _, e in ipairs(ns.Log.Entries()) do text[#text + 1] = tostring(e.msg or e.text or e[2] or e) end
  truthy(table.concat(text, "\n"):find("hooks: BuyTrainerService installed", 1, true))
end)

test("rank skipping is recorded when a lower rank is unlearned", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.GetTrainerServiceInfo = function(i) return "Wing Clip", "Rank " .. (i == 1 and 1 or 2), "available" end
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  truthy(saved.rankSkips["Wing Clip#2"], "skip observed")
end)

test("respec quote event is recorded", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "CONFIRM_TALENT_WIPE", 10000, 0)
  eq(saved.respecQuotes[1].copper, 10000)
  eq(saved.respecQuotes[1].count, 0)
end)

test("talent snapshot is captured", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "PLAYER_TALENT_UPDATE")
  eq(saved.captures.talents.trees[1].points, 5)
end)

test("hooks install once and observe purchases without altering anything", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  truthy(env.hooks.BuyTrainerService, "BuyTrainerService hooked")
  falsy(env.hooks.LearnTalent, "absent functions are not hooked")
  env.hooks.BuyTrainerService(2)
  env.scripts.PreClick()
  eq(saved.captures.purchases[1].name, "Serpent Sting")
  eq(saved.captures.purchases[1].cost, 200)
  eq(saved.interceptions["trainer/talent"]["BuyTrainerService post-hook fired"].n, 1)
  eq(saved.interceptions["trainer"]["Train button PreClick hook fired"].n, 1)
end)

test("hooks stay silent once debug is turned off", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  ns.Log.SetEnabled(false)
  env.hooks.BuyTrainerService(1)
  eq(#saved.captures.purchases, 0)
end)

test("frame report shows missing and protected state", function()
  local ns = setup(true)
  local lines = ns.Capture.FrameReport(fakeEnv())
  local text = table.concat(lines, "\n")
  truthy(text:find("ClassTrainerFrame: missing", 1, true))
  truthy(text:find("ClassTrainerTrainButton: Button, protected=false explicit=false", 1, true))
end)

test("a failing handler is contained", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.GetNumTrainerServices = function() error("boom") end
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  eq(saved.captures.events.TRAINER_SHOW, 1)
end)

test("report lines summarize what was captured", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "TRAINER_SHOW")
  local text = table.concat(ns.Capture.Lines(saved), "\n")
  truthy(text:find('trainer "Class Trainer"', 1, true))
  truthy(text:find("Serpent Sting rank=2", 1, true))
end)

test("empty report tells the player what to do", function()
  local ns = setup(true)
  truthy(table.concat(ns.Capture.Lines({}), "\n"):find("debug on", 1, true))
end)

test("the craft (Beast Training) window is captured with training point costs", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.GetNumCrafts = function() return 2 end
  env.GetCraftDisplaySkillLine = function() return "Beast Training" end
  env.GetPetTrainingPoints = function() return 30, 12 end
  env.GetCraftInfo = function(i)
    if i == 1 then return "Bite", "Rank 2", "optimal", 0, false, 5, 8 end
    return "Natural Armor", "Rank 1", "easy", 0, false, 1, 10
  end
  ns.Capture.OnEvent(env, saved, "CRAFT_SHOW")
  local b = saved.captures.beast
  eq(b.skillLine, "Beast Training")
  eq(b.trainingPoints, { total = 30, spent = 12 })
  eq(#b.rows, 2)
  eq(b.rows[1].points, 5)
  local text = table.concat(ns.Capture.Lines(saved), "\n")
  truthy(text:find('craft window "Beast Training"', 1, true))
  truthy(text:find("Natural Armor Rank 1 type=easy points=1 level=10", 1, true))
end)

test("a missing craft API is contained", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "CRAFT_SHOW")
  eq(saved.captures.beast, nil)
  eq(saved.captures.events.CRAFT_SHOW, 1)
end)

test("a client that rejects an event name does not break startup", function()
  local ns, saved = setup(true)
  local registered = {}
  local addon = {
    RegisterEvent = function(_, event)
      if event == "CRAFT_SHOW" then error("Attempt to register unknown event") end
      registered[event] = true
    end,
  }
  ns.Capture.Enable(addon, fakeEnv(), saved)
  truthy(registered.TRAINER_SHOW, "other events still register")
  falsy(registered.CRAFT_SHOW)
  truthy(table.concat(saved.captures.eventFailures, ","):find("CRAFT_SHOW", 1, true))
  truthy(table.concat(ns.Capture.Lines(saved), "\n"):find("events this client rejected", 1, true))
end)

test("pet reset quotes are recorded from the confirm event", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "CONFIRM_PET_UNLEARN", 1000)
  eq(saved.captures.petResetQuotes[1].cost, 1000)
  truthy(table.concat(ns.Capture.Lines(saved), "\n"):find("pet reset quote: cost=1000", 1, true))
end)

test("confirmation dialogs are recorded while debug is on, hooks installed at startup", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.StaticPopup_Show = function() end
  ns.Capture.Enable({ RegisterEvent = function() end }, env, saved)
  truthy(env.hooks.StaticPopup_Show, "popup hook installed at enable")
  env.hooks.StaticPopup_Show("CONFIRM_PET_UNLEARN", 1000, nil)
  env.hooks.StaticPopup_Show("CONFIRM_TALENT_WIPE", 50000)
  eq(saved.captures.popups[1].which, "CONFIRM_PET_UNLEARN")
  eq(saved.captures.popups[1].text1, 1000)
  eq(#saved.captures.popups, 2)
  ns.Log.SetEnabled(false)
  env.hooks.StaticPopup_Show("QUIET", 1)
  eq(#saved.captures.popups, 2, "nothing recorded once debug is off")
end)

test("popup history is bounded", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.StaticPopup_Show = function() end
  ns.Capture.Enable({ RegisterEvent = function() end }, env, saved)
  for i = 1, 100 do env.hooks.StaticPopup_Show("P" .. i, i) end
  eq(#saved.captures.popups, 60)
  eq(saved.captures.popups[60].which, "P100")
end)

test("opening the talent UI captures talents and hooks the window", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.GetUnspentTalentPoints = function() return 1 end
  env.PlayerTalentFrame = {
    HookScript = function(_, script, fn) env.scripts["Talent" .. script] = fn end,
    GetObjectType = function() return "Frame" end,
    IsProtected = function() return false, false end,
  }
  ns.Capture.OnEvent(env, saved, "ADDON_LOADED", "Blizzard_TalentUI")
  eq(saved.captures.talents.unspent, 1)
  eq(saved.captures.talents.trees[1].points, 5)
  truthy(env.scripts.TalentOnShow, "OnShow hooked")
  saved.captures.talents = nil
  env.scripts.TalentOnShow()
  truthy(saved.captures.talents, "showing the window takes a fresh snapshot")
  local text = table.concat(ns.Capture.Lines(saved), "\n")
  truthy(text:find("unspent=1", 1, true))
end)

test("other addons loading is ignored without noise", function()
  local ns, saved = setup(true)
  ns.Capture.OnEvent(fakeEnv(), saved, "ADDON_LOADED", "SomethingElse")
  eq(saved.captures.events.ADDON_LOADED, nil)
  eq(saved.captures.talents, nil)
  eq(ns.Log.Count(), 0)
end)

test("talent buttons are included in the frame report", function()
  local ns = setup(true)
  local env = fakeEnv()
  env.PlayerTalentFrameTalent1 = { GetObjectType = function() return "Button" end, IsProtected = function() return true, true end }
  local text = table.concat(ns.Capture.FrameReport(env), "\n")
  truthy(text:find("PlayerTalentFrameTalent1: Button, protected=true explicit=true", 1, true))
end)

test("the trainer window row layout is recorded after each refresh", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  local function label(text) return { GetText = function() return text end } end
  for i, spec in ipairs({ { "Aspect of the Hawk", "Rank 1", 2 }, { "Serpent Sting", "Rank 2", 31 } }) do
    env["ClassTrainerSkill" .. i] = { IsShown = function() return true end, GetID = function() return spec[3] end }
    env["ClassTrainerSkill" .. i .. "Text"] = label(spec[1])
    env["ClassTrainerSkill" .. i .. "SubText"] = label(spec[2])
  end
  env.ClassTrainerFrame_Update = function() end
  env.FauxScrollFrame_GetOffset = function() return 4 end
  env.ClassTrainerListScrollFrame = {}
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  truthy(env.hooks.ClassTrainerFrame_Update, "update function hooked")
  env.hooks.ClassTrainerFrame_Update()
  local tr = saved.captures.trainerRows
  eq(tr.offset, 4)
  eq(#tr.rows, 2)
  eq(tr.rows[2], { n = 2, shown = true, id = 31, text = "Serpent Sting", sub = "Rank 2" })
  truthy(table.concat(ns.Capture.Lines(saved), "\n"):find("ClassTrainerSkill2 shown=true id=31 text=Serpent Sting", 1, true))
end)

test("row capture tolerates a missing window", function()
  local ns, saved = setup(true)
  ns.Capture.TrainerRows(fakeEnv(), saved)
  eq(#saved.captures.trainerRows.rows, 0)
end)

test("hooks missed on the first open are installed at the next trainer update", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  env.ClassTrainerTrainButton = nil
  env.ClassTrainerFrame_Update = nil
  ns.Capture.OnEvent(env, saved, "TRAINER_SHOW")
  falsy(env.scripts.PreClick, "button does not exist yet")
  env.ClassTrainerTrainButton = {
    HookScript = function(_, script, fn) env.scripts[script] = fn end,
    GetObjectType = function() return "Button" end, IsProtected = function() return false, false end,
  }
  env.ClassTrainerFrame_Update = function() end
  ns.Capture.OnEvent(env, saved, "TRAINER_UPDATE")
  truthy(env.scripts.PreClick, "installed on the update")
  truthy(env.hooks.ClassTrainerFrame_Update)
end)

test("the frame report lists filter and dropdown child fields", function()
  local ns = setup(true)
  local env = fakeEnv()
  env.ClassTrainerFrame = setmetatable({ FilterDropdown = {}, Other = {}, ScrollBox = {}, count = 3 }, {})
  env.ClassTrainerFrame.GetObjectType = function() return "Frame" end
  env.ClassTrainerFrame.IsProtected = function() return false, false end
  local text = table.concat(ns.Capture.FrameReport(env), "\n")
  truthy(text:find("FilterDropdown:table", 1, true))
  truthy(text:find("ScrollBox:table", 1, true))
  falsy(text:find("Other:table", 1, true), "unrelated fields are left out")
end)

test("the filter dropdown's fields and open menu tags are recorded", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  local clicked
  env.ClassTrainerFrame = { FilterDropdown = { menuTag = "x", SetupMenu = function() end,
    HookScript = function(_, script, fn) if script == "OnClick" then clicked = fn end end } }
  env.Menu = { GetOpenMenuTags = function() return { "MENU_CLASS_TRAINER_FILTER" } end }
  ns.Capture.OnEvent(env, saved, "TRAINER_UPDATE")
  truthy(clicked, "OnClick hooked")
  eq(saved.captures.filterDropdown.fields, { "HookScript:function", "SetupMenu:function", "menuTag:string" })
  clicked()
  eq(saved.captures.filterDropdown.tags, { "MENU_CLASS_TRAINER_FILTER" })
  local text = table.concat(ns.Capture.Lines(saved), "\n")
  truthy(text:find("filter dropdown fields: HookScript:function SetupMenu:function menuTag:string", 1, true))
  truthy(text:find("open menu tags after clicking the filter: MENU_CLASS_TRAINER_FILTER", 1, true))
end)

test("a missing Menu API is recorded without error", function()
  local ns, saved = setup(true)
  local env = fakeEnv()
  local clicked
  env.ClassTrainerFrame = { FilterDropdown = { HookScript = function(_, _, fn) clicked = fn end } }
  ns.Capture.OnEvent(env, saved, "TRAINER_UPDATE")
  clicked()
  eq(saved.captures.filterDropdown.tags, {})
end)

package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = {}
for _, f in ipairs({ "Rules/Schema.lua", "Rules/Engine.lua", "Rules/Data/Hunter.lua", "Model/SpecInference.lua",
  "Model/Milestones.lua", "Model/PlayerProfile.lua", "Intercepts/Adapter.lua", "Intercepts/Context.lua",
  "Intercepts/Trainer.lua" }) do
  H.load("DontDoThat/" .. f, ns)
end

-- Rows replay the shapes seen in a real Hunter trainer export (Classic Era 1.15.9).
local ROWS = {
  { "Beast Mastery", nil, "header" },
  { "Aspect of the Hawk", "Rank 1", "available", 400, 10 },
  { "Mend Pet", "Rank 1", "unavailable", 600, 12 },
  { "Marksmanship", nil, "header" },
  { "Serpent Sting", "Rank 2", "available", 400, 10 },
  { "Distracting Shot", "Rank 1", "unavailable", 600, 12 },
  { "Distracting Shot", "Rank 2", "unavailable", 2200, 20 },
  { "Survival", nil, "header" },
  { "Track Humanoids", nil, "available", 400, 10 },
  { "Wing Clip", "Rank 1", "used", 600, 12 },
}

local function fakeEnv(opts)
  opts = opts or {}
  local env = {}
  env.UnitClass = function() return "Hunter", opts.class or "HUNTER", 3 end
  env.UnitLevel = function() return opts.level or 10 end
  env.GetNumTrainerServices = function() return #ROWS end
  env.GetTrainerServiceInfo = function(i) local r = ROWS[i]; return r[1], r[2], r[3], 1 end
  env.GetTrainerServiceCost = function(i) return ROWS[i][4] end
  env.GetTrainerServiceLevelReq = function(i) return ROWS[i][5] end
  env.GetNumTalentTabs = function() return 3 end
  env.GetTalentTabInfo = function(i)
    local pts = opts.points or { 0, 0, 0 }
    return 360 + i, ({ "Beast Mastery", "Marksmanship", "Survival" })[i], "", 132164, pts[i], "Background"
  end
  return env
end

test("adapter reads trainer rows, headers, ranks and next rank levels", function()
  local t = ns.Adapter.ReadTrainer(fakeEnv())
  truthy(t.ok)
  eq(#t.rows, 10)
  truthy(t.byIndex[1].header)
  eq(t.byIndex[2].rank, 1); eq(t.byIndex[2].level, 10); eq(t.byIndex[2].cost, 400)
  truthy(t.byIndex[2].available); falsy(t.byIndex[3].available)
  truthy(t.byIndex[10].learned)
  eq(t.byIndex[9].rank, nil)
end)

test("adapter degrades without the trainer API", function()
  local t = ns.Adapter.ReadTrainer({})
  falsy(t.ok)
  eq(#t.rows, 0)
end)

test("adapter reads the player and the id-first talent shape", function()
  local env = fakeEnv({ level = 25, points = { 11, 2, 0 } })
  eq(ns.Adapter.ReadPlayer(env), { class = "HUNTER", level = 25 })
  local tabs = ns.Adapter.ReadTalentTabs(env)
  eq(tabs[1], { name = "Beast Mastery", points = 11 })
  eq(tabs[3].points, 0)
  eq(ns.Adapter.ReadTalentTabs({}), {})
end)

test("context builds a profile using the talent tab to spec mapping", function()
  local p = ns.Context.Profile(fakeEnv({ level = 25, points = { 16, 2, 0 } }))
  eq(p.class, "HUNTER"); eq(p.level, 25)
  eq(p.treePoints, { BM = 16, MM = 2, SV = 0 })
  eq(p.plausibleSpecs, { "BM" })
  eq(p.milestone.state, "active")
end)

test("context is nil for an unsupported class", function()
  eq(ns.Context.Profile(fakeEnv({ class = "MAGE" })), nil)
  eq(ns.Context.Profile({}), nil)
end)

test("compute flags the rows the rules defer and leaves the rest", function()
  local c = ns.TrainerOverlay.Compute(fakeEnv())
  eq(c.verdicts[2].tier, "keep")          -- Aspect of the Hawk: no rule
  eq(c.verdicts[5].tier, "keep")          -- Serpent Sting: override
  eq(c.verdicts[6].tier, "defer")         -- Distracting Shot: not needed until 60
  eq(c.verdicts[7].tier, "defer")
  eq(c.verdicts[9].tier, "deferLow")      -- all tracking is low value
  eq(c.verdicts[1], nil, "headers are not evaluated")
  eq(c.verdicts[10], nil, "learned rows are not evaluated")
  eq(c.verdicts[6].cost, 600)
  eq(c.verdicts[6].name, "Distracting Shot")
end)

test("compute is nil when the class is unsupported or the trainer unreadable", function()
  eq(ns.TrainerOverlay.Compute(fakeEnv({ class = "MAGE" })), nil)
  local env = fakeEnv(); env.GetNumTrainerServices = nil
  eq(ns.TrainerOverlay.Compute(env), nil)
end)

local function buttons(env, ids)
  local calls = {}
  for i, id in ipairs(ids) do
    env["ClassTrainerSkill" .. i] = { GetID = function() return id end, n = i }
  end
  return { set = function(button, verdict) calls[button.n] = verdict and verdict.tier or "none" end }, calls
end

test("refresh applies verdicts to the buttons by service index, including after scrolling", function()
  local env = fakeEnv()
  local widgets, calls = buttons(env, { 5, 6, 9, 1 })
  ns.TrainerOverlay.Refresh(env, widgets)
  eq(calls, { "keep", "defer", "deferLow", "none" })
  -- scrolled so different services sit in the same buttons
  env.ClassTrainerSkill3, env.ClassTrainerSkill4 = nil, nil
  widgets, calls = buttons(env, { 7, 2 })
  ns.TrainerOverlay.Refresh(env, widgets)
  eq(calls, { "defer", "keep" })
end)

test("refresh clears every button when warnings are turned off", function()
  local env = fakeEnv()
  local widgets, calls = buttons(env, { 6, 9 })
  ns.db = { profile = { enabled = true, warnings = false } }
  ns.TrainerOverlay.Refresh(env, widgets)
  ns.db = nil
  eq(calls, { "none", "none" })
end)

test("refresh survives a button that errors and an evaluation that fails", function()
  local env = fakeEnv()
  local widgets = buttons(env, { 6 })
  env.ClassTrainerSkill1.GetID = function() error("boom") end
  local ok = ns.TrainerOverlay.SafeRefresh(env, widgets)
  truthy(ok, "contained")
  local saved = ns.Rules.Evaluate
  ns.Rules.Evaluate = function() error("bad rule") end
  truthy(ns.TrainerOverlay.SafeRefresh(env, widgets))
  ns.Rules.Evaluate = saved
end)

test("enable hooks the update function once and refreshes on trainer events", function()
  ns.TrainerOverlay.Reset()
  local env = fakeEnv()
  local widgets, calls = buttons(env, { 6 })
  ns.TrainerOverlay.widgets = widgets
  local registered, hooks = {}, 0
  env.ClassTrainerFrame_Update = function() end
  env.hooksecurefunc = function() hooks = hooks + 1 end
  local target = { RegisterEvent = function(_, event, fn) registered[event] = fn end }
  ns.TrainerOverlay.Enable(target, env)
  truthy(registered.TRAINER_SHOW and registered.TRAINER_UPDATE)
  registered.TRAINER_UPDATE()
  registered.TRAINER_UPDATE()
  eq(hooks, 1, "hooked once")
  eq(calls[1], "defer")
end)

test("adapter lists the talents with points in them, and nil when the client cannot say", function()
  local env = {
    GetNumTalentTabs = function() return 2 end,
    GetNumTalents = function(tab) return 2 end,
    GetTalentInfo = function(tab, i)
      local names = { { "Improved Tracking", "Aimed Shot" }, { "Wyvern Sting", "Savage Strikes" } }
      local ranks = { { 0, 1 }, { 0, 2 } }
      return names[tab][i], "icon", 1, 1, ranks[tab][i], 5
    end,
  }
  eq(ns.Adapter.ReadActiveTalents(env), { ["Aimed Shot"] = true, ["Savage Strikes"] = true })
  eq(ns.Adapter.ReadActiveTalents({}), nil)
end)

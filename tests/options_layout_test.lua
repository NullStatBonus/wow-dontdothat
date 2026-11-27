package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

-- Settings landmarks, the game's Settings window registration and the Appearance tabs.

local function fresh(profile)
  local ns = { version = "0.1.0" }
  for _, f in ipairs({ "UI/Helpers.lua", "Data/Sounds.lua", "Data/SpellData.lua", "Data/RuleSpells.lua", "Data/SkipRevisions.lua", "Data/TalentData.lua", "Model/SpellData.lua", "Rules/Schema.lua", "Rules/Engine.lua",
    "Rules/Data/Hunter.lua", "Rules/Data/Warrior.lua", "Rules/Data/Mage.lua", "Data/TrainerPrices.lua",
    "Model/Ledger.lua", "Model/Savings.lua", "Model/Milestones.lua", "Model/Settings.lua", "Model/SkipRevision.lua", "Model/ItemCategory.lua", "Options/Options.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  ns.db = { profile = profile or {} }
  return ns
end

-- Stub Ace libraries that record what is registered, added, opened, selected and notified.
local function stubAce()
  local rec = { tables = {}, registers = {}, added = {}, notified = {}, selected = nil, opened = nil }
  local config = { RegisterOptionsTable = function(_, name, t) rec.tables[name] = t; rec.registers[#rec.registers + 1] = name end }
  local dialog = {
    Status = {},
    AddToBlizOptions = function(_, name, title, parent)
      for _, a in ipairs(rec.added) do if a.name == name then error("already added") end end
      rec.added[#rec.added + 1] = { name = name, title = title, parent = parent }
    end,
    SetDefaultSize = function(_, name, w, h) rec.size = { name, w, h } end,
    Open = function(_, name) rec.opened = name end,
    SelectGroup = function(_, name, ...) rec.selected = { name, ... } end,
  }
  local registry = { NotifyChange = function(_, name) rec.notified[#rec.notified + 1] = name end }
  local saved = _G.LibStub
  _G.LibStub = function(lib) return ({ ["AceConfig-3.0"] = config, ["AceConfigDialog-3.0"] = dialog, ["AceConfigRegistry-3.0"] = registry })[lib] end
  return rec, dialog, function() _G.LibStub = saved end
end

local function sortedArgs(group)
  local list = {}
  -- The test-settings banner (an inline group at order 0, shown only while the mode is on) is not page content.
  for key, w in pairs(group.args or {}) do if key ~= "testBanner" then list[#list + 1] = { key = key, w = w } end end
  table.sort(list, function(a, b) return a.w.order < b.w.order end)
  return list
end

-- Any class group (the large tree) anywhere under a group.
local function hasClassTree(group)
  for key, child in pairs(group.args or {}) do
    if key == "HUNTER" or key == "WARRIOR" or key == "MAGE" then return true end
    if child.type == "group" and hasClassTree(child) then return true end
  end
  return false
end

test("the seven landmarks are in order, and Appearance has Warnings, Explanations and Sound tabs", function()
  local ns = fresh({})
  local root = ns.Options.Root()
  local order = {}
  for _, entry in ipairs(sortedArgs(root)) do if entry.w.type == "group" then order[#order + 1] = entry.key end end
  eq(order, { "home", "watch", "progress", "appearance", "advanced", "about", "profiles" })
  local appearance = root.args.appearance
  eq(appearance.childGroups, "tab")
  local tabs = {}
  for _, entry in ipairs(sortedArgs(appearance)) do if entry.w.type == "group" then tabs[#tabs + 1] = entry.key end end
  eq(tabs, { "warnings", "explanations", "sound" })
  local advanced = {}
  for _, entry in ipairs(sortedArgs(root.args.advanced)) do if entry.w.type == "group" then advanced[#advanced + 1] = entry.key end end
  eq(advanced, { "tuning", "classes", "debug" })
  truthy(hasClassTree(root.args.advanced), "the /ddt window keeps the class tree")
  truthy(root.args.advanced.args.scope.name:find("shared by your whole account", 1, true), "Advanced explains where settings are kept")
end)

test("every page and tab states its purpose first, with nonnegative orders", function()
  local ns = fresh({})
  local function check(group, path)
    local list = sortedArgs(group)
    for _, entry in ipairs(list) do truthy(entry.w.order >= 0, path .. "." .. entry.key .. " has a negative order") end
    if group.args.intro then
      local first
      for _, entry in ipairs(list) do if entry.key ~= "title" and entry.key ~= "testBanner" then first = entry.key; break end end
      eq(first, "intro", path .. " starts with its introduction")
    end
    for key, child in pairs(group.args) do
      if child.type == "group" and not path:find("classes", 1, true) then check(child, path .. "." .. key) end
    end
  end
  local root = ns.Options.Root()
  for _, key in ipairs({ "home", "watch", "progress", "appearance", "advanced" }) do
    truthy(root.args[key].args.intro, key .. " has an introduction")
    check(root.args[key], key)
  end
  for _, tab in ipairs({ "warnings", "explanations", "sound" }) do truthy(root.args.appearance.args[tab].args.intro, tab .. " tab has an introduction") end
  local about = sortedArgs(root.args.about)
  eq(about[1].key, "title"); eq(about[2].key, "version"); eq(about[3].key, "purpose")
  eq(about[1].w.fontSize, "large")
  truthy(about[2].w.name:find("|cff9d9d9d", 1, true), "the version is muted")
end)

test("about lists each command on its own row, log as the report command", function()
  local ns = fresh({})
  local about = ns.Options.About().args
  local rows = {}
  for key, w in pairs(about) do if type(w.name) == "string" and w.name:find("/ddt ", 1, true) then rows[#rows + 1] = w.name end end
  truthy(#rows >= 6, "one row per command")
  local joined = table.concat(rows, "\n")
  truthy(joined:find("/ddt log", 1, true))
  for _, row in ipairs(rows) do
    if row:find("/ddt export", 1, true) then falsy(row:find("\226\128\162", 1, true), "export is only a note, not a command row") end
  end
end)

test("without the game's Settings registration the /ddt window still opens at Home", function()
  local ns = fresh({})
  local rec, dialog, restore = stubAce()
  dialog.AddToBlizOptions = function() error("Settings API missing") end
  local ok, err = pcall(function()
    truthy(ns.Options.Register({}))
    truthy(rec.tables.DontDoThat, "the /ddt window's table is registered")
    truthy(ns.Options.Open())
    eq(rec.selected, { "DontDoThat", "home" })
  end)
  restore()
  truthy(ok, tostring(err))
end)

test("the root game-options entry is Home itself, with the same values as the /ddt window", function()
  local ns = fresh({})
  local rec, _, restore = stubAce()
  local ok, err = pcall(function()
    truthy(ns.Options.Register({}))
    eq(rec.added[1].name, "DontDoThat_parent"); eq(rec.added[1].title, "Don't Do That")
    local rootPage = rec.tables.DontDoThat_parent
    for _, key in ipairs({ "intro", "enabled", "nudge", "stopAfter", "banner", "resetAll" }) do truthy(rootPage.args[key], "root has " .. key) end
    eq(rootPage.args.title, nil, "no heading repeating the panel's own")
    falsy(tostring(rootPage.args.intro.name):find("Pick a page", 1, true), "not the old placeholder")
    -- Change the nudge on the root page; the /ddt window's Home shows the same choice.
    rootPage.args.nudge.set(nil, "everything")
    eq(rec.tables.DontDoThat.args.home.args.nudge.get(), "everything")
    eq(rec.size, { "DontDoThat", 600, 460 })
  end)
  restore()
  truthy(ok, tostring(err))
end)

test("the game-options Advanced has a classes launcher, not the class tree", function()
  local ns = fresh({})
  local rec, _, restore = stubAce()
  local closed
  _G.SettingsPanel = { Hide = function() closed = true end }
  local ok, err = pcall(function()
    ns.Options.Register({})
    local advanced = rec.tables.DontDoThat_advanced
    falsy(hasClassTree(advanced), "no class tree in the game's Settings window")
    local launch = advanced.args.classes.args.openClasses
    eq(launch.type, "execute"); eq(launch.name, "Open classes")
    launch.func()
    truthy(closed, "the game's Settings window was closed")
    eq(rec.opened, "DontDoThat")
    eq(rec.selected, { "DontDoThat", "advanced", "classes" })
  end)
  _G.SettingsPanel = nil
  restore()
  truthy(ok, tostring(err))
end)

test("registering again adds no categories, and rebuild refreshes the root and every page", function()
  local ns = fresh({})
  local rec, _, restore = stubAce()
  local ok, err = pcall(function()
    ns.Options.Register({})
    local before = #rec.added
    truthy(ns.Options.Register({}))
    eq(#rec.added, before, "no duplicate categories")
    local oldRoot = rec.tables.DontDoThat_parent
    rec.registers, rec.notified = {}, {}
    truthy(ns.Options.Rebuild())
    local names = {}
    for _, n in ipairs(rec.registers) do names[n] = true end
    for _, n in ipairs({ "DontDoThat", "DontDoThat_parent", "DontDoThat_watch", "DontDoThat_progress", "DontDoThat_appearance", "DontDoThat_advanced", "DontDoThat_profiles", "DontDoThat_about" }) do
      truthy(names[n], n .. " registered again")
    end
    truthy(rec.tables.DontDoThat_parent ~= oldRoot, "the root holds a fresh Home table")
    eq(#rec.notified, 8, "every open page redraws")
  end)
  restore()
  truthy(ok, tostring(err))
end)

test("opening selects Home explicitly, collapses the classes, and a page name opens its path", function()
  local ns = fresh({})
  local rec, dialog, restore = stubAce()
  local ok, err = pcall(function()
    ns.Options.Register({})
    dialog.Status.DontDoThat = { status = { groups = { groups = {
      ["advanced"] = true, ["advanced\001classes"] = true, ["advanced\001classes\001HUNTER"] = true,
      ["advanced\001classes\001HUNTER\001wait"] = true, ["watch"] = true } } } }
    rec.selected = { "DontDoThat", "advanced", "classes", "HUNTER" }
    truthy(ns.Options.Open())
    eq(rec.selected, { "DontDoThat", "home" }, "Home, not the last page")
    local open = dialog.Status.DontDoThat.status.groups.groups
    eq(open["advanced\001classes\001HUNTER"], nil); eq(open["advanced\001classes\001HUNTER\001wait"], nil)
    truthy(open.watch and open.advanced, "other nodes keep their state")
    ns.Options.Open("sound"); eq(rec.selected, { "DontDoThat", "appearance", "sound" })
    ns.Options.Open("classes"); eq(rec.selected, { "DontDoThat", "advanced", "classes" })
    ns.Options.Open("bogus"); eq(rec.selected, { "DontDoThat", "home" })
  end)
  restore()
  truthy(ok, tostring(err))
end)

test("warnings tab: toast controls hide under Warning and keep their values", function()
  local ns = fresh({ toast = { bgAlpha = 40, textAlpha = 80, scale = 150 } })
  local calls = {}
  ns.Demo = { Preview = function(kind) calls[#calls + 1] = "preview " .. kind end }
  ns.Toast = { StartMove = function() calls[#calls + 1] = "move" end, ResetPosition = function() calls[#calls + 1] = "reset" end,
    Refresh = function() calls[#calls + 1] = "refresh" end }
  local w = ns.Options.Warnings().args
  eq(w.style.get(), "toast")
  for _, key in ipairs({ "toastBg", "toastText", "toastScale", "move", "resetPosition" }) do falsy(w[key].hidden(), key .. " shown for Toast") end
  truthy(w.warningLook.hidden())
  eq(w.toastBg.get(), 40); eq(w.toastText.get(), 80); eq(w.toastScale.get(), 150)
  eq({ w.toastBg.min, w.toastBg.max, w.toastScale.min, w.toastScale.max }, { 0, 100, 50, 200 })
  w.toastBg.set(nil, 0)
  eq(ns.db.profile.toast.bgAlpha, 0)
  w.preview.func(); w.move.func(); w.resetPosition.func()
  eq(calls, { "refresh", "preview toast", "move", "reset" })
  eq(ns.db.profile.toast, { bgAlpha = 0, textAlpha = 80, scale = 150 }, "Reset position changes no saved value here")
  w.style.set(nil, "warning")
  eq(ns.db.profile.alert.style, "warning")
  for _, key in ipairs({ "toastBg", "toastText", "toastScale", "move", "resetPosition" }) do truthy(w[key].hidden(), key .. " hidden for Warning") end
  falsy(w.warningLook.hidden(), "Warning explains why")
  falsy(w.preview.hidden, "preview stays")
  calls = {}
  w.preview.func()
  eq(calls, { "preview warning" })
  w.style.set(nil, "toast")
  eq(w.toastText.get(), 80, "values survive the switch")
end)

test("warnings tab: chat record toggle, disabled only when the addon is off", function()
  local ns = fresh({ alerts = false })
  local w = ns.Options.Warnings().args
  truthy(w.chat.get())
  falsy(w.chat.disabled(), "not tied to the warning sound switch")
  falsy(w.messagesOff.hidden(), "explains that messages are off")
  w.chat.set(nil, false)
  eq(ns.db.profile.alert.chat, false)
  ns.db.profile.enabled = false
  truthy(w.chat.disabled())
  ns.db.profile.enabled, ns.db.profile.alerts = true, true
  truthy(w.messagesOff.hidden())
end)

test("explanations tab: three sliders for the pinned explanation and a preview", function()
  local ns = fresh({})
  local previewed
  ns.Demo = { Preview = function(kind) previewed = kind end }
  local e = ns.Options.Explanations().args
  eq(e.explanationBg.get(), 100); eq(e.explanationText.get(), 100); eq(e.explanationScale.get(), 100)
  e.explanationScale.set(nil, 125)
  eq(ns.db.profile.explanation.scale, 125)
  e.preview.func()
  eq(previewed, "explanation")
  eq(e.move, nil, "a pinned explanation stays by its mark, so it has no Move")
end)

test("appearance buttons are safe when their screens are not loaded", function()
  local ns = fresh({})
  local w, e = ns.Options.Warnings().args, ns.Options.Explanations().args
  w.preview.func(); w.move.func(); w.resetPosition.func(); w.toastScale.set(nil, 120); e.preview.func()
  eq(ns.db.profile.toast.scale, 120)
end)

test("controls use compact widths; text and checkboxes use the full row", function()
  local ns = fresh({})
  local function check(group, path)
    for key, w in pairs(group.args or {}) do
      if w.type == "group" then check(w, path .. "." .. key)
      elseif w.type == "range" or (w.type == "select" and w.style ~= "radio") then
        truthy(w.width ~= "full", path .. "." .. key .. " is a full-width " .. w.type)
      elseif w.type == "description" or w.type == "toggle" then
        eq(w.width, "full", path .. "." .. key)
      end
    end
  end
  local root = ns.Options.Root()
  for _, key in ipairs({ "home", "appearance", "advanced" }) do
    local g = root.args[key]
    if key == "advanced" then g = { args = { tuning = g.args.tuning, debug = g.args.debug } } end
    check(g, key)
  end
end)

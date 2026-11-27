local H = require("harness")

-- Test settings in the settings pages (banner, Profiles page, Reset all), the slash command and the question popup,
-- over the real bundled AceDB, AceDBOptions and AceConfigRegistry.
local GLOBALS = { "LibStub", "GetRealmName", "UnitName", "UnitNameUnmodified", "RegionalUniqueNamesEnabled", "strlenutf8",
  "C_GameRules", "Enum", "UnitClass", "UnitRace", "UnitFactionGroup", "GetLocale", "GetCurrentRegion",
  "GetCurrentRegionName", "CreateFrame", "DontDoThatDB", "securecallfunction" }
local function cleanup() for _, k in ipairs(GLOBALS) do _G[k] = nil end end

local function session()
  _G.LibStub = nil
  _G.securecallfunction = function(f, ...) return f(...) end
  _G.GetRealmName = function() return "Realm" end
  _G.UnitName = function() return "Hero" end
  _G.UnitNameUnmodified = function() return "Hero" end
  _G.RegionalUniqueNamesEnabled = function() return false end
  _G.C_GameRules = { IsGameRuleActive = function() return false end }
  _G.Enum = { GameRule = { RPRuleset = 1, PvPRuleset = 2, HardcoreRuleset = 3 } }
  _G.strlenutf8 = function(s) return #s end
  _G.UnitClass = function() return "Warrior", "WARRIOR" end
  _G.UnitRace = function() return "Human", "Human" end
  _G.UnitFactionGroup = function() return "Alliance" end
  _G.GetLocale = function() return "enUS" end
  _G.GetCurrentRegion = function() return 1 end
  _G.GetCurrentRegionName = function() return "US" end
  _G.CreateFrame = function() return { RegisterEvent = function() end, SetScript = function() end } end
  for _, f in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua", "AceDB-3.0/AceDB-3.0.lua",
    "AceDBOptions-3.0/AceDBOptions-3.0.lua", "AceConfig-3.0/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua" }) do
    assert(loadfile("DontDoThat/Libs/" .. f))()
  end
  local ns = { version = "0.1.0" }
  for _, f in ipairs({ "UI/Helpers.lua", "Data/Sounds.lua", "Data/SpellData.lua", "Data/RuleSpells.lua", "Data/SkipRevisions.lua", "Data/TalentData.lua", "Model/SpellData.lua", "Rules/Schema.lua", "Rules/Engine.lua",
    "Rules/Data/Hunter.lua", "Rules/Data/Warrior.lua", "Rules/Data/Mage.lua", "Data/TrainerPrices.lua",
    "Model/Ledger.lua", "Model/Savings.lua", "Model/Milestones.lua", "Model/Settings.lua", "Model/SkipRevision.lua", "Model/ItemCategory.lua",
    "Model/TestSettings.lua", "Options/Options.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  ns.db = _G.LibStub("AceDB-3.0"):New("DontDoThatDB", {
    profile = { alerts = true, minPrice = 100, debug = false, traceItems = false },
    char = { ledger = {}, allowedItems = {} },
  }, true)
  local said = {}
  local deps = { say = function(m) said[#said + 1] = m end, log = function() end, mark = function(p) p.styleMarked = true end,
    refresh = function() end, syncDebug = function() end }
  ns.addon = { TestSettingsDeps = function() return deps end }
  return ns, said
end

local function run(fn)
  _G.DontDoThatDB = nil
  local ok, err = pcall(fn)
  cleanup()
  if not ok then error(err, 0) end
end

local function hidden(group) local h = group.args.testBanner.hidden; return h() end

test("banner: every settings page has it, hidden until test settings are on", function() run(function()
  local ns = session()
  for _, page in ipairs(ns.Options.Pages()) do
    truthy(page.group.args.testBanner, page.key .. " has the banner")
    truthy(hidden(page.group), page.key .. " banner is hidden while the mode is off")
  end
  ns.TestSettings.On(ns.db, {})
  for _, page in ipairs(ns.Options.Pages()) do falsy(hidden(page.group), page.key .. " banner shows while on") end
end) end)

test("banner: says the profile is temporary and names the own profile as safe", function() run(function()
  local ns = session()
  ns.db:SetProfile("Raid")
  ns.TestSettings.On(ns.db, {})
  local banner = ns.Options.Home().args.testBanner
  local text = banner.args.text.name()
  truthy(text:find("temporary profile with default settings", 1, true), text)
  truthy(text:find("Your own profile Raid is safe and unchanged", 1, true), text)
  eq(banner.args.restore.name, "Restore my settings")
end) end)

test("banner: Restore my settings turns test settings off and says which profile is in use", function() run(function()
  local ns, said = session()
  ns.db:SetProfile("Raid")
  ns.TestSettings.On(ns.db, {})
  ns.Options.Home().args.testBanner.args.restore.func()
  eq(ns.TestSettings.IsOn(ns.db), false)
  eq(ns.db:GetCurrentProfile(), "Raid")
  eq(said, { "Test settings off. Profile in use: Raid (your own). The temporary profile is deleted." })
end) end)

test("profiles page: the standard AceDBOptions control, valid for AceConfigRegistry, locked while test settings are on", function() run(function()
  local ns = session()
  local page = ns.Options.Profiles()
  truthy(page.args.manage, "the control is there")
  truthy(page.args.manage.args.choose and page.args.manage.args.new and page.args.manage.args.delete, "choose, new and delete")
  _G.LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(page, "DontDoThat")
  falsy(page.args.manage.disabled(), "usable while the mode is off")
  local function plain(s) return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
  eq(plain(page.args.current.name()), "Profile in use: Default (your own).")
  truthy(page.args.lockNote.hidden(), "no lock note while off")
  ns.TestSettings.On(ns.db, {})
  truthy(page.args.manage.disabled(), "locked while on")
  eq(plain(page.args.current.name()), "Profile in use: DDT test (temporary).")
  falsy(page.args.lockNote.hidden())
end) end)

test("profiles page: choosing another profile switches it for this character", function() run(function()
  local ns = session()
  local page = ns.Options.Profiles()
  local choose = page.args.manage.args.choose
  local handler = page.args.manage.handler
  handler[choose.set](handler, {}, "Raid")
  eq(ns.db:GetCurrentProfile(), "Raid")
end) end)

test("profiles page: is a page of the root window and of the game's panel", function() run(function()
  local ns = session()
  local keys = {}
  for _, p in ipairs(ns.Options.Pages()) do keys[#keys + 1] = p.key end
  truthy(table.concat(keys, ","):find("profiles", 1, true))
  truthy(ns.Options.PATHS.profiles)
  _G.LibStub("AceConfigRegistry-3.0"):ValidateOptionsTable(ns.Options.Root(), "DontDoThat")
end) end)

test("reset all: keeps the player's Always Allow items while test settings are on, empties them otherwise", function() run(function()
  local ns = session()
  ns.db.char.allowedItems[10050] = { name = "Mageweave Bag" }
  local rebuild, toast = ns.Options.Rebuild, ns.Toast
  ns.Options.Rebuild, ns.Toast = function() end, nil
  ns.TestSettings.On(ns.db, {})
  ns.Options.Home().args.resetAll.func()
  truthy(ns.db.char.allowedItems[10050], "kept while on")
  ns.TestSettings.Off(ns.db, {})
  ns.Options.Home().args.resetAll.func()
  ns.Options.Rebuild, ns.Toast = rebuild, toast
  eq(next(ns.db.char.allowedItems), nil, "emptied when off")
end) end)

-- Slash command
local function slash()
  local ns = { version = "9.9.9", build = "1" }
  local said, calls = {}, {}
  ns.addon = { Print = function(_, m) said[#said + 1] = m end, RegisterChatCommand = function() end,
    db = { profile = {}, global = {}, char = {} },
    TestSettingsDeps = function() return { tag = "deps" } end }
  H.load("DontDoThat/Model/Settings.lua", ns)
  H.load("DontDoThat/Core/Registry.lua", ns)
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  H.load("DontDoThat/Core/Slash.lua", ns)
  ns.TestSettings = { Command = function(db, deps, action) calls[#calls + 1] = { db = db, deps = deps, action = action } end }
  return ns, said, calls, function(s) ns.addon:HandleSlash(s) end
end

test("slash: testsettings on and off reach the controller with the addon's database", function()
  local ns, said, calls, run = slash()
  run("testsettings on"); run("TESTSETTINGS off")
  eq(#calls, 2); eq(calls[1].action, "on"); eq(calls[2].action, "off")
  eq(calls[1].db, ns.addon.db); eq(calls[1].deps.tag, "deps")
  eq(#said, 0)
end)

test("slash: testsettings with a wrong or missing word prints usage and changes nothing", function()
  local _, said, calls, run = slash()
  run("testsettings"); run("testsettings maybe"); run("testsettings on now")
  eq(#calls, 0)
  eq(#said, 3)
  truthy(said[1]:find("usage: /ddt testsettings on|off", 1, true))
end)

test("slash: the diagnostics help lists testsettings", function()
  local _, said, _, run = slash()
  run("help diagnostics")
  truthy(table.concat(said, "\n"):find("/ddt testsettings on|off", 1, true))
end)

-- The question popup
test("popup: Close answers the open question as declined and hides it", function()
  local ns = { L = setmetatable({}, { __index = function(_, k) return k end }) }
  local hidden, declined = {}, 0
  _G.StaticPopupDialogs = {}
  _G.StaticPopup_Show = function() return {} end
  _G.StaticPopup_Hide = function(key) hidden[#hidden + 1] = key end
  H.load("DontDoThat/UI/ConfirmPopup.lua", ns)
  eq(ns.ConfirmPopup.Close(), false, "nothing open")
  truthy(ns.ConfirmPopup.Show("Buy?", function() error("must not buy") end, function() declined = declined + 1 end))
  eq(ns.ConfirmPopup.Close(), true)
  eq(declined, 1)
  eq(hidden, { "DONTDOTHAT_CONFIRM" })
  eq(ns.ConfirmPopup.Close(), false, "answered once")
  _G.StaticPopupDialogs, _G.StaticPopup_Show, _G.StaticPopup_Hide = nil, nil, nil
end)

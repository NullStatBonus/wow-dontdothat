local H = require("harness")

-- Test settings against the real bundled AceDB: login, logout (the saved file) and the next login.
local GLOBALS = { "LibStub", "GetRealmName", "UnitName", "UnitNameUnmodified", "RegionalUniqueNamesEnabled", "strlenutf8",
  "C_GameRules", "Enum", "UnitClass", "UnitRace", "UnitFactionGroup", "GetLocale", "GetCurrentRegion",
  "GetCurrentRegionName", "CreateFrame", "DontDoThatDB", "securecallfunction" }
local function cleanup() for _, k in ipairs(GLOBALS) do _G[k] = nil end end

local logoutFn
local function login()
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
  _G.CreateFrame = function() return { RegisterEvent = function() end, SetScript = function(_, _, fn) logoutFn = fn end } end
  for _, f in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua", "AceDB-3.0/AceDB-3.0.lua" }) do
    assert(loadfile("DontDoThat/Libs/" .. f))()
  end
  local ns = {}
  H.load("DontDoThat/Model/TestSettings.lua", ns)
  local db = _G.LibStub("AceDB-3.0"):New("DontDoThatDB", {
    profile = { alerts = true, debug = false, traceItems = false, minPrice = 100 },
    char = { ledger = {}, allowedItems = {} },
  }, true)
  db.RegisterCallback(ns, "OnDatabaseShutdown", function() ns.TestSettings.Shutdown(db) end)
  return ns.TestSettings, db, ns
end

local function logout() logoutFn({}, "PLAYER_LOGOUT") end

local function collector()
  local logs = {}
  return { log = function(m) logs[#logs + 1] = m end, mark = function(p) p.styleMarked = true end }, logs
end

local function run(fn)
  local ok, err = pcall(function() _G.DontDoThatDB = nil; fn() end)
  cleanup()
  if not ok then error(err, 0) end
end

test("test settings on: default settings on a temporary profile, the own profile untouched, one log line", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  db.char.allowedItems[5] = { name = "x" }
  local opts, logs = collector()
  eq(TS.On(db, opts), "on")
  eq(db:GetCurrentProfile(), "DDT test")
  eq(db.profile.minPrice, 100, "defaults")
  truthy(db.profile.styleMarked, "marked as migrated")
  eq(db.char.testSettings.profile, "Default")
  eq(db.char.allowedItems[5].name, "x", "db.char data is not touched")
  eq(rawget(db.profiles, "Default").minPrice, 777, "the own profile is untouched")
  eq(logs, { "test settings: on (own settings put aside)" })
  local cur, temporary = TS.Current(db)
  eq(cur, "DDT test"); truthy(temporary)
end) end)

test("test settings on while on: resets to defaults and keeps the original profile name", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  local opts, logs = collector()
  TS.On(db, opts)
  db.profile.minPrice = 5
  eq(TS.On(db, opts), "reset")
  eq(db.profile.minPrice, 100)
  eq(db.char.testSettings.profile, "Default")
  eq(logs[2], "test settings: reset to defaults")
  TS.Off(db, opts)
  eq(db.profile.minPrice, 777, "off still returns to the original profile")
end) end)

test("test settings off: the own profile is back with its values, the temporary profile is gone", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  local opts, logs = collector()
  TS.On(db, opts)
  eq(TS.Off(db, opts), true)
  eq(db:GetCurrentProfile(), "Default")
  eq(db.profile.minPrice, 777)
  eq(rawget(db.profiles, "DDT test"), nil)
  eq(db.char.testSettings, nil)
  eq(logs[#logs], "test settings: off (own settings restored)")
end) end)

test("test settings off while not on: nothing changes", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  local opts, logs = collector()
  eq(TS.Off(db, opts), false)
  eq(db.profile.minPrice, 777)
  eq(#logs, 0)
end) end)

test("test settings keep another character's profile and settings", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  db.sv.profileKeys["Other - Realm"] = "Default"
  TS.On(db, collector())
  eq(db.sv.profileKeys["Other - Realm"], "Default")
  eq(rawget(db.profiles, "Default").minPrice, 777)
  TS.Off(db, collector())
  eq(db.sv.profileKeys["Other - Realm"], "Default")
end) end)

test("a character on its own named profile returns to that profile", function() run(function()
  local TS, db = login()
  db:SetProfile("Raid")
  db.profile.minPrice = 321
  TS.On(db, collector())
  eq(db.char.testSettings.profile, "Raid")
  TS.Off(db, collector())
  eq(db:GetCurrentProfile(), "Raid")
  eq(db.profile.minPrice, 321)
end) end)

test("debug stays on across on, reset and off", function() run(function()
  local TS, db = login()
  db.profile.debug, db.profile.traceItems = true, true
  TS.On(db, collector())
  truthy(db.profile.debug and db.profile.traceItems, "after on")
  TS.On(db, collector())
  truthy(db.profile.debug, "after reset")
  TS.Off(db, collector())
  truthy(db.profile.debug and db.profile.traceItems, "after off")
end) end)

test("debug switched on during test settings stays on after off", function() run(function()
  local TS, db = login()
  TS.On(db, collector())
  db.profile.debug = true
  TS.Off(db, collector())
  truthy(db.profile.debug, "debug is on after off")
end) end)

test("logout while on: the saved profile key names the own profile, and the record is saved", function() run(function()
  local TS, db = login()
  db:SetProfile("Raid")
  TS.On(db, collector())
  logout()
  eq(DontDoThatDB.profileKeys["Hero - Realm"], "Raid")
  truthy(DontDoThatDB.char["Hero - Realm"].testSettings)
end) end)

test("login with no open run: the own profile is active, the record and the temporary profile are gone", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  TS.On(db, collector())
  db.profile.minPrice = 5
  logout()
  local TS2, db2 = login()
  eq(db2:GetCurrentProfile(), "Default", "a save already wrote the own profile back")
  local opts, logs = collector()
  eq(TS2.Login(db2, opts, false), "restored")
  eq(db2.profile.minPrice, 777)
  eq(db2.char.testSettings, nil)
  eq(rawget(db2.profiles, "DDT test"), nil)
  eq(logs, { "test settings: restored at login" })
end) end)

test("login with a run open: test settings stay on with the values the run set", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  TS.On(db, collector(), "run-1")
  db.profile.minPrice = 55
  logout()
  local TS2, db2 = login()
  local opts, logs = collector()
  eq(TS2.Login(db2, opts, true), "kept")
  eq(db2:GetCurrentProfile(), "DDT test")
  eq(db2.profile.minPrice, 55)
  eq(db2.char.testSettings.runId, "run-1")
  eq(logs, { "test settings: on at login" })
  logout()
  eq(DontDoThatDB.profileKeys["Hero - Realm"], "Default")
end) end)

test("a downgrade: a version without this code loads the own profile and ignores the record", function() run(function()
  local TS, db = login()
  db:SetProfile("Raid")
  db.profile.minPrice = 321
  TS.On(db, collector())
  logout()
  -- A load that never calls Login: the plain AceDB result.
  local _, plain = login()
  eq(plain:GetCurrentProfile(), "Raid")
  eq(plain.profile.minPrice, 321)
end) end)

test("a temporary profile in use with no record: the default profile becomes active and the temporary one is deleted", function() run(function()
  local TS, db = login()
  TS.On(db, collector())
  db.char.testSettings = nil -- the record is lost
  local opts, logs = collector()
  eq(TS.Login(db, opts, true), "removed")
  eq(db:GetCurrentProfile(), "Default")
  eq(rawget(db.profiles, "DDT test"), nil)
  eq(logs, { "test settings: temporary profile removed at login" })
end) end)

test("nothing to do at login with no record and an ordinary profile", function() run(function()
  local TS, db = login()
  eq(TS.Login(db, collector(), false), nil)
  eq(db:GetCurrentProfile(), "Default")
end) end)

test("a record that names the temporary profile or nothing falls back to the default profile", function() run(function()
  local TS, db = login()
  TS.On(db, collector())
  db.char.testSettings.profile = "DDT test"
  TS.Shutdown(db)
  eq(db.sv.profileKeys["Hero - Realm"], "Default")
  TS.Off(db, collector())
  eq(db:GetCurrentProfile(), "Default")
end) end)

test("an own profile with only default values (stripped when saved) round-trips", function() run(function()
  local TS, db = login()
  TS.On(db, collector())
  logout()
  local TS2, db2 = login()
  TS2.Login(db2, collector(), false)
  eq(db2:GetCurrentProfile(), "Default")
  eq(db2.profile.minPrice, 100)
end) end)

test("a failing profile switch changes nothing and logs the failure", function() run(function()
  local TS, db = login()
  local opts, logs = collector()
  local real = db.SetProfile
  db.SetProfile = function() error("nope") end
  local status = TS.On(db, opts)
  eq(status, nil)
  eq(db.char.testSettings, nil)
  truthy(logs[1]:find("test settings: FAILED:", 1, true))
  db.SetProfile = real
  eq(db:GetCurrentProfile(), "Default")
end) end)

test("run rules: same id changes nothing, a new id resets, no id is ignored, an end turns it off", function() run(function()
  local TS, db = login()
  db.profile.minPrice = 777
  local opts, logs = collector()
  eq(TS.RunStarted(db, opts, nil), "ignored")
  eq(TS.IsOn(db), false)
  eq(TS.RunStarted(db, opts, "r1"), "on")
  db.profile.minPrice = 5
  eq(TS.RunStarted(db, opts, "r1"), "seen")
  eq(db.profile.minPrice, 5, "a repeated start keeps the run's values")
  eq(TS.RunStarted(db, opts, "r2"), "reset")
  eq(db.profile.minPrice, 100)
  eq(db.char.testSettings.runId, "r2")
  TS.RunEnded(db, opts, "ended")
  eq(TS.IsOn(db), false)
  eq(db.profile.minPrice, 777)
  eq(TS.RunEnded(db, opts, "deleted"), false)
  eq(logs, {
    "test settings: run start without an id",
    "test settings: on (own settings put aside)",
    "test settings: run already seen",
    "test settings: another run started",
    "test settings: run ended: ended",
    "test settings: off (own settings restored)",
    "test settings: run ended: deleted",
  })
end) end)

test("the temporary profile is marked as migrated, so a later load sets no alert style and prints no notice", function() run(function()
  local TS, db = login()
  local marked
  TS.On(db, { mark = function(p) marked = p end })
  truthy(marked == db.profile, "mark received the temporary profile")
end) end)

-- The controller: chat lines, the order of the steps and one line for one switch.
local function deps()
  local d = { says = {}, steps = {} }
  d.say = function(m) d.says[#d.says + 1] = m end
  d.log = function() end
  d.mark = function(p) p.styleMarked = true end
  d.closeUi = function() d.steps[#d.steps + 1] = "close" end
  d.refresh = function() d.steps[#d.steps + 1] = "refresh" end
  d.syncDebug = function() d.steps[#d.steps + 1] = "debug" end
  return d
end

-- Wires AceDB's profile callbacks the way Core/Addon.lua does.
local function wire(TS, db, ns, d)
  db.RegisterCallback(ns, "OnProfileChanged", function() TS.ProfileChanged(db, d) end)
end

test("chat: test settings on names the temporary profile and the own profile; one line", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  db:SetProfile("Raid"); d.says, d.steps = {}, {}
  TS.Command(db, d, "on")
  eq(#d.says, 1, "one profile line for one switch")
  truthy(d.says[1]:find("Profile in use: DDT test (temporary", 1, true), d.says[1])
  truthy(d.says[1]:find("Your own profile Raid is put aside", 1, true), d.says[1])
  eq(d.steps[1], "close", "questions and previews close before the swap")
  eq(d.steps[#d.steps], "refresh", "the pages redraw after the swap")
end) end)

test("chat: on while on says the temporary profile was reset", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  TS.Command(db, d, "on"); d.says = {}
  TS.Command(db, d, "on")
  eq(#d.says, 1)
  truthy(d.says[1]:find("reset to defaults. Profile in use: DDT test (temporary)", 1, true), d.says[1])
end) end)

test("chat: off names the own profile; off when not on says so", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  TS.Command(db, d, "off")
  eq(d.says, { "Test settings are not on. Profile in use: Default (your own)." })
  TS.Command(db, d, "on"); d.says = {}
  TS.Command(db, d, "off")
  eq(d.says, { "Test settings off. Profile in use: Default (your own). The temporary profile is deleted." })
end) end)

test("chat: a switch on the Profiles page prints one profile-changed line", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  db:SetProfile("Raid")
  eq(d.says, { "Profile changed. Profile in use: Raid (your own)." })
  eq(d.steps, { "debug", "refresh" })
end) end)

test("chat: a profile switch while temporary says temporary", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  TS.Command(db, d, "on"); d.says = {}
  db:SetProfile("Raid") -- another addon or the console switches while on
  eq(d.says[1]:find("Profile changed. Profile in use: Raid (your own).", 1, true) ~= nil, true)
end) end)

test("chat at login: own profile, restored, and kept for an open run", function() run(function()
  local TS, db = login()
  local d = deps()
  eq(TS.LoginAnnounce(db, d, false), nil)
  eq(d.says, { "Profile in use: Default (your own)." })
  TS.Command(db, d, "on", "r1")
  logout()
  local TS2, db2 = login()
  d = deps()
  eq(TS2.LoginAnnounce(db2, d, true), "kept")
  eq(d.says, { "Test settings are still on for the open run. Profile in use: DDT test (temporary)." })
  logout()
  local TS3, db3 = login()
  d = deps()
  eq(TS3.LoginAnnounce(db3, d, false), "restored")
  eq(d.says, { "Test settings were left on. Profile in use: Default (your own). The temporary profile is deleted." })
end) end)

test("chat: a run start and a run end print the switch line once each; a repeated start prints nothing", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  TS.OnRunStarted(db, d, "r1")
  eq(#d.says, 1); truthy(d.says[1]:find("(temporary", 1, true))
  TS.OnRunStarted(db, d, "r1")
  eq(#d.says, 1)
  TS.OnRunEnded(db, d, "ended")
  eq(#d.says, 2); truthy(d.says[2]:find("(your own)", 1, true))
  TS.OnRunEnded(db, d, "ended")
  eq(#d.says, 2)
end) end)

test("chat: a failing switch says why and prints no profile line", function() run(function()
  local TS, db, ns = login()
  local d = deps(); wire(TS, db, ns, d)
  db.SetProfile = function() error("nope") end
  TS.Command(db, d, "on")
  eq(#d.says, 1)
  truthy(d.says[1]:find("could not change the profile", 1, true))
end) end)

local H = require("harness")

-- The whole addon in real TOC order over the real bundled libraries: DontDoThat loads and initializes first,
-- CheckThat appears afterwards (it lists DontDoThat as an optional dependency), then PLAYER_LOGIN enables the addon.
local GLOBALS = { "LibStub", "CreateFrame", "UIParent", "GetRealmName", "UnitName", "UnitNameUnmodified", "RegionalUniqueNamesEnabled",
  "strlenutf8", "C_GameRules", "Enum", "UnitClass", "UnitRace", "UnitFactionGroup", "UnitLevel", "GetLocale", "GetCurrentRegion",
  "GetCurrentRegionName", "securecallfunction", "DEFAULT_CHAT_FRAME", "SlashCmdList", "GetAddOnMetadata", "CheckThat", "DontDoThatDB" }
local function cleanup() for _, k in ipairs(GLOBALS) do _G[k] = nil end end

local function tocFiles(toc)
  local out = {}
  for line in io.open("DontDoThat/" .. toc):read("*a"):gmatch("[^\r\n]+") do
    if not line:find("^#") and line:find("%.lua$") then out[#out + 1] = "DontDoThat/" .. line:gsub("\\", "/") end
  end
  return out
end

-- One login. opts.checkThat(): a fake CheckThat table installed after the addon initialized, or nil.
-- Returns a session with the chat lines, ns, the AceDB object and logout().
local function login(opts)
  opts = opts or {}
  _G.LibStub = nil
  local chat = {}
  _G.CreateFrame = function()
    local f = setmetatable({ scripts = {} }, { __index = function(t) return function() return t end end })
    f.SetScript = function(self, n, fn) self.scripts[n] = fn end
    return f
  end
  _G.UIParent = _G.CreateFrame("Frame")
  local who = opts.who or { name = "Hero", realm = "Realm" }
  _G.GetRealmName = function() return who.realm end
  _G.UnitName = function() return who.name end
  _G.UnitNameUnmodified = function() if who.surname then return who.name, who.surname end return who.name end
  _G.RegionalUniqueNamesEnabled = function() return who.surname ~= nil end
  _G.C_GameRules = { IsGameRuleActive = function() return false end }
  _G.Enum = { GameRule = { RPRuleset = 1, PvPRuleset = 2, HardcoreRuleset = 3 } }
  _G.strlenutf8 = function(s) return #s end
  _G.UnitClass = function() return "Warrior", "WARRIOR" end
  _G.UnitRace = function() return "Human", "Human" end
  _G.UnitFactionGroup = function() return "Alliance" end
  _G.UnitLevel = function() return 20 end
  _G.GetLocale = function() return "enUS" end
  _G.GetCurrentRegion = function() return 1 end
  _G.GetCurrentRegionName = function() return "US" end
  _G.securecallfunction = function(f, ...) return f(...) end
  _G.SlashCmdList = {}
  _G.GetAddOnMetadata = function(_, field) return field == "Version" and (opts.version or "0.15.0") or nil end
  _G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = (m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end }
  _G.CheckThat = nil
  for _, f in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua", "AceAddon-3.0/AceAddon-3.0.lua",
    "AceEvent-3.0/AceEvent-3.0.lua", "AceHook-3.0/AceHook-3.0.lua", "AceDB-3.0/AceDB-3.0.lua", "AceConsole-3.0/AceConsole-3.0.lua" }) do
    assert(loadfile("DontDoThat/Libs/" .. f))()
  end
  local ns = {}
  for _, path in ipairs(tocFiles(opts.toc or "DontDoThat_Vanilla.toc")) do H.load(path, ns) end
  ns.addon:OnInitialize()
  if opts.checkThat then _G.CheckThat = opts.checkThat() end -- CheckThat loads after this addon
  ns.addon:OnEnable()
  return {
    ns = ns, chat = chat, db = ns.db,
    logout = function() _G.LibStub("AceDB-3.0").frame.scripts.OnEvent({}, "PLAYER_LOGOUT") end,
    say = function(cmd) ns.addon:HandleSlash(cmd) end,
  }
end

-- A fake current CheckThat. run: the open run's plan title or nil; the entries and the run callback are kept.
local function fakeCheckThat(run)
  local t = { entries = {}, run = run }
  function t.Entry(_, name, fn) t.entries[name] = fn; return true end
  function t.OnRun(_, fn) t.hook = fn; return true end
  function t.ActiveRun() return t.run end
  return t
end

local function has(lines, text)
  for _, l in ipairs(lines) do if l:find(text, 1, true) then return true end end
  return false
end

local function run(fn)
  _G.DontDoThatDB = nil
  local ok, err = pcall(fn)
  cleanup()
  if not ok then error(err, 0) end
end

test("boot: both TOCs list CheckThat.lua and Model/TestSettings.lua", function()
  for _, toc in ipairs({ "DontDoThat_Vanilla.toc", "DontDoThat_Camelot.toc" }) do
    local files = table.concat(tocFiles(toc), "\n")
    truthy(files:find("DontDoThat/CheckThat.lua", 1, true), toc)
    truthy(files:find("DontDoThat/Model/TestSettings.lua", 1, true), toc)
  end
end)

test("boot: no CheckThat, a normal login says which profile is in use and nothing else changes", function() run(function()
  local s = login()
  truthy(has(s.chat, "Profile in use: Default (your own)."), table.concat(s.chat, "\n"))
  eq(s.ns.CheckThat.Status(), "not detected")
  eq(s.db:GetCurrentProfile(), "Default")
end) end)

test("boot: test settings on, save, then a login with no CheckThat restores the player's own profile", function() run(function()
  local s = login()
  s.db.profile.minPrice = 777
  s.say("testsettings on")
  eq(s.db:GetCurrentProfile(), "DDT test")
  s.logout()
  eq(DontDoThatDB.profileKeys["Hero - Realm"], "Default", "the saved file names the own profile")
  local s2 = login()
  eq(s2.db:GetCurrentProfile(), "Default")
  eq(s2.db.profile.minPrice, 777, "the player's settings are unchanged")
  eq(s2.db.char.testSettings, nil)
  truthy(has(s2.chat, "Test settings were left on. Profile in use: Default (your own)."), table.concat(s2.chat, "\n"))
  eq(rawget(s2.db.profiles, "DDT test"), nil)
end) end)

test("boot: the same with a CheckThat that reports no open run", function() run(function()
  local s = login()
  s.say("testsettings on")
  s.logout()
  local s2 = login({ checkThat = function() return fakeCheckThat(nil) end })
  eq(s2.db:GetCurrentProfile(), "Default")
  truthy(has(s2.chat, "Test settings were left on."))
end) end)

test("boot: a CheckThat too old to report a run restores the player's profile", function() run(function()
  local s = login()
  s.say("testsettings on")
  s.logout()
  local s2 = login({ checkThat = function() local t = fakeCheckThat("plan"); t.ActiveRun = nil; return t end })
  eq(s2.db:GetCurrentProfile(), "Default")
end) end)

test("boot: an open run keeps test settings and debug across a reload, and the run end turns them off", function() run(function()
  local ct
  local s = login({ checkThat = function() ct = fakeCheckThat(nil); return ct end })
  s.say("debug on")
  ct.run = "plan"
  ct.hook("start", { runId = "run-1" })
  eq(s.db:GetCurrentProfile(), "DDT test")
  truthy(s.ns.Log.IsEnabled(), "debug stays on")
  s.logout()
  local ct2
  local s2 = login({ checkThat = function() ct2 = fakeCheckThat("plan"); return ct2 end })
  eq(s2.db:GetCurrentProfile(), "DDT test", "still on")
  truthy(s2.ns.Log.IsEnabled(), "debug is still on after the reload")
  truthy(has(s2.chat, "Test settings are still on for the open run. Profile in use: DDT test (temporary)."), table.concat(s2.chat, "\n"))
  local lines = {}
  for _, e in ipairs(s2.ns.Log.Entries()) do lines[#lines + 1] = e.msg end
  truthy(has(lines, "test settings: on at login"), table.concat(lines, "\n"))
  truthy(has(lines, "checkthat: entries registered: 4"))
  truthy(has(lines, "checkthat: run hook registered"))
  ct2.hook("start", { runId = "run-1" }) -- the catch-up start for the open run
  truthy(has((function() local l = {} for _, e in ipairs(s2.ns.Log.Entries()) do l[#l + 1] = e.msg end return l end)(), "test settings: run already seen"))
  ct2.run = nil
  ct2.hook("end", { reason = "ended" })
  eq(s2.db:GetCurrentProfile(), "Default")
  truthy(has(s2.chat, "Test settings off. Profile in use: Default (your own)."))
end) end)

test("boot: entries report the version, test settings and settings; an entry call writes no log line", function() run(function()
  local ct
  local s = login({ checkThat = function() ct = fakeCheckThat(nil); return ct end })
  s.say("debug on")
  local before = #s.ns.Log.Entries()
  eq(ct.entries.version(), 1500)
  eq(ct.entries.testsettings(), "off")
  eq(ct.entries.setting("nudge"), s.ns.Registry.Get("nudge", s.db.profile))
  eq(ct.entries.setting("marks"), "none")
  eq(ct.entries.setting("allowed"), 0)
  s.say("testsettings on")
  eq(ct.entries.testsettings(), "on")
  eq(#s.ns.Log.Entries() - before, 1, "only the test-settings line; the entry calls wrote nothing")
end) end)

test("boot: a swap and a restore set no alert style and print no skip-list notice on the next load", function() run(function()
  local s = login()
  s.db.profile.alert.style = "toast"
  s.say("testsettings on")
  s.say("testsettings off")
  s.logout()
  local s2 = login()
  truthy(not has(s2.chat, "Skip list revision"), table.concat(s2.chat, "\n"))
  eq(s2.db.profile.alert.style, "toast")
end) end)

test("boot: the old build ignores the record and loads the own profile", function() run(function()
  local s = login()
  s.db.profile.minPrice = 321
  s.say("testsettings on")
  s.logout()
  local plain = _G.LibStub("AceDB-3.0"):New("DontDoThatDB", { profile = { minPrice = 100 } }, true)
  eq(plain:GetCurrentProfile(), "Default")
  eq(plain.profile.minPrice, 321)
end) end)

test("boot: a failing CheckThat does not stop the addon", function() run(function()
  local s = login({ checkThat = function() local t = fakeCheckThat(nil); t.OnRun = function() error("boom") end; return t end })
  truthy(s.ns.CheckThat.Status():find("failed: OnRun:", 1, true))
  s.say("testsettings on")
  eq(s.db:GetCurrentProfile(), "DDT test")
end) end)

test("boot: the Camelot TOC loads the same way", function() run(function()
  local s = login({ toc = "DontDoThat_Camelot.toc" })
  truthy(has(s.chat, "Profile in use: Default (your own)."))
end) end)

test("boot: the debug report names the profile in use, the test-settings state and the CheckThat status", function() run(function()
  local s = login({ checkThat = function() return fakeCheckThat(nil) end })
  local function build() local src = s.ns.Export.sourceProvider(); src.env = {}; src.probe = nil; return s.ns.Export.Build(src) end
  local text = build()
  truthy(text:find("active profile: Default", 1, true), text)
  truthy(text:find("test settings: off", 1, true))
  truthy(text:find("CheckThat: working", 1, true))
  s.say("testsettings on")
  text = build()
  truthy(text:find("active profile: DDT test", 1, true))
  truthy(text:find("test settings: on (temporary profile in use; own profile Default)", 1, true), text)
end) end)

-- Saved variables from real players (names replaced, tables trimmed; tests/fixtures), through a swap and a restore.
local function deepCopy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, x in pairs(v) do out[k] = deepCopy(x) end
  return out
end

local function replay(fixture, who, charKey)
  _G.DontDoThatDB = dofile("tests/fixtures/" .. fixture)
  local s = login({ who = who })
  eq(s.db:GetCurrentProfile(), "Default")
  local profile, char = deepCopy(s.db.profile), deepCopy(s.db.char)
  truthy(next(char.ledger) ~= nil or next(char.catalog) ~= nil, "the fixture loaded this character's data")
  s.say("testsettings on")
  eq(s.db:GetCurrentProfile(), "DDT test")
  eq(s.db.char.allowedItems, char.allowedItems)
  s.say("testsettings off")
  eq(s.db.profile, profile, "the profile after on and off")
  local c2 = deepCopy(s.db.char); c2.testSettings = nil
  eq(c2, char, "db.char after on and off")
  -- Left on at logout, then a login with no open run.
  s.say("testsettings on")
  s.logout()
  eq(DontDoThatDB.profileKeys[charKey], "Default")
  local s2 = login({ who = who })
  eq(s2.db:GetCurrentProfile(), "Default")
  eq(s2.db.profile, profile, "the profile after a save with test settings on")
  local c3 = deepCopy(s2.db.char); c3.testSettings = nil
  eq(c3, char, "db.char after a save with test settings on")
  truthy(not has(s2.chat, "Skip list revision"), table.concat(s2.chat, "\n"))
  eq(s2.db.profiles["DDT test"], nil)
end

test("replay: a WoW Forever player's saved variables survive test settings on, off and a save", function() run(function()
  replay("saved_forever.lua", { name = "Hero", surname = "Two", realm = "" }, "Hero Two")
end) end)

test("replay: a Classic Era player's saved variables survive test settings on, off and a save", function() run(function()
  replay("saved_era.lua", { name = "Hero A", realm = "Realm One" }, "Hero A - Realm One")
end) end)

test("boot: a switch on the Profiles page prints one line, keeps debug on and marks the new profile", function() run(function()
  local s = login()
  s.say("debug on")
  local n = #s.chat
  s.db:SetProfile("Raid")
  eq(#s.chat - n, 1, "one chat line for one switch")
  truthy(s.chat[#s.chat]:find("Profile changed. Profile in use: Raid (your own).", 1, true), s.chat[#s.chat])
  truthy(s.ns.Log.IsEnabled(), "debug stays on")
  truthy(s.db.profile.debug, "the new profile carries the debug flag")
  truthy(s.db.profile.styleMarked, "the new profile is marked, so a later load keeps its alert style")
end) end)

test("boot: debug on writes its own line first", function() run(function()
  local s = login()
  s.say("debug on")
  eq(s.ns.Log.Entries()[1].msg, "debug log turned on")
  s.say("debug off")
  local e = s.ns.Log.Entries()
  eq(e[#e].msg, "debug log turned off")
end) end)

test("boot: each load stamps the version; an upgrade keeps the earlier one; a downgrade keeps the data", function() run(function()
  local s = login({ version = "0.14.0" })
  eq(s.db.global.version, "0.14.0"); eq(s.db.global.previousVersion, nil)
  s.logout()
  local s2 = login({ version = "1.0.0" })
  eq(s2.db.global.version, "1.0.0"); eq(s2.db.global.previousVersion, "0.14.0")
  local function build() local src = s2.ns.Export.sourceProvider(); src.env = {}; src.probe = nil; return s2.ns.Export.Build(src) end
  truthy(build():find("saved data version: 1.0.0 (earlier: 0.14.0)", 1, true))
  s2.logout()
  -- a build that ignores the stamp reads the same data
  local plain = _G.LibStub("AceDB-3.0"):New("DontDoThatDB", { profile = { minPrice = 100 } }, true)
  eq(plain:GetCurrentProfile(), "Default")
end) end)

local H = require("harness")

local function settings()
  local ns = {}
  H.load("DontDoThat/Model/Settings.lua", ns)
  return ns.Settings
end

-- A fake db with the parts MigrateCharKey uses.
local function fakeDb(sv, newKey, current)
  local db = { sv = sv, keys = { char = newKey }, current = current or "Default", switched = {} }
  function db:GetCurrentProfile() return self.current end
  function db:SetProfile(name) self.current = name; self.switched[#self.switched + 1] = name end
  return db
end

local OLD, NEW = "Hero - Realm", "Hero Surname"

test("char key: data and profile choice move to the new key", function()
  local S = settings()
  local ledger = { saved = 5 }
  local sv = { char = { [OLD] = { ledger = ledger } }, profileKeys = { [OLD] = "Alt", [NEW] = "Default" } }
  local db = fakeDb(sv, NEW)
  truthy(S.MigrateCharKey(sv, db, OLD))
  eq(sv.char[NEW].ledger, ledger); eq(sv.char[OLD], nil)
  eq(db.current, "Alt"); eq(sv.profileKeys[OLD], nil)
end)

test("char key: a second run changes nothing", function()
  local S = settings()
  local sv = { char = { [OLD] = { ledger = {} } }, profileKeys = { [OLD] = "Alt", [NEW] = "Default" } }
  local db = fakeDb(sv, NEW)
  S.MigrateCharKey(sv, db, OLD)
  local charNew = sv.char[NEW]
  falsy(S.MigrateCharKey(sv, db, OLD))
  eq(sv.char[NEW], charNew); eq(#db.switched, 1)
end)

test("char key: a profile picked after the move survives the next login", function()
  local S = settings()
  local sv = { char = {}, profileKeys = { [OLD] = "Alt", [NEW] = "Default" } }
  local db = fakeDb(sv, NEW)
  S.MigrateCharKey(sv, db, OLD)
  db.current = "Other" -- the player picks another profile
  S.MigrateCharKey(sv, db, OLD)
  eq(db.current, "Other")
end)

test("char key: equal keys touch nothing", function()
  local S = settings()
  local c = { ledger = {} }
  local sv = { char = { [OLD] = c }, profileKeys = { [OLD] = "Alt" } }
  local db = fakeDb(sv, OLD)
  falsy(S.MigrateCharKey(sv, db, OLD))
  eq(sv.char[OLD], c); eq(sv.profileKeys[OLD], "Alt"); eq(#db.switched, 0)
end)

test("char key: data already under the new key is not overwritten", function()
  local S = settings()
  local old, new = { ledger = { a = 1 } }, { ledger = { b = 2 } }
  local sv = { char = { [OLD] = old, [NEW] = new } }
  S.MigrateCharKey(sv, fakeDb(sv, NEW), OLD)
  eq(sv.char[NEW], new); eq(sv.char[OLD], old)
end)

test("char key: an unreadable old key or a fresh install does nothing and raises nothing", function()
  local S = settings()
  local sv = { char = { [OLD] = { ledger = {} } } }
  falsy(S.MigrateCharKey(sv, fakeDb(sv, NEW), nil))
  truthy(sv.char[OLD])
  local fresh = {}
  falsy(S.MigrateCharKey(fresh, fakeDb(fresh, NEW), OLD))
  eq(fresh.char, nil)
end)

test("adapter: the legacy key is Name - Realm, or nil when a part is missing", function()
  local ns = {}
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  local A = ns.Adapter
  eq(A.ReadLegacyCharKey({ UnitName = function() return "Hero" end, GetRealmName = function() return "Realm" end }), OLD)
  eq(A.ReadLegacyCharKey({ GetRealmName = function() return "Realm" end }), nil)
  eq(A.ReadLegacyCharKey({ UnitName = function() return "Hero" end }), nil)
  eq(A.ReadLegacyCharKey({ UnitName = function() return nil end, GetRealmName = function() return "Realm" end }), nil)
  eq(A.ReadLegacyCharKey({ UnitName = function() error("x") end, GetRealmName = function() return "Realm" end }), nil)
end)

-- End to end with the real bundled AceDB on a Forever-shaped or Era-shaped client.
local GLOBALS = { "LibStub", "GetRealmName", "UnitName", "UnitNameUnmodified", "RegionalUniqueNamesEnabled", "strlenutf8",
  "C_GameRules", "Enum", "UnitClass", "UnitRace", "UnitFactionGroup", "GetLocale", "GetCurrentRegion",
  "GetCurrentRegionName", "CreateFrame", "DontDoThatDB" }
local function cleanup() for _, k in ipairs(GLOBALS) do _G[k] = nil end end

local logout
-- mode "forever": AceDB 40 on Forever. "era": Classic Era. "older": WoW Forever with a library that ignores regional
-- names (AceDB 33): AceDB loads with RegionalUniqueNamesEnabled missing, so its key is "Name - Realm".
local function login(mode)
  local forever = mode == "forever" or mode == "older"
  _G.LibStub = nil
  _G.GetRealmName = function() return "Realm" end
  _G.UnitName = function() return "Hero" end
  _G.UnitNameUnmodified = function() if forever then return "Hero", "Surname" end return "Hero" end
  _G.RegionalUniqueNamesEnabled = mode ~= "older" and function() return forever end or nil
  _G.C_GameRules = { IsGameRuleActive = function() return false end }
  _G.Enum = { GameRule = { RPRuleset = 1, PvPRuleset = 2, HardcoreRuleset = 3 } }
  _G.strlenutf8 = function(s) return #s end
  _G.UnitClass = function() return "Warrior", "WARRIOR" end
  _G.UnitRace = function() return "Human", "Human" end
  _G.UnitFactionGroup = function() return "Alliance" end
  _G.GetLocale = function() return "enUS" end
  _G.GetCurrentRegion = function() return 1 end
  _G.GetCurrentRegionName = function() return "US" end
  _G.CreateFrame = function()
    return { RegisterEvent = function() end, SetScript = function(_, _, fn) logout = fn end }
  end
  for _, f in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua", "AceDB-3.0/AceDB-3.0.lua" }) do
    assert(loadfile("DontDoThat/Libs/" .. f))()
  end
  local ns = {}
  H.load("DontDoThat/Model/Settings.lua", ns)
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  local db = _G.LibStub("AceDB-3.0"):New("DontDoThatDB", { profile = { alerts = true }, char = { ledger = {} } }, true)
  if mode == "older" then _G.RegionalUniqueNamesEnabled = function() return true end end -- the client still has it
  -- As Core/Addon.lua OnInitialize does it.
  ns.Settings.MigrateCharKeys(db.sv, db, ns.Adapter.ReadCharKeys(_G))
  return db
end

local function savedUnderOldKey()
  return {
    char = { [OLD] = { ledger = { saved = 1234 }, costCache = { ["spell:1"] = 100 } } },
    profileKeys = { [OLD] = "Alt" },
    profiles = { Alt = { alerts = false } },
  }
end

test("AceDB 40 on Forever: savings, prices and profile choice survive; a second login changes nothing", function()
  _G.DontDoThatDB = savedUnderOldKey()
  local db = login("forever")
  eq(db.keys.char, NEW)
  eq(db.char.ledger.saved, 1234); eq(db.char.costCache["spell:1"], 100)
  eq(db:GetCurrentProfile(), "Alt"); eq(db.profile.alerts, false)
  eq(_G.DontDoThatDB.profileKeys[OLD], nil); eq(_G.DontDoThatDB.char[OLD], nil)
  logout(nil, "PLAYER_LOGOUT")
  db = login("forever")
  eq(db.char.ledger.saved, 1234); eq(db:GetCurrentProfile(), "Alt")
  db:SetProfile("Default")
  logout(nil, "PLAYER_LOGOUT")
  db = login("forever")
  eq(db:GetCurrentProfile(), "Default", "a profile picked after the move stays")
  cleanup()
end)

test("AceDB 40 on Era: the keys are equal and nothing moves", function()
  _G.DontDoThatDB = savedUnderOldKey()
  local db = login("era")
  eq(db.keys.char, OLD)
  eq(db.char.ledger.saved, 1234); eq(db:GetCurrentProfile(), "Alt")
  eq(_G.DontDoThatDB.profileKeys[OLD], "Alt")
  cleanup()
end)

test("AceDB 40 on Forever: a fresh install loads without error", function()
  _G.DontDoThatDB = {}
  local db = login("forever")
  eq(db:GetCurrentProfile(), "Default"); eq(type(db.char.ledger), "table")
  cleanup()
end)

test("adapter: candidate keys are Name - Realm, plus Name Surname with regional names", function()
  local ns = {}
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  local A = ns.Adapter
  local function env(regional, surname)
    return { UnitName = function() return "Hero" end, GetRealmName = function() return "Realm" end,
      RegionalUniqueNamesEnabled = regional, UnitNameUnmodified = function() return "Hero", surname end }
  end
  eq(A.ReadCharKeys(env(function() return true end, "Surname")), { OLD, NEW })
  eq(A.ReadCharKeys(env(function() return false end, "Surname")), { OLD }, "regional names off")
  eq(A.ReadCharKeys(env(nil, "Surname")), { OLD }, "no RegionalUniqueNamesEnabled")
  eq(A.ReadCharKeys(env(function() return true end, nil)), { OLD }, "no surname")
  eq(A.ReadCharKeys(env(function() return true end, "")), { OLD }, "empty surname")
  eq(A.ReadCharKeys(env(function() error("x") end, "Surname")), { OLD }, "an erroring call")
  eq(A.ReadCharKeys({}), {}, "nothing readable")
end)

test("older library on Forever: data saved under Name Surname comes back, then moves forward again", function()
  _G.DontDoThatDB = savedUnderOldKey()
  local db = login("forever")
  eq(db.keys.char, NEW); eq(db.char.ledger.saved, 1234)
  logout(nil, "PLAYER_LOGOUT")
  db = login("older")
  eq(db.keys.char, OLD)
  eq(db.char.ledger.saved, 1234); eq(db.char.costCache["spell:1"], 100)
  eq(db:GetCurrentProfile(), "Alt")
  eq(_G.DontDoThatDB.char[NEW], nil); eq(_G.DontDoThatDB.profileKeys[NEW], nil)
  logout(nil, "PLAYER_LOGOUT")
  db = login("older")
  eq(db.char.ledger.saved, 1234, "a second login with the older library changes nothing")
  logout(nil, "PLAYER_LOGOUT")
  db = login("forever")
  eq(db.keys.char, NEW)
  eq(db.char.ledger.saved, 1234); eq(db:GetCurrentProfile(), "Alt")
  eq(_G.DontDoThatDB.char[OLD], nil); eq(_G.DontDoThatDB.profileKeys[OLD], nil)
  cleanup()
end)

test("older library on Forever: with data under both keys, both stay as they are", function()
  _G.DontDoThatDB = savedUnderOldKey()
  _G.DontDoThatDB.char[NEW] = { ledger = { saved = 7 } }
  local db = login("older")
  eq(db.char.ledger.saved, 1234)
  eq(_G.DontDoThatDB.char[NEW].ledger.saved, 7)
  cleanup()
end)

test("MigrateCharKeys: tries each key, tolerates a bad list", function()
  local S = settings()
  local sv = { char = { [NEW] = { ledger = { saved = 1 } } } }
  local db = fakeDb(sv, OLD)
  truthy(S.MigrateCharKeys(sv, db, { OLD, NEW }))
  eq(sv.char[OLD].ledger.saved, 1)
  falsy(S.MigrateCharKeys(sv, db, nil))
end)

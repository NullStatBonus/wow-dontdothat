local H = require("harness")

-- Runs the real bundled AceDB so the logout cleanup (which strips values equal to their defaults) is exercised.
local logout
local function loadAce()
  _G.LibStub = nil
  _G.GetRealmName = function() return "Realm" end
  _G.UnitName = function() return "Hero" end
  _G.UnitNameUnmodified = function() return "Hero" end
  _G.RegionalUniqueNamesEnabled = function() return false end
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
  return _G.LibStub("AceDB-3.0")
end

local function cleanup()
  for _, k in ipairs({ "LibStub", "GetRealmName", "UnitName", "UnitNameUnmodified", "RegionalUniqueNamesEnabled", "strlenutf8", "UnitClass", "UnitRace", "UnitFactionGroup",
      "GetLocale", "GetCurrentRegion", "GetCurrentRegionName", "CreateFrame", "DontDoThatDB" }) do _G[k] = nil end
end

local defaults = { profile = { alerts = true, alert = { banner = true, style = "toast", chat = true, cooldown = 3 } } }

-- One login as Core/Addon.lua does it: note whether saved data existed, open the db, classify. Returns ns.
local function login()
  local ns = {}
  H.load("DontDoThat/Model/Settings.lua", ns)
  local AceDB = loadAce()
  local before = ns.Settings.StyleBefore(_G.DontDoThatDB)
  ns.db = AceDB:New("DontDoThatDB", defaults, true)
  ns.Settings.ClassifyStyle(ns.db.profile, before, ns.db:GetCurrentProfile())
  return ns
end

local function relog()
  logout(nil, "PLAYER_LOGOUT")
  return login()
end

test("warning style: a fresh install gets Toast and keeps it after a relog", function()
  _G.DontDoThatDB = nil
  local ns = login()
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  ns.db.profile.alerts = false -- a changed setting makes the profile non-empty on disk
  ns = relog()
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  ns = relog()
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  cleanup()
end)

test("warning style: a profile from an older version gets Warning once; its other settings stay", function()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Default" },
    profiles = { Default = { alerts = false, alert = { banner = false } } } }
  local ns = login()
  eq(ns.Settings.WarningStyle(ns.db.profile), "warning")
  eq(ns.db.profile.alerts, false); eq(ns.db.profile.alert.banner, false)
  ns.db.profile.alert.style = "toast" -- the player picks Toast; that choice is kept
  ns = relog()
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  cleanup()
end)

test("warning style: an untouched older profile (empty on disk) still counts as existing", function()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Default" }, profiles = { Default = {} } }
  local ns = login()
  eq(ns.Settings.WarningStyle(ns.db.profile), "warning")
  cleanup()
end)

test("warning style: Reset all settings goes back to Toast and stays Toast after a relog", function()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Default" }, profiles = { Default = { alerts = false } } }
  local ns = login()
  eq(ns.Settings.WarningStyle(ns.db.profile), "warning")
  ns.Settings.ResetAll(ns.db.profile)
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  ns = relog()
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  cleanup()
end)

test("reset all: warnings work at once, AceDB still saves only changed values, and a relog reads the defaults", function()
  _G.DontDoThatDB = nil
  local full = { profile = { alerts = true, minPrice = 100, alert = { style = "toast", cooldown = 3 },
    itemModes = { armor = "both", bags = "ah" } } }
  local saved = defaults
  defaults = full
  local ns = login()
  H.load("DontDoThat/Model/ItemWarning.lua", ns)
  ns.defaults = full
  local p = ns.db.profile
  p.itemModes.armor = "off"; p.minPrice = 5000; p.professionAsked = { [2575] = true }
  ns.Settings.ResetAll(p)
  eq(p.itemModes.armor, "both"); eq(p.itemModes.bags, "ah"); eq(p.minPrice, 100); eq(p.alert.cooldown, 3)
  truthy(ns.ItemWarning.Flagged(p.itemModes, "armor", "vendor", 200, p.minPrice), "2s of armor at a vendor is warned about")
  truthy(p.styleMarked); eq(p.professionAsked, { [2575] = true })
  logout(nil, "PLAYER_LOGOUT")
  local disk = _G.DontDoThatDB.profiles.Default
  eq(disk.itemModes, nil); eq(disk.minPrice, nil)
  eq(disk.professionAsked, { [2575] = true })
  ns = login()
  eq(ns.db.profile.itemModes.armor, "both"); eq(ns.db.profile.minPrice, 100)
  defaults = saved
  cleanup()
end)

test("warning style: an invalid saved style on an old profile becomes Warning; classify is idempotent", function()
  local ns = {}
  H.load("DontDoThat/Model/Settings.lua", ns)
  local p = { alert = { style = "huge" } }
  local before = ns.Settings.StyleBefore({ profiles = { Default = { alert = { style = "huge" } } } })
  ns.Settings.ClassifyStyle(p, before, "Default")
  eq(p.alert.style, "warning"); truthy(p.styleMarked)
  p.alert.style = "toast"
  ns.Settings.ClassifyStyle(p, before, "Default")
  eq(p.alert.style, "toast")
  eq(ns.Settings.WarningStyle({ alert = { style = "huge" } }), "toast")
end)

test("warning style: the character's own profile decides, not Default", function()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Other" },
    profiles = { Default = {}, Other = { alert = { style = "toast" } } } }
  local ns = login()
  eq(ns.db:GetCurrentProfile(), "Other")
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast", "Other's saved Toast is kept")
  cleanup()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Other" },
    profiles = { Default = { alert = { style = "toast" } }, Other = { alerts = false } } }
  ns = login()
  eq(ns.Settings.WarningStyle(ns.db.profile), "warning", "old Other migrates even though Default has a style")
  cleanup()
end)

test("warning style: a profile first created in an existing database is new, so Toast", function()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Other" }, profiles = { Default = { alerts = false } } }
  local ns = login()
  eq(ns.Settings.WarningStyle(ns.db.profile), "toast")
  cleanup()
end)

test("warning style: a malformed saved alert entry loads with defaults and migrates", function()
  _G.DontDoThatDB = { profileKeys = { ["Hero - Realm"] = "Default" }, profiles = { Default = { alert = true } } }
  local ns = login()
  eq(type(ns.db.profile.alert), "table")
  eq(ns.Settings.WarningStyle(ns.db.profile), "warning")
  eq(ns.db.profile.alert.cooldown, 3, "defaults filled in")
  cleanup()
end)

local H = require("harness")

local function fresh()
  local ns = {}
  H.load("DontDoThat/Data/Sounds.lua", ns)
  H.load("DontDoThat/UI/Helpers.lua", ns)
  H.load("DontDoThat/UI/Alert.lua", ns)
  return ns
end

local defer = { tier = "defer", cost = 12345, reason = "Rank 2 in 2 levels" }

test("ShouldFire: first attempt fires, repeat within cooldown does not", function()
  local ns = fresh()
  local st = { last = {} }
  truthy(ns.Alert.ShouldFire("a", 100, 5, st))
  falsy(ns.Alert.ShouldFire("a", 103, 5, st))
  truthy(ns.Alert.ShouldFire("a", 105, 5, st))
end)

test("ShouldFire: cooldown is per action", function()
  local ns = fresh()
  local st = { last = {} }
  truthy(ns.Alert.ShouldFire("a", 100, 5, st))
  truthy(ns.Alert.ShouldFire("b", 101, 5, st))
end)

test("ShouldFire: bad input does not fire", function()
  local ns = fresh()
  falsy(ns.Alert.ShouldFire(nil, 1, 5, { last = {} }))
  falsy(ns.Alert.ShouldFire("a", nil, 5, { last = {} }))
end)

test("Trigger fires sound and banner on attempt, then cooldown suppresses", function()
  local ns = fresh()
  local plays, banners = 0, 0
  ns.Alert.PlaySound = function() plays = plays + 1 end
  ns.AlertBanner = { Show = function() banners = banners + 1 end }
  truthy(ns.Alert.Trigger(defer, "spell:1", {}, 10))
  falsy(ns.Alert.Trigger(defer, "spell:1", {}, 11))
  eq(plays, 1); eq(banners, 1)
end)

test("hover is silent: nothing fires unless Trigger is called", function()
  local ns = fresh()
  local plays, banners = 0, 0
  ns.Alert.PlaySound = function() plays = plays + 1 end
  ns.AlertBanner = { Show = function() banners = banners + 1 end }
  -- The hover path (badge/tooltip/bubble) only formats text; it never calls Trigger.
  ns.UIHelpers.TooltipText(defer)
  ns.UIHelpers.TierStyle("defer")
  eq(plays, 0); eq(banners, 0)
end)

test("Trigger ignores non-defer tiers and respects the alerts toggle", function()
  local ns = fresh()
  ns.Alert.PlaySound = function() error("should not play") end
  falsy(ns.Alert.Trigger({ tier = "info" }, "x", {}, 1))
  falsy(ns.Alert.Trigger({ tier = "keep" }, "x", {}, 1))
  falsy(ns.Alert.Trigger(defer, "x", { alertsEnabled = false }, 1))
  falsy(ns.Alert.Trigger(nil, "x", {}, 1))
end)

test("Trigger survives a failing sound or banner", function()
  local ns = fresh()
  ns.Alert.PlaySound = function() error("boom") end
  ns.AlertBanner = { Show = function() error("boom") end }
  truthy(ns.Alert.Trigger(defer, "x", {}, 1))
end)

test("Resolve: unverified entries are unresolved; constant via guarded lookup", function()
  local ns = fresh()
  eq(ns.Alert.Resolve("nope"), nil)
  eq(ns.Alert.Resolve("nope"), nil)
  eq(ns.Alert.Resolve("raidwarning"), nil) -- no SOUNDKIT outside the game
  _G.SOUNDKIT = { RAID_WARNING = 8959 }
  local kind, id = ns.Alert.Resolve("raidwarning")
  _G.SOUNDKIT = nil
  eq(kind, "soundkit"); eq(id, 8959)
end)

test("PlaySound uses Master channel and falls back to default for invalid entry", function()
  local ns = fresh()
  local calls = {}
  _G.SOUNDKIT = { RAID_WARNING = 7 }
  _G.PlaySound = function(id, ch) calls[#calls + 1] = { id, ch }; return true end
  local ok = ns.Alert.PlaySound("nope", {})
  _G.SOUNDKIT, _G.PlaySound = nil, nil
  truthy(ok)
  eq(calls[1][1], 7); eq(calls[1][2], "Master")
end)

test("PlaySound falls back when playback reports failure, and never errors", function()
  local ns = fresh()
  _G.SOUNDKIT = { RAID_WARNING = 7 }
  _G.PlaySound = function() error("bad") end
  local ok = ns.Alert.PlaySound("raidwarning", {})
  _G.SOUNDKIT, _G.PlaySound = nil, nil
  falsy(ok)
  falsy(ns.Alert.PlaySound("nope", {}))
end)

test("Trigger can play the sound without the banner", function()
  local ns = fresh()
  local plays, banners = 0, 0
  ns.Alert.PlaySound = function() plays = plays + 1 end
  ns.AlertBanner = { Show = function() banners = banners + 1 end }
  truthy(ns.Alert.Trigger(defer, "spell:2", { alertBanner = false }, 10))
  eq(plays, 1); eq(banners, 0)
  truthy(ns.Alert.Trigger(defer, "spell:3", { alertBanner = true }, 10))
  eq(banners, 1)
end)

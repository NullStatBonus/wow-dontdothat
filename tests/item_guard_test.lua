package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

-- The guard with only the files it needs, so these tests do not depend on rule data.
local function guard()
  local ns = {}
  for _, f in ipairs({ "Model/ItemCategory.lua", "Model/ItemWarning.lua", "Model/Ledger.lua", "Intercepts/Adapter.lua", "Intercepts/ItemGuard.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  local logs = {}
  ns.Log = { Add = function(fmt, ...) logs[#logs + 1] = fmt:format(...) end }
  ns.Prompt = { Say = function() end, AlertSettings = function() return {} end, SoundOnly = function(s) return s end,
    BannerInstead = function() end }
  ns.Alert = { Trigger = function() return true end }
  local shown = {}
  ns.ConfirmPopup = { Ask = function(_, yes, no, allow) shown.yes, shown.no, shown.allow = yes, no, allow; return true end }
  ns.db = { profile = { enabled = true, blockingConfirmations = true, minPrice = 100, itemModes = { armor = "both" } },
    char = { ledger = ns.Ledger.NewState() }, global = {} }
  _G.GetItemInfoInstant = function() return 1, "Armor", "Plate", "INVTYPE_CHEST", 0, 4, 4 end
  _G.GetMoney, _G.GetTime = nil, nil
  local clock, money = 100, 100000
  _G.GetTime = function() return clock end
  _G.GetMoney = function() return money end
  local env = { advance = function(dt) clock = clock + dt end, setMoney = function(m) money = m end }
  return ns, shown, logs, env
end

local function cleanup() _G.GetItemInfoInstant, _G.GetMoney, _G.GetTime = nil, nil, nil end

test("an accepted buyout counts as spent only when the money drops", function()
  local ns, shown, logs, env = guard()
  ns.ItemGuard.Run("ah", "Plate Chest", "link", 5000, function() end, false)
  shown.yes()
  eq(ns.db.char.ledger.spentAgainst, 0, "nothing counted before the money moves")
  env.setMoney(95000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 5000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 5000, "counted once")
  local found
  for _, l in ipairs(logs) do if l:find("spent 5000 counted", 1, true) then found = true end end
  truthy(found)
  cleanup()
end)

test("a purchase that fails does not count: no money drop within the window", function()
  local ns, shown, logs, env = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  shown.yes()
  env.advance(10)
  env.setMoney(1)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0)
  local found
  for _, l in ipairs(logs) do if l:find("expired", 1, true) then found = true end end
  truthy(found)
  cleanup()
end)

test("the spend counts the smaller of the price and the money drop", function()
  local ns, shown, _, env = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  shown.yes()
  env.setMoney(100000 - 9000) -- another gold loss happened at the same time
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 5000)
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  shown.yes()
  env.setMoney(91000 - 2000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 7000)
  cleanup()
end)

test("an auction bid never counts as spent", function()
  local ns, shown, logs, env = guard()
  ns.ItemGuard.Run("ah", "Plate Chest", "link", 5000, function() end, true)
  shown.yes()
  env.setMoney(95000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0)
  local found
  for _, l in ipairs(logs) do if l:find("bid of 5000 is not counted", 1, true) then found = true end end
  truthy(found)
  cleanup()
end)

test("the alert-only path also counts a real spend", function()
  local ns, _, _, env = guard()
  ns.db.profile.blockingConfirmations = false
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  env.setMoney(95000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 5000)
  cleanup()
end)

test("a dropped purchase (proceed returns false) is not noted as a spend", function()
  local ns, shown, _, env = guard()
  ns.ItemGuard.Run("ah", "Plate Chest", "link", 5000, function() return false end)
  shown.yes()
  env.setMoney(95000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0)
  cleanup()
end)

test("the blocked-action watcher also matches UNKNOWN()", function()
  local ns = guard()
  local handlers = {}
  local target = { RegisterEvent = function(_, event, fn) handlers[event] = fn end }
  ns.ItemGuard.Watch(target)
  truthy(handlers.PLAYER_MONEY)
  handlers.ADDON_ACTION_BLOCKED("ADDON_ACTION_BLOCKED", "OtherAddon", "UNKNOWN()")
  eq(ns.ItemGuard.DisabledReason(), nil)
  handlers.ADDON_ACTION_BLOCKED("ADDON_ACTION_BLOCKED", "DontDoThat", "UNKNOWN()")
  eq(ns.ItemGuard.DisabledReason(), nil, "an UNKNOWN() block outside our purchase call is not ours (a reset, beast training)")
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function()
    handlers.ADDON_ACTION_BLOCKED("ADDON_ACTION_BLOCKED", "DontDoThat", "UNKNOWN()")
  end)
  eq(ns.ItemGuard.DisabledReason(), nil, "the question is still waiting")
  ns.ItemGuard.Reset()
  ns.db.profile.blockingConfirmations = false
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function()
    handlers.ADDON_ACTION_BLOCKED("ADDON_ACTION_BLOCKED", "DontDoThat", "UNKNOWN()")
  end)
  eq(ns.ItemGuard.DisabledReason(), "blocked: UNKNOWN()")
  ns.db.profile.blockingConfirmations = true
  ns.ItemGuard.Reset()
  handlers.ADDON_ACTION_FORBIDDEN("ADDON_ACTION_FORBIDDEN", "DontDoThat", "BuyMerchantItem")
  eq(ns.ItemGuard.DisabledReason(), "blocked: BuyMerchantItem")
  ns.ItemGuard.Reset()
  handlers.ADDON_ACTION_FORBIDDEN("ADDON_ACTION_FORBIDDEN", "DontDoThat", "SomethingElse")
  eq(ns.ItemGuard.DisabledReason(), nil)
  cleanup()
end)

test("several purchases close together are all counted as the money drops", function()
  local ns, shown, logs, env = guard()
  ns.db.profile.blockingConfirmations = false
  for _ = 1, 3 do ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end) end
  env.setMoney(95000)
  ns.ItemGuard.OnMoney()
  env.setMoney(85000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 15000)
  env.setMoney(80000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 15000, "no more than the prices")
  cleanup()
end)

test("a bid's money debit does not settle an earlier purchase that failed", function()
  local ns, shown, _, env = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  shown.yes()
  ns.ItemGuard.Run("ah", "Plate Chest", "link", 5000, function() end, true)
  shown.yes()
  env.setMoney(95000) -- only the bid took gold
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0)
  cleanup()
end)

test("a purchase and a bid together count the purchase once", function()
  local ns, shown, _, env = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  shown.yes()
  ns.ItemGuard.Run("ah", "Plate Chest", "link", 3000, function() end, true)
  shown.yes()
  env.setMoney(100000 - 8000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 5000)
  cleanup()
end)

test("each pending purchase keeps its own deadline", function()
  local ns, shown, logs, env = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  shown.yes()
  env.advance(4)
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 7000, function() end)
  shown.yes()
  env.advance(2) -- the first is 6s old, the second 2s old
  env.setMoney(100000 - 7000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 7000, "the expired first purchase is not counted")
  local found
  for _, l in ipairs(logs) do if l == "items: pending spend of 5000 expired, not counted" then found = true end end
  truthy(found)
  cleanup()
end)

local CHEST = "|cffffffff|Hitem:2589::::::::20:::::|h[Zzz]|h|r"
local OTHER = "|cffffffff|Hitem:2590::::::::20:::::|h[Zzz]|h|r"

test("allowed items: add, query, remove and list by name", function()
  local ns = guard()
  falsy(ns.ItemGuard.Allowed(2589))
  truthy(ns.ItemGuard.Allow(2589, "Plate Chest", 134))
  truthy(ns.ItemGuard.Allow(10050, "Mageweave Bag", 135))
  truthy(ns.ItemGuard.Allowed(2589))
  falsy(ns.ItemGuard.Allow(nil, "No ID"), "an item without an ID is never saved")
  local list = ns.ItemGuard.AllowedList()
  eq(#list, 2)
  eq(list[1].name, "Mageweave Bag")
  eq(list[2].id, 2589)
  eq(list[2].icon, 134)
  ns.ItemGuard.Disallow(2589)
  falsy(ns.ItemGuard.Allowed(2589))
  ns.db.char = nil
  falsy(ns.ItemGuard.Allowed(10050), "no character data means nothing is allowed")
  eq(#ns.ItemGuard.AllowedList(), 0)
  cleanup()
end)

test("an allowed item is not flagged, other items of its category still are", function()
  local ns, shown, logs = guard()
  ns.ItemGuard.Allow(2589, "Plate Chest")
  local info = ns.ItemGuard.Inspect("vendor", CHEST, 5000)
  falsy(info.flagged)
  eq(info.why, "allowed")
  truthy(ns.ItemGuard.Inspect("ah", OTHER, 5000).flagged)
  local bought = false
  ns.ItemGuard.Run("ah", "Plate Chest", CHEST, 5000, function() bought = true end)
  truthy(bought, "bought without a question")
  falsy(shown.yes)
  local found
  for _, l in ipairs(logs) do if l:find("-> passed through: allowed", 1, true) then found = true end end
  truthy(found)
  cleanup()
end)

test("an allowed item gets no tooltip line", function()
  local ns = guard()
  local lines = 0
  ns.TooltipAugment = { Augment = function() lines = lines + 1 end }
  ns.ItemGuard.Tooltip({}, "vendor", "Plate Chest", CHEST, 5000)
  eq(lines, 1, "flagged before it is allowed")
  ns.ItemGuard.Allow(2589, "Plate Chest")
  ns.ItemGuard.Tooltip({}, "vendor", "Plate Chest", CHEST, 5000)
  eq(lines, 1)
  cleanup()
end)

test("Always Allow buys, saves the item and counts nothing", function()
  local ns, shown, logs, env = guard()
  local bought, rebuilt = 0, 0
  ns.Options = { Rebuild = function() rebuilt = rebuilt + 1 end }
  ns.ItemGuard.Run("vendor", "Plate Chest", CHEST, 5000, function() bought = bought + 1 end)
  truthy(shown.allow, "the question offers Always Allow")
  shown.allow()
  eq(bought, 1)
  eq(rebuilt, 1)
  truthy(ns.ItemGuard.Allowed(2589))
  env.setMoney(95000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0, "not spent against the rules")
  eq(ns.db.char.ledger.itemsAvoided or 0, 0, "not avoided")
  local found
  for _, l in ipairs(logs) do if l == "items: always allowed 2589 Plate Chest" then found = true end end
  truthy(found)
  eq(ns.db.global.itemTrace, nil, "no saved trace while recording is off")
  shown.allow = nil
  ns.ItemGuard.Run("vendor", "Plate Chest", CHEST, 5000, function() bought = bought + 1 end)
  eq(bought, 2, "the next purchase is not asked about")
  falsy(shown.allow)
  cleanup()
end)

test("an item without an ID in its link gets no Always Allow", function()
  local ns, shown = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", "link", 5000, function() end)
  truthy(shown.yes)
  falsy(shown.allow)
  cleanup()
end)

test("an allowed purchase never settles an earlier purchase that failed", function()
  local ns, shown, logs, env = guard()
  ns.ItemGuard.Run("vendor", "Plate Chest", OTHER, 5000, function() end)
  shown.yes() -- accepted, but no money leaves yet (it may have failed)
  ns.ItemGuard.Run("vendor", "Plate Chest", CHEST, 1000, function() end)
  shown.allow()
  env.setMoney(99000) -- only the allowed purchase took gold
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0)
  ns.ItemGuard.Run("vendor", "Plate Chest", OTHER, 5000, function() end)
  shown.yes()
  ns.ItemGuard.Run("vendor", "Plate Chest", CHEST, 1000, function() end) -- already allowed: no question
  env.setMoney(98000)
  ns.ItemGuard.OnMoney()
  eq(ns.db.char.ledger.spentAgainst, 0, "a repeat purchase is not counted either")
  local found
  for _, l in ipairs(logs) do if l == "items: allowed purchase of 1000 is not counted as spent" then found = true end end
  truthy(found)
  cleanup()
end)

test("Always Allow on a purchase that is dropped keeps the allow and says dropped", function()
  local ns, shown = guard()
  ns.db.profile.traceItems = true
  ns.ItemGuard.Run("ah", nil, "|cffffffff|Hitem:2589::::::::20:::::|h[Chest From Link]|h|r", 5000, function() return false end)
  shown.allow()
  truthy(ns.ItemGuard.Allowed(2589))
  eq(ns.ItemGuard.AllowedList()[1].name, "Chest From Link", "a missing name comes from the link")
  local trace = ns.db.global.itemTrace
  eq(trace[#trace].outcome, "question shown, always allowed, dropped")
  cleanup()
end)

test("no Always Allow when the character data is missing", function()
  local ns, shown = guard()
  ns.db.char = nil
  ns.ItemGuard.Run("vendor", "Plate Chest", CHEST, 5000, function() end)
  truthy(shown.yes)
  falsy(shown.allow)
  cleanup()
end)

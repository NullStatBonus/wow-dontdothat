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
  ns.ConfirmPopup = { Ask = function(_, yes, no) shown.yes, shown.no = yes, no; return true end }
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

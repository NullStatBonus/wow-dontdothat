local H = require("harness")

local function setup(env)
  local ns, seen = {}, {}
  ns.ItemGuard = {
    Trace = function() end,
    Run = function(surface, name, link, total, proceed) seen.name, seen.total = name, total; return proceed() end,
  }
  H.load("DontDoThat/Intercepts/Merchant.lua", ns)
  env.BuyMerchantItem = function() seen.bought = true end
  ns.Merchant.Install(env)
  return env, seen
end

test("vendor buy reads the row from C_MerchantFrame when the legacy call is gone", function()
  local env, seen = setup({
    GetMerchantItemLink = function() return "|Hitem:1|h[Bag]|h" end,
    C_MerchantFrame = { GetItemInfo = function() return { name = "Bag", price = 500, stackCount = 1 } end },
  })
  env.BuyMerchantItem(1, 1)
  eq(seen.name, "Bag")
  eq(seen.total, 500)
  truthy(seen.bought)
end)

test("vendor buy still reads the legacy call", function()
  local env, seen = setup({
    GetMerchantItemLink = function() return "|Hitem:1|h[Bag]|h" end,
    GetMerchantItemInfo = function() return "Bag", nil, 500, 1 end,
  })
  env.BuyMerchantItem(1, 2)
  eq(seen.total, 1000)
end)

test("legacy row: extendedCost is the 8th value, a usable item is still guarded", function()
  local env, seen = setup({
    GetMerchantItemLink = function() return "|Hitem:1|h[Bag]|h" end,
    -- name, texture, price, quantity, numAvailable, isPurchasable, isUsable, extendedCost
    GetMerchantItemInfo = function() return "Bag", nil, 500, 1, -1, true, true, nil end,
  })
  env.BuyMerchantItem(1, 1)
  eq(seen.total, 500)
end)

test("legacy row: a token item (8th value set) passes through unguarded", function()
  local env, seen = setup({
    GetMerchantItemLink = function() return "|Hitem:1|h[Bag]|h" end,
    GetMerchantItemInfo = function() return "Bag", nil, 500, 1, -1, true, false, true end,
  })
  env.BuyMerchantItem(1, 1)
  eq(seen.name, nil)
  truthy(seen.bought)
end)

test("a bundle bought with no quantity costs the whole bundle price", function()
  local env, seen = setup({
    GetMerchantItemLink = function() return "|Hitem:1|h[Arrows]|h" end,
    GetMerchantItemInfo = function() return "Arrows", nil, 100, 200 end,
  })
  env.BuyMerchantItem(1)
  eq(seen.total, 100)
  env.BuyMerchantItem(1, 50)
  eq(seen.total, 25, "a split quantity stays per unit")
end)

-- The question may stay open while the vendor's list changes.
local function vendor(rows)
  local ns = { Log = { Add = function() end } }
  local logs = {}
  ns.Log.Add = function(fmt, ...) logs[#logs + 1] = fmt:format(...) end
  local asked, bought = {}, {}
  ns.ItemGuard = { Run = function(_, name, link, total, proceed) asked.proceed = proceed; asked.name = name; asked.link = link end,
    Trace = function() end }
  H.load("DontDoThat/Intercepts/Merchant.lua", ns)
  local env = {
    BuyMerchantItem = function(i, q) bought[#bought + 1] = { i, q } end,
    GetMerchantItemInfo = function(i) local r = rows[i]; if r then return r.name, 0, r.price, 1, -1, true end end,
    GetMerchantItemLink = function(i) local r = rows[i]; return r and r.link end,
  }
  ns.Merchant.Install(env)
  return ns, env, asked, bought, logs
end

test("accepting buys the row the question named when the vendor's row is unchanged", function()
  local rows = { { name = "Plate Chest", price = 5000, link = "|Hitem:1|h[Plate Chest]|h" } }
  local _, env, asked, bought = vendor(rows)
  env.BuyMerchantItem(1, 1)
  eq(asked.name, "Plate Chest")
  asked.proceed()
  eq(bought, { { 1, 1 } })
end)

test("accepting after the vendor's list changed buys nothing and logs it", function()
  local rows = { { name = "Plate Chest", price = 5000, link = "|Hitem:1|h[Plate Chest]|h" } }
  local _, env, asked, bought, logs = vendor(rows)
  env.BuyMerchantItem(1, 1)
  rows[1] = { name = "Silk Robe", price = 5000, link = "|Hitem:2|h[Silk Robe]|h" } -- another item now at the index
  eq(asked.proceed(), false)
  eq(bought, {})
  truthy(logs[#logs]:find("changed while the question was open, purchase dropped", 1, true), logs[#logs])
end)

test("accepting after the price changed, or the vendor closed, buys nothing", function()
  local rows = { { name = "Plate Chest", price = 5000, link = "|Hitem:1|h[Plate Chest]|h" } }
  local _, env, asked, bought = vendor(rows)
  env.BuyMerchantItem(1, 1)
  rows[1].price = 9000
  eq(asked.proceed(), false)
  rows[1] = nil -- the vendor window closed
  eq(asked.proceed(), false)
  eq(bought, {})
end)

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

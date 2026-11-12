local H = require("harness")

-- Records what ItemGuard was asked and what reached the real purchase call.
local function setup(env)
  local ns, seen = {}, { runs = {}, traces = {} }
  ns.ItemGuard = {
    Trace = function(entry) seen.traces[#seen.traces + 1] = entry end,
    Run = function(surface, name, link, total, proceed)
      seen.runs[#seen.runs + 1] = { surface = surface, name = name, link = link, total = total }
      return proceed()
    end,
  }
  H.load("DontDoThat/Intercepts/Auction.lua", ns)
  ns.Auction.Reset()
  return ns, env, seen
end

test("classic: another seller's auction is asked about with the bid amount", function()
  local bid
  local ns, env, seen = setup({
    PlaceAuctionBid = function(...) bid = { ... } end,
    GetAuctionItemInfo = function() return "Plate Chest" end,
    GetAuctionItemLink = function() return "|Hitem:1|h[Plate Chest]|h" end,
  })
  truthy(ns.Auction.Install(env))
  env.PlaceAuctionBid("list", 3, 900)
  eq(seen.runs[1].name, "Plate Chest"); eq(seen.runs[1].total, 900); eq(seen.runs[1].surface, "ah")
  eq(bid, { "list", 3, 900 })
end)

test("classic: your own listings and non-number amounts go straight through, and the trace says so", function()
  local calls = 0
  local ns, env, seen = setup({
    PlaceAuctionBid = function() calls = calls + 1 end,
    GetAuctionItemInfo = function() return "x" end,
  })
  ns.Auction.Install(env)
  env.PlaceAuctionBid("owner", 1, 500)
  env.PlaceAuctionBid("list", 1, nil)
  eq(calls, 2); eq(#seen.runs, 0)
  truthy(seen.traces[1].outcome:find("list type owner", 1, true))
end)

test("classic: an unreadable auction goes through", function()
  local calls = 0
  local ns, env, seen = setup({
    PlaceAuctionBid = function() calls = calls + 1 end,
    GetAuctionItemInfo = function() return nil end,
  })
  ns.Auction.Install(env)
  env.PlaceAuctionBid("list", 1, 500)
  eq(calls, 1); eq(#seen.runs, 0)
  eq(seen.traces[1].outcome, "passed through: could not read the auction")
end)

local function modernEnv(results)
  local bought = {}
  return {
    C_AuctionHouse = {
      PlaceBid = function(...) bought.bid = { ... } end,
      GetAuctionInfoByID = function(id) return { itemLink = "|Hitem:" .. id .. "|h[Bow]|h" } end,
      ConfirmCommoditiesPurchase = function(...) bought.commodity = { ... } end,
      GetNumCommoditySearchResults = function() return #results end,
      GetCommoditySearchResultInfo = function(_, i) return results[i] end,
    },
    GetItemInfo = function() return "Linen", "|Hitem:5|h[Linen]|h" end,
  }, bought
end

test("modern: a bid is asked about by the auction's item and the amount", function()
  local env, bought = modernEnv({})
  local ns, _, seen = setup(env)
  truthy(ns.Auction.Install(env))
  env.C_AuctionHouse.PlaceBid(77, 1200)
  eq(seen.runs[1].name, "Bow"); eq(seen.runs[1].total, 1200)
  eq(bought.bid, { 77, 1200 })
end)

test("modern: a commodity purchase is totalled from the quote, across result rows", function()
  local env, bought = modernEnv({ { quantity = 3, unitPrice = 10 }, { quantity = 5, unitPrice = 20 } })
  local ns, _, seen = setup(env)
  ns.Auction.Install(env)
  env.C_AuctionHouse.ConfirmCommoditiesPurchase(5, 5)
  eq(seen.runs[1].total, 3 * 10 + 2 * 20)
  eq(bought.commodity, { 5, 5 })
end)

test("modern: a quote that cannot be totalled lets the purchase through and says why", function()
  local env, bought = modernEnv({ { unitPrice = 10 } }) -- no quantity
  local ns, _, seen = setup(env)
  ns.Auction.Install(env)
  env.C_AuctionHouse.ConfirmCommoditiesPurchase(5, 2)
  eq(#seen.runs, 0); eq(bought.commodity, { 5, 2 })
  eq(seen.traces[1].outcome, "passed through: could not total the commodity quote")
end)

test("modern: when the game replaces a wrapped function, the next AH opening wraps the new one", function()
  local env, bought = modernEnv({})
  local ns, _, seen = setup(env)
  ns.Auction.Install(env)
  local ours = env.C_AuctionHouse.PlaceBid
  env.C_AuctionHouse.PlaceBid = function(...) bought.replacement = { ... } end -- the game puts its own back
  ns.Auction.Rewrap(env)
  truthy(env.C_AuctionHouse.PlaceBid ~= ours)
  eq(ns.Auction.Status(env).modernPlaceBid, true)
  env.C_AuctionHouse.PlaceBid(77, 1200)
  eq(seen.runs[1].total, 1200); eq(bought.replacement, { 77, 1200 })
  local current = env.C_AuctionHouse.PlaceBid
  ns.Auction.Rewrap(env)
  eq(env.C_AuctionHouse.PlaceBid == current, true, "a wrapper still in place is not wrapped twice")
end)

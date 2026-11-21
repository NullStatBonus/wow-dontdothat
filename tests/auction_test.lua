local H = require("harness")

local function setup(env, runs)
  local ns = {}
  ns.ItemGuard = {
    Trace = function() end,
    Run = function(surface, name, link, total, proceed, isBid)
      runs[#runs + 1] = { name = name, link = link, total = total, isBid = isBid, proceed = proceed }
      return proceed()
    end,
  }
  H.load("DontDoThat/Intercepts/Auction.lua", ns)
  ns.Auction.Install(env)
  return ns
end

-- name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, ..., owner (14th)
local function legacy(rows)
  local env = { bought = {} }
  env.GetAuctionItemInfo = function(_, i)
    local r = rows[i]
    if not r then return nil end
    return r.name, 0, 1, 1, true, 1, "", 100, 10, r.buyout, 0, nil, nil, r.owner
  end
  env.GetAuctionItemLink = function(_, i) return rows[i] and rows[i].link end
  env.PlaceAuctionBid = function(t, i, amount) env.bought[#env.bought + 1] = { t, i, amount } end
  return env
end

test("legacy bids from the Bids tab are guarded, own auctions are not", function()
  local runs = {}
  local env = legacy({ { name = "A", link = "|Hitem:1|h[A]|h", buyout = 500, owner = "X" } })
  local ns = setup(env, runs)
  local logs = {}
  ns.Log = { Add = function(fmt, ...) logs[#logs + 1] = fmt:format(...) end }
  env.PlaceAuctionBid("bidder", 1, 500)
  eq(#runs, 1)
  eq(logs[#logs], "items: auction bidder 1 checked (500)", "the Bids tab has its own log line")
  ns.Log = nil
  env.PlaceAuctionBid("owner", 1, 500)
  eq(#runs, 1)
  env.PlaceAuctionBid("list", 1, 500)
  eq(#runs, 2)
end)

test("legacy: a buyout is not a bid, a lower amount is", function()
  local runs = {}
  local env = legacy({ { name = "A", link = "|Hitem:1|h[A]|h", buyout = 500, owner = "X" },
    { name = "B", link = "|Hitem:2|h[B]|h", buyout = 0, owner = "X" } })
  setup(env, runs)
  env.PlaceAuctionBid("list", 1, 500)
  eq(runs[1].isBid, false)
  env.PlaceAuctionBid("list", 1, 300)
  eq(runs[2].isBid, true)
  env.PlaceAuctionBid("list", 2, 300)
  eq(runs[3].isBid, true, "no buyout price: always a bid")
end)

test("legacy: accepting after the list changed drops the purchase", function()
  local rows = { { name = "A", link = "|Hitem:1|h[A]|h", buyout = 500, owner = "X" } }
  local env = legacy(rows)
  local runs = {}
  local ns = setup(env, runs)
  ns.ItemGuard.Run = function(surface, name, link, total, proceed, isBid) runs[#runs + 1] = { proceed = proceed } end
  env.PlaceAuctionBid("list", 1, 500)
  rows[1] = { name = "B", link = "|Hitem:2|h[B]|h", buyout = 500, owner = "X" } -- the list was searched again
  eq(runs[1].proceed(), false)
  eq(#env.bought, 0)
  rows[1] = { name = "A", link = "|Hitem:1|h[A]|h", buyout = 500, owner = "X" }
  runs[1].proceed()
  eq(#env.bought, 1)
end)

test("legacy: a different seller or buyout at the same index drops the purchase", function()
  local rows = { { name = "A", link = "|Hitem:1|h[A]|h", buyout = 500, owner = "X" } }
  local env = legacy(rows)
  local runs = {}
  local ns = setup(env, runs)
  ns.ItemGuard.Run = function(_, _, _, _, proceed) runs[#runs + 1] = { proceed = proceed } end
  env.PlaceAuctionBid("list", 1, 500)
  rows[1].owner = "Y"
  eq(runs[1].proceed(), false)
  rows[1].owner = "X"; rows[1].buyout = 900
  eq(runs[1].proceed(), false)
  eq(#env.bought, 0)
end)

test("legacy: a seller name that loads late does not drop the purchase", function()
  local rows = { { name = "A", link = "|Hitem:1|h[A]|h", buyout = 500, owner = nil } }
  local env = legacy(rows)
  local runs = {}
  local ns = setup(env, runs)
  ns.ItemGuard.Run = function(_, _, _, _, proceed) runs[#runs + 1] = { proceed = proceed } end
  env.PlaceAuctionBid("list", 1, 500)
  rows[1].owner = "X"
  runs[1].proceed()
  eq(#env.bought, 1)
end)

test("modern PlaceBid: accepting after the auction changed drops the purchase", function()
  local info = { itemLink = "|Hitem:1|h[A]|h", buyoutAmount = 500 }
  local placed = {}
  local env = { C_AuctionHouse = { GetAuctionInfoByID = function() return info end,
    PlaceBid = function(id, amount) placed[#placed + 1] = { id, amount } end } }
  local runs = {}
  local ns = setup(env, runs)
  ns.ItemGuard.Run = function(_, _, _, _, proceed, isBid) runs[#runs + 1] = { proceed = proceed, isBid = isBid } end
  env.C_AuctionHouse.PlaceBid(7, 500)
  eq(runs[1].isBid, false)
  env.C_AuctionHouse.PlaceBid(7, 200)
  eq(runs[2].isBid, true)
  info = { itemLink = "|Hitem:2|h[B]|h", buyoutAmount = 500 }
  eq(runs[1].proceed(), false)
  eq(#placed, 0)
  info = { itemLink = "|Hitem:1|h[A]|h", buyoutAmount = 500 }
  runs[1].proceed()
  eq(#placed, 1)
end)

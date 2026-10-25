local addonName, ns = ...

-- Auction house bids and buyouts. PlaceAuctionBid is wrapped the same way as the vendor purchase. If the
-- client refuses the addon's confirmation, ItemGuard switches the question off and purchases still go through.
-- UNVERIFIED in game on both clients; see tasks.md 1.1.
local Auction = {}
ns.Auction = Auction

local installed = false
local wrapper

function Auction.Reset() installed = false; wrapper = nil end

function Auction.Status(env)
  env = env or _G
  return {
    wrapped = installed,
    gameStillCallsOurs = installed and env.PlaceAuctionBid == wrapper or false,
    PlaceAuctionBid = type(env.PlaceAuctionBid),
    GetAuctionItemInfo = type(env.GetAuctionItemInfo),
    GetAuctionItemLink = type(env.GetAuctionItemLink),
  }
end

function Auction.Install(env)
  env = env or _G
  if installed then return true end
  local original = env.PlaceAuctionBid
  if type(original) ~= "function" or type(env.GetAuctionItemInfo) ~= "function" then
    if ns.Log then ns.Log.Add("items: auction functions missing (PlaceAuctionBid %s, GetAuctionItemInfo %s)",
      type(original), type(env.GetAuctionItemInfo)) end
    return false
  end
  wrapper = function(listType, index, amount, ...)
    -- Only other people's auctions; never the player's own listings.
    if listType ~= "list" or type(amount) ~= "number" then
      pcall(ns.ItemGuard.Trace, { surface = "ah", total = type(amount) == "number" and amount or nil,
        outcome = "passed through: list type " .. tostring(listType) .. " / amount " .. type(amount) })
      return original(listType, index, amount, ...)
    end
    local ok, name = pcall(env.GetAuctionItemInfo, listType, index)
    if not ok or not name then
      pcall(ns.ItemGuard.Trace, { surface = "ah", total = amount, outcome = "passed through: could not read the auction" })
      return original(listType, index, amount, ...)
    end
    local link = type(env.GetAuctionItemLink) == "function" and env.GetAuctionItemLink(listType, index) or nil
    local args = { ... }
    return ns.ItemGuard.Run("ah", name, link, amount,
      function() return original(listType, index, amount, unpack(args)) end)
  end
  env.PlaceAuctionBid = wrapper
  installed = true
  if ns.Log then ns.Log.Add("items: PlaceAuctionBid wrapped") end
  return true
end

function Auction.Enable(env)
  pcall(Auction.Install, env or _G)
end

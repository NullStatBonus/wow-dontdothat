local addonName, ns = ...

-- Auction house bids and buyouts. PlaceAuctionBid is wrapped the same way as the vendor purchase. If the
-- client refuses the addon's confirmation, ItemGuard switches the question off and purchases still go through.
-- UNVERIFIED in game on both clients; see tasks.md 1.1.
local Auction = {}
ns.Auction = Auction

local installed = false
local wrapper
local modern = {} -- C_AuctionHouse wrappers, keyed by function name

function Auction.Reset() installed = false; wrapper = nil; modern = {} end

function Auction.Status(env)
  env = env or _G
  return {
    wrapped = installed,
    gameStillCallsOurs = installed and env.PlaceAuctionBid == wrapper or false,
    PlaceAuctionBid = type(env.PlaceAuctionBid),
    GetAuctionItemInfo = type(env.GetAuctionItemInfo),
    GetAuctionItemLink = type(env.GetAuctionItemLink),
    modernPlaceBid = modern.PlaceBid ~= nil and env.C_AuctionHouse.PlaceBid == modern.PlaceBid or false,
    modernConfirmCommoditiesPurchase = modern.ConfirmCommoditiesPurchase ~= nil
      and env.C_AuctionHouse.ConfirmCommoditiesPurchase == modern.ConfirmCommoditiesPurchase or false,
  }
end

-- Forever has only the retail-style C_AuctionHouse API. Items: PlaceBid(auctionID, amount). Commodities:
-- ConfirmCommoditiesPurchase(itemID, quantity) after a quote, so the total is summed from the quoted results.
-- Only used when the legacy PlaceAuctionBid is absent; the Classic path is untouched.
-- An amount below the buyout price (or an auction with no buyout) is a bid, not a purchase.
local function isBid(amount, buyout)
  return not (type(buyout) == "number" and buyout > 0 and amount >= buyout)
end

local function nameOf(link) return type(link) == "string" and link:match("%[(.-)%]") or nil end

local function installModern(env)
  local api = env.C_AuctionHouse
  if type(api) ~= "table" then return false end
  if modern.PlaceBid or modern.ConfirmCommoditiesPurchase then return true end
  local bid, confirm = api.PlaceBid, api.ConfirmCommoditiesPurchase
  if type(bid) == "function" and type(api.GetAuctionInfoByID) == "function" then
    modern.PlaceBid = function(auctionID, amount, ...)
      local ok, info = pcall(api.GetAuctionInfoByID, auctionID)
      local link = ok and type(info) == "table" and info.itemLink or nil
      local buyout = ok and type(info) == "table" and info.buyoutAmount or nil
      if not link or type(amount) ~= "number" then
        pcall(ns.ItemGuard.Trace, { surface = "ah", total = type(amount) == "number" and amount or nil,
          outcome = "passed through: could not read the auction" })
        return bid(auctionID, amount, ...)
      end
      local args = { ... }
      return ns.ItemGuard.Run("ah", nameOf(link), link, amount, function()
        -- The question may have stayed open while the auction changed hands or sold.
        local okNow, now = pcall(api.GetAuctionInfoByID, auctionID)
        if not okNow or type(now) ~= "table" or now.itemLink ~= link or now.buyoutAmount ~= buyout then
          if ns.Log then ns.Log.Add("items: auction %s changed while the question was open, purchase dropped", tostring(auctionID)) end
          return false
        end
        return bid(auctionID, amount, unpack(args))
      end, isBid(amount, buyout))
    end
    api.PlaceBid = modern.PlaceBid
  end
  if type(confirm) == "function" and type(api.GetNumCommoditySearchResults) == "function"
      and type(api.GetCommoditySearchResultInfo) == "function" then
    modern.ConfirmCommoditiesPurchase = function(itemID, quantity, ...)
      local total, left = 0, tonumber(quantity) or 0
      local ok = pcall(function()
        for i = 1, api.GetNumCommoditySearchResults(itemID) do
          if left <= 0 then break end
          local r = api.GetCommoditySearchResultInfo(itemID, i)
          local take = math.min(left, r.quantity)
          total = total + take * r.unitPrice
          left = left - take
        end
      end)
      local name, link
      if type(env.GetItemInfo) == "function" then name, link = env.GetItemInfo(itemID) end
      link = link or ("|Hitem:%d|h[%s]|h"):format(itemID, tostring(name))
      if not ok or total == 0 then
        pcall(ns.ItemGuard.Trace, { surface = "ah", name = name, outcome = "passed through: could not total the commodity quote" })
        return confirm(itemID, quantity, ...)
      end
      local args = { ... }
      return ns.ItemGuard.Run("ah", name, link, total,
        function() return confirm(itemID, quantity, unpack(args)) end)
    end
    api.ConfirmCommoditiesPurchase = modern.ConfirmCommoditiesPurchase
  end
  if modern.PlaceBid or modern.ConfirmCommoditiesPurchase then
    if ns.Log then ns.Log.Add("items: C_AuctionHouse purchases wrapped") end
    return true
  end
  return false
end

-- ok, name, buyoutPrice, owner from GetAuctionItemInfo (returns: name, texture, count, quality, canUse, level,
-- levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ...).
local function readRow(env, listType, index)
  local r = { pcall(env.GetAuctionItemInfo, listType, index) }
  return r[1], r[2], r[11], r[15]
end

function Auction.Install(env)
  env = env or _G
  if installed then return true end
  if type(env.PlaceAuctionBid) ~= "function" and installModern(env) then installed = true; return true end
  local original = env.PlaceAuctionBid
  if type(original) ~= "function" or type(env.GetAuctionItemInfo) ~= "function" then
    if ns.Log then ns.Log.Add("items: auction functions missing (PlaceAuctionBid %s, GetAuctionItemInfo %s)",
      type(original), type(env.GetAuctionItemInfo)) end
    return false
  end
  wrapper = function(listType, index, amount, ...)
    -- Only other people's auctions; never the player's own listings.
    -- "bidder" is the Bids tab, where a buyout of an auction already bid on is placed.
    if (listType ~= "list" and listType ~= "bidder") or type(amount) ~= "number" then
      pcall(ns.ItemGuard.Trace, { surface = "ah", total = type(amount) == "number" and amount or nil,
        outcome = "passed through: list type " .. tostring(listType) .. " / amount " .. type(amount) })
      return original(listType, index, amount, ...)
    end
    local ok, name, buyout, owner = readRow(env, listType, index)
    if not ok or not name then
      pcall(ns.ItemGuard.Trace, { surface = "ah", total = amount, outcome = "passed through: could not read the auction" })
      return original(listType, index, amount, ...)
    end
    local link = type(env.GetAuctionItemLink) == "function" and env.GetAuctionItemLink(listType, index) or nil
    if ns.Log then ns.Log.Add("items: auction %s %s checked (%s)", listType, tostring(index), tostring(amount)) end
    local args = { ... }
    return ns.ItemGuard.Run("ah", name, link, amount, function()
      -- The list may have changed (new search, sort, page) while the question was open; the index would then
      -- name another auction.
      local okNow, nowName, nowBuyout, nowOwner = readRow(env, listType, index)
      local nowLink = type(env.GetAuctionItemLink) == "function" and env.GetAuctionItemLink(listType, index) or nil
      if not okNow or nowName ~= name or nowLink ~= link or nowBuyout ~= buyout
        or (owner ~= nil and nowOwner ~= nil and nowOwner ~= owner) then -- a seller name can load late
        if ns.Log then ns.Log.Add("items: auction %s %s changed while the question was open, purchase dropped",
          tostring(listType), tostring(index)) end
        return false
      end
      return original(listType, index, amount, unpack(args))
    end, isBid(amount, buyout))
  end
  env.PlaceAuctionBid = wrapper
  installed = true
  if ns.Log then ns.Log.Add("items: PlaceAuctionBid wrapped") end
  return true
end

function Auction.Enable(env)
  pcall(Auction.Install, env or _G)
end

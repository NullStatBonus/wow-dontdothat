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
    modernPlaceBidWrittenBy = type(env.issecurevariable) == "function" and type(env.C_AuctionHouse) == "table"
      and select(2, env.issecurevariable(env.C_AuctionHouse, "PlaceBid")) or nil,
    modernPlaceBidMade = modern.PlaceBid ~= nil, -- false: never wrapped; true with modernPlaceBid false: the game replaced it
    modernConfirmCommoditiesPurchase = modern.ConfirmCommoditiesPurchase ~= nil
      and env.C_AuctionHouse.ConfirmCommoditiesPurchase == modern.ConfirmCommoditiesPurchase or false,
  }
end

-- Forever has only the retail-style C_AuctionHouse API. Items: PlaceBid(auctionID, amount). Commodities:
-- ConfirmCommoditiesPurchase(itemID, quantity) after a quote, so the total is summed from the quoted results.
-- Only used when the legacy PlaceAuctionBid is absent; the Classic path is untouched.
local function nameOf(link) return type(link) == "string" and link:match("%[(.-)%]") or nil end

local function installModern(env)
  local api = env.C_AuctionHouse
  if type(api) ~= "table" then return false end
  local bid, confirm = api.PlaceBid, api.ConfirmCommoditiesPurchase
  -- Called again when the AH opens: if the game put its own function back, wrap that one. Ours is left alone.
  if bid == modern.PlaceBid then bid = nil end
  if confirm == modern.ConfirmCommoditiesPurchase then confirm = nil end
  local wrapped = bid ~= nil or confirm ~= nil
  if type(bid) == "function" and type(api.GetAuctionInfoByID) == "function" then
    modern.PlaceBid = function(auctionID, amount, ...)
      local ok, info = pcall(api.GetAuctionInfoByID, auctionID)
      local link = ok and type(info) == "table" and info.itemLink or nil
      if not link or type(amount) ~= "number" then
        pcall(ns.ItemGuard.Trace, { surface = "ah", total = type(amount) == "number" and amount or nil,
          outcome = "passed through: could not read the auction" })
        return bid(auctionID, amount, ...)
      end
      local args = { ... }
      return ns.ItemGuard.Run("ah", nameOf(link), link, amount,
        function() return bid(auctionID, amount, unpack(args)) end)
    end
    api.PlaceBid = modern.PlaceBid
    if ns.Log then
      local secure, by
      if type(env.issecurevariable) == "function" then secure, by = env.issecurevariable(api, "PlaceBid") end
      ns.Log.Add("items: C_AuctionHouse.PlaceBid written, reads back %s, secure=%s, last written by %s",
        api.PlaceBid == modern.PlaceBid and "as ours" or "DIFFERENT", tostring(secure), tostring(by))
    end
  end
  if not modern.PlaceBid and ns.Log then
    ns.Log.Add("items: C_AuctionHouse.PlaceBid not wrapped (PlaceBid %s, GetAuctionInfoByID %s)",
      type(bid), type(api.GetAuctionInfoByID))
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
    if wrapped and ns.Log then ns.Log.Add("items: C_AuctionHouse purchases wrapped") end
    return true
  end
  return false
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

-- The game can replace C_AuctionHouse functions after login (the AH window loads later), which silently drops ours.
function Auction.Rewrap(env)
  env = env or _G
  if installed and (modern.PlaceBid or modern.ConfirmCommoditiesPurchase) then pcall(installModern, env) end
end

-- eventTarget (optional): a dedicated AceEvent object, so the AH opening can re-check the wrappers.
function Auction.Enable(env, eventTarget)
  env = env or _G
  pcall(Auction.Install, env)
  if eventTarget then
    pcall(eventTarget.RegisterEvent, eventTarget, "AUCTION_HOUSE_SHOW", function() Auction.Rewrap(env) end)
  end
end

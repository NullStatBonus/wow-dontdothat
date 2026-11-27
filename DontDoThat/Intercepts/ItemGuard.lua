local addonName, ns = ...
local L = ns.L

-- The shared flow for vendor and auction purchases: classify the item, decide if it is flagged, then alert,
-- ask, and either run `proceed` (the real purchase) or drop it. Anything unexpected lets the purchase through,
-- so the player is never stopped from buying by a fault in here. If the client reports a forbidden action,
-- the question switches off for the session and purchases go ahead with the warning sound and banner only.
local Guard = {}
ns.ItemGuard = Guard

local disabledReason
local pending -- purchases waiting for the money drop: { amount, before, counted, expires }
local bidDebit, lastMoney -- see NoteSpend
local buying = false -- true while our purchase call runs, so a blocked "UNKNOWN()" call is known to be ours
local trace -- defined below

function Guard.Reset() disabledReason = nil; pending = nil; bidDebit = nil; lastMoney = nil end
function Guard.DisabledReason() return disabledReason end

function Guard.Disable(reason)
  if disabledReason then return end
  disabledReason = reason
  pcall(trace, { surface = "-", outcome = "prompts switched off: " .. tostring(reason) })
  if ns.Log then ns.Log.Add("items: prompts switched off for the session (%s)", tostring(reason)) end
  ns.Prompt.Say(L["Don't Do That: this game version won't let it confirm item purchases, so it will only warn you."])
end

-- The client may name a wrapped call "UNKNOWN()" instead of the function.
local BLOCKED_NAMES = { BuyMerchantItem = true, PlaceAuctionBid = true, UNKNOWN = true }

function Guard.Watch(eventTarget)
  for _, event in ipairs({ "ADDON_ACTION_FORBIDDEN", "ADDON_ACTION_BLOCKED" }) do
    pcall(eventTarget.RegisterEvent, eventTarget, event, function(_, who, func)
      local name = type(func) == "string" and func:gsub("%(%)$", "")
      if who == addonName and BLOCKED_NAMES[name] and (name ~= "UNKNOWN" or buying) then
        Guard.Disable("blocked: " .. tostring(func))
      end
    end)
  end
  pcall(eventTarget.RegisterEvent, eventTarget, "PLAYER_MONEY", function() Guard.OnMoney() end)
end

local function profile() return (ns.db and ns.db.profile) or {} end

local function ledgerState() return ns.db and ns.db.char and ns.db.char.ledger end

-- Real spend: a purchase is counted as spent only when the player's money drops soon after it runs, and by no
-- more than its price. A bid never counts, because the gold comes back when someone outbids it.
local SPEND_WINDOW = 5
local function now() return ns.Adapter.ReadTime() or 0 end

local function money() return ns.Adapter.ReadMoney() end

-- Each purchase waits in its own entry with its own deadline. The money level last seen is the baseline for the
-- next drop. A known bid raises a debit allowance that is taken off a drop before purchases settle, so the
-- gold a bid takes never settles an earlier purchase that failed.
-- label names an uncounted debit in the log ("bid" by default; "allowed purchase" for an Always Allow item).
function Guard.NoteSpend(amount, isBid, before, label)
  if type(amount) ~= "number" then return end
  label = label or "bid"
  if not before then
    if isBid and ns.Log then ns.Log.Add("items: %s of %s is not counted as spent", label, tostring(amount)) end
    return
  end
  if not pending then pending = {} end
  if #pending == 0 and not (bidDebit and bidDebit.amount > 0) then lastMoney = before end
  if isBid then
    bidDebit = { amount = (bidDebit and bidDebit.amount or 0) + amount, expires = now() + SPEND_WINDOW }
    if ns.Log then ns.Log.Add("items: %s of %s is not counted as spent", label, tostring(amount)) end
    return
  end
  pending[#pending + 1] = { amount = amount, before = before, counted = 0, expires = now() + SPEND_WINDOW }
  if ns.Log then ns.Log.Add("items: spend of %d pending (money %d)", amount, before) end
end

function Guard.OnMoney()
  local current = money()
  local list = pending or {}
  local t = now()
  local kept = {}
  for _, e in ipairs(list) do
    if t > e.expires then
      if ns.Log then ns.Log.Add("items: pending spend of %d expired, not counted", e.amount) end
    else
      kept[#kept + 1] = e
    end
  end
  pending = kept
  if bidDebit and t > bidDebit.expires then bidDebit = nil end
  local previous = lastMoney
  lastMoney = current
  if not current or not previous then return end
  local drop = math.max(previous - current, 0)
  if bidDebit then
    local taken = math.min(drop, bidDebit.amount)
    drop = drop - taken
    bidDebit.amount = bidDebit.amount - taken
    if bidDebit.amount <= 0 then bidDebit = nil end
  end
  local available, remaining = drop, {}
  for _, e in ipairs(pending) do
    local spent = math.min(available, e.amount - e.counted)
    if spent > 0 then
      available = available - spent
      e.counted = e.counted + spent
      local state = ledgerState()
      if state then ns.Ledger.RecordItemPerformed(state, spent) end
      if ns.Log then ns.Log.Add("items: spent %d counted (money dropped %d, price %d)", spent, drop, e.amount) end
    end
    if e.counted < e.amount then remaining[#remaining + 1] = e end
  end
  pending = remaining
end

-- Runs the purchase, then notes it as a pending spend unless it was dropped (proceed returned false).
local function guarded(proceed)
  buying = true
  local ok, result = pcall(proceed)
  buying = false
  if not ok then error(result, 0) end
  return result
end

local function purchase(proceed, total, isBid)
  local before = money()
  local result = guarded(proceed)
  if result ~= false then Guard.NoteSpend(total, isBid, before) end
  return result
end

-- An allowed item's purchase: its money drop is taken off like a bid's, so it never settles an earlier purchase.
local function uncounted(proceed, total)
  local before = money()
  local result = guarded(proceed)
  if result ~= false then Guard.NoteSpend(total, true, before, "allowed purchase") end
  return result
end

local TRACE_MAX = 40

-- A saved record of every guarded purchase and what was decided, so a later /ddt export shows what happened.
-- Only kept when the "Record item purchases" setting is on. Newest last.
trace = function(entry)
  entry.t = type(_G.time) == "function" and _G.time() or nil
  local store = ns.db and ns.db.global
  if store and profile().traceItems then
    store.itemTrace = store.itemTrace or {}
    table.insert(store.itemTrace, entry)
    while #store.itemTrace > TRACE_MAX do table.remove(store.itemTrace, 1) end
  end
  if ns.Log then
    ns.Log.Add("items: %s %s total=%s category=%s -> %s", tostring(entry.surface), tostring(entry.name),
      tostring(entry.total), tostring(entry.category), tostring(entry.outcome))
  end
  return entry
end
Guard.Trace = trace

-- Items the player chose Always Allow for on this character: item ID -> { name = ..., icon = ... }. Name and icon
-- are saved with the ID so the settings list and the report never wait for the item cache.
local function allowedItems(create)
  local c = ns.db and ns.db.char
  if not c then return nil end
  if create and type(c.allowedItems) ~= "table" then c.allowedItems = {} end
  return type(c.allowedItems) == "table" and c.allowedItems or nil
end

function Guard.Allowed(id)
  local list = allowedItems()
  return id ~= nil and list ~= nil and list[id] ~= nil
end

function Guard.Allow(id, name, icon)
  local list = type(id) == "number" and allowedItems(true)
  if not list then return false end
  list[id] = { name = name, icon = icon }
  return true
end

function Guard.Disallow(id)
  local list = allowedItems()
  if list then list[id] = nil end
end

-- The allowed items, sorted by name: { { id = ..., name = ..., icon = ... }, ... }.
function Guard.AllowedList()
  local out = {}
  for id, e in pairs(allowedItems() or {}) do
    out[#out + 1] = { id = id, name = type(e) == "table" and e.name or tostring(id), icon = type(e) == "table" and e.icon or nil }
  end
  table.sort(out, function(a, b)
    if a.name ~= b.name then return tostring(a.name) < tostring(b.name) end
    return a.id < b.id
  end)
  return out
end

-- For /ddt export: "<item ID> <name>" per allowed item, or "none".
function Guard.AllowedReport()
  local lines = {}
  for _, e in ipairs(Guard.AllowedList()) do lines[#lines + 1] = ("%d %s"):format(e.id, tostring(e.name)) end
  return #lines > 0 and lines or "none"
end

-- Items some classes are warned about by family: a Warlock's demon grimoires, for example. The class's rule data
-- lists the item families to keep; every other grimoire is flagged at a vendor. An item is recognised by the item
-- ID in its link ("|Hitem:1224:..."), which Data/RuleItems.lua maps to a family, so the item's name never matters.
local function itemId(link)
  return type(link) == "string" and tonumber(link:match("|Hitem:(%d+)")) or nil
end

local function classGrimoires()
  local player = ns.Adapter and ns.Adapter.ReadPlayer and ns.Adapter.ReadPlayer(_G)
  local data = player and player.class and ns.Rules and ns.Rules.GetClass(player.class)
  return data and data.grimoires
end

-- The grimoire family named by the link, when this class flags grimoires and this one is not kept.
local function flaggedGrimoire(link)
  local rule = classGrimoires()
  local id = rule and itemId(link)
  local player = rule and ns.Adapter.ReadPlayer(_G)
  local family = id and player and ns.RuleItems and ns.RuleItems[player.class] and ns.RuleItems[player.class][id]
  if not family then return nil end
  for _, kept in ipairs(rule.keep or {}) do
    if kept == family then return nil end
  end
  return family, rule.reason
end

-- The Forever client moved GetItemInfoInstant into C_Item; both return the same values.
local function instantInfo(env)
  if type(env.GetItemInfoInstant) == "function" then return env.GetItemInfoInstant end
  local c = env.C_Item
  if type(c) == "table" and type(c.GetItemInfoInstant) == "function" then return c.GetItemInfoInstant end
end

-- Everything known about one purchase: its item numbers, category, mode, and whether it is flagged (and if
-- not, why not).
function Guard.Inspect(surface, link, total)
  local p = profile()
  local info = { surface = surface, total = total, minPrice = p.minPrice }
  if p.enabled == false then info.why = "addon off"; return info end
  if p.watch and p.watch.shopping == false then info.why = "Shopping is off"; return info end
  if ns.Context and not ns.Context.Saving(_G) then info.why = "mount bought"; return info end
  info.itemId = itemId(link)
  if Guard.Allowed(info.itemId) then info.why = "allowed"; return info end
  if surface == "vendor" then
    local family, reason = flaggedGrimoire(link)
    if family then
      info.category, info.reason, info.mode = "grimoires", reason, L["class rule"]
      if total >= (p.minPrice or 0) then info.flagged = true else info.why = "below minimum price" end
      return info
    end
  end
  local instant = instantInfo(_G)
  if not instant or not link then info.why = "no item info"; return info end
  local _, _, _, equipLoc, icon, classID, subClassID = instant(link)
  if not classID then info.why = "item not cached"; return info end
  info.classID, info.subClassID, info.equipLoc, info.icon = classID, subClassID, equipLoc, icon
  info.category = ns.ItemCategory.Classify({ classID = classID, subClassID = subClassID, equipLoc = equipLoc })
  info.mode = p.itemModes and p.itemModes[info.category] or "off"
  if ns.ItemWarning.Flagged(p.itemModes, info.category, surface, total, p.minPrice) then
    info.flagged = true
  elseif total < (p.minPrice or 0) then
    info.why = "below minimum price"
  else
    info.why = "mode " .. info.mode .. " does not cover " .. surface
  end
  return info
end

-- The category when this purchase should be warned about, else nil.
function Guard.Flag(surface, link, total)
  local info = Guard.Inspect(surface, link, total)
  return info.flagged and info.category or nil
end

local function record(info, name, outcome)
  return trace({ surface = info.surface, name = name, total = info.total, classID = info.classID,
    subClassID = info.subClassID, equipLoc = info.equipLoc, category = info.category, mode = info.mode,
    minPrice = info.minPrice, why = info.why, outcome = outcome })
end

-- surface: "vendor" | "ah". name: item name. link: item link. total: copper. proceed(): the real purchase; it
-- returns false when it dropped the purchase. isBid: an auction bid below the buyout, never counted as spent.
function Guard.Run(surface, name, link, total, proceed, isBid)
  local okInfo, info = pcall(Guard.Inspect, surface, link, total)
  if not okInfo then
    trace({ surface = surface, name = name, total = total, outcome = "passed through: decision failed: " .. tostring(info) })
    return guarded(proceed)
  end
  if not info.flagged then
    record(info, name, "passed through: " .. tostring(info.why))
    if info.why == "allowed" then return uncounted(proceed, total) end
    return guarded(proceed)
  end

  local category = info.category
  local verdict = { tier = "defer", name = name or L["This item"], cost = total,
    reason = info.reason or ns.ItemWarning.Reason(category), icon = info.icon }
  local key = surface .. ":" .. tostring(name)
  local settings = ns.Prompt.AlertSettings()
  local asking = not disabledReason and profile().blockingConfirmations ~= false
  local entry = record(info, name, "flagged")

  if not asking then
    local fired = false
    pcall(function() fired = ns.Alert.Trigger(verdict, key, settings) end)
    entry.outcome = "alert only (" .. (disabledReason and ("prompts off: " .. tostring(disabledReason)) or "Ask before buying is off")
      .. "), alert " .. (fired and "played" or "not played") .. ", bought"
    return purchase(proceed, total, isBid)
  end

  -- The question says everything the banner would, so it gets the sound alone.
  pcall(ns.Alert.Trigger, verdict, key, ns.Prompt.SoundOnly(settings))

  local shown = false
  pcall(function()
    shown = ns.ConfirmPopup.Ask(verdict,
      function()
        entry.outcome = "question shown, accepted, bought"
        purchase(proceed, total, isBid)
      end,
      function()
        entry.outcome = "question shown, declined, not bought"
        local state = ledgerState()
        if state then ns.Ledger.RecordItemAvoided(state, total) end
      end,
      -- Always Allow: saved before the purchase runs, and never counted as spent or avoided.
      info.itemId and allowedItems(true) and function()
        local label = name or (type(link) == "string" and link:match("%[(.-)%]")) or nil
        local icon = info.icon
        local instant = not icon and link and instantInfo(_G)
        if instant then
          local ok, _, _, _, _, found = pcall(instant, link)
          icon = ok and found or nil
        end
        if Guard.Allow(info.itemId, label, icon) and ns.Log then
          ns.Log.Add("items: always allowed %s %s", tostring(info.itemId), tostring(label))
        end
        local result = uncounted(proceed, total)
        entry.outcome = "question shown, always allowed, " .. (result == false and "dropped" or "bought")
        if ns.Options and ns.Options.Rebuild then pcall(ns.Options.Rebuild) end
      end or nil)
  end)
  if shown then
    entry.outcome = "question shown, waiting for an answer"
    return
  end
  entry.outcome = "question could not be shown, bought with banner"
  ns.Prompt.BannerInstead(settings, verdict, verdict.name)
  return purchase(proceed, total, isBid)
end

-- What /ddt export shows for item warnings.
function Guard.Report(env)
  env = env or _G
  local p = profile()
  local rate = ns.EarnBack and type(env.UnitLevel) == "function" and ns.EarnBack.Rate(env.UnitLevel("player"))
  local buildInfo = type(env.GetBuildInfo) == "function" and { env.GetBuildInfo() } or {}
  local report = {
    client = ("%s (build %s, interface %s)"):format(tostring(buildInfo[1]), tostring(buildInfo[2]), tostring(buildInfo[4])),
    promptsSwitchedOffBy = disabledReason or "no",
    GetItemInfoInstant = instantInfo(env) and "available" or "MISSING",
    vendor = ns.Merchant and ns.Merchant.Status(env) or "module missing",
    auction = ns.Auction and ns.Auction.Status(env) or "module missing",
    guardedDialogs = ns.Resets and ns.Resets.Status() or "module missing",
    minPrice = ns.UIHelpers.FormatMoney(p.minPrice or 0),
    modes = p.itemModes,
    allowedItems = Guard.AllowedReport(),
    earnBackRateCopperPerHour = rate or "unknown",
    recentPurchases = (ns.db and ns.db.global and ns.db.global.itemTrace) or {},
  }
  return report
end

-- A tooltip line for a flagged item, used where a prompt is not possible and as a heads-up beforehand.
function Guard.Tooltip(tooltip, surface, name, link, total)
  if profile().warnings == false then return end
  local ok, info = pcall(Guard.Inspect, surface, link, total)
  if not ok or not info.flagged then return end
  ns.TooltipAugment.Augment(tooltip, { tier = "defer", name = name, cost = total,
    reason = info.reason or ns.ItemWarning.Reason(info.category) })
end

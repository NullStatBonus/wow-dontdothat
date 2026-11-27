local addonName, ns = ...
local L = ns.L

local Popup = {}
ns.ConfirmPopup = Popup

local KEY = "DONTDOTHAT_CONFIRM"
-- The item question adds a third button, Always Allow. It has its own dialog entry, so the trainer and reset
-- questions never show a third button left over from an item question.
local ITEM_KEY = "DONTDOTHAT_CONFIRM_ITEM"

-- Each prompt carries its own callbacks in the dialog's data, so another prompt, a re-used dialog, or the
-- game hiding it cannot clear them. `current` is only a fallback for a handler called without data.
local current

local function say(message)
  if _G.DEFAULT_CHAT_FRAME and _G.DEFAULT_CHAT_FRAME.AddMessage then
    pcall(_G.DEFAULT_CHAT_FRAME.AddMessage, _G.DEFAULT_CHAT_FRAME, "|cffff3333" .. L["Don't Do That:"] .. "|r " .. message)
  end
end

-- kind is "accept", "allow" or "cancel". Runs the matching callback once; a later answer for the same prompt is ignored.
local function answer(kind, data)
  data = data or current
  if type(data) ~= "table" or data.answered then return end
  data.answered = true
  if current == data then current = nil end
  if ns.Log then ns.Log.Add("popup: %s", kind) end
  local fn = (kind == "accept" and data.onConfirm) or (kind == "allow" and data.onAllow) or (kind == "cancel" and data.onCancel)
  if not fn then return end
  local ok, err = pcall(fn)
  if not ok then
    if ns.Log then ns.Log.Add("popup: the %s step failed: %s", kind, tostring(err)) end
    say(L["that didn't work (%s)."]:format(tostring(err)))
  end
end

local function register(key)
  if type(_G.StaticPopupDialogs) ~= "table" then return false end
  if _G.StaticPopupDialogs[key] then return true end
  local dialog = {
    text = "%s",
    button1 = _G.ACCEPT or L["Accept"],
    button2 = _G.CANCEL or L["Cancel"],
    -- Called as (dialog, data, ...). Returning nothing lets the game close the dialog.
    OnAccept = function(_, data) answer("accept", data) end,
    OnCancel = function(_, data)
      if type(data) == "table" and not data.shown then return end
      answer("cancel", data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    -- Addon dialogs use the last slot, so they never take over a slot the game's own dialogs rely on.
    preferredIndex = 3,
  }
  if key == ITEM_KEY then
    dialog.button3 = L["Always Allow"]
    -- Called as (dialog, data, "clicked") for the third button, on Era and Forever alike.
    dialog.OnAlt = function(_, data) answer("allow", data) end
  end
  _G.StaticPopupDialogs[key] = dialog
  return true
end

-- Shows an Accept / Cancel dialog with this text, or Accept / Always Allow / Cancel when onAllow is given. Returns
-- true if it was shown, false when it cannot be, so the caller can degrade (a banner, or leaving the game's own
-- dialog alone).
function Popup.Show(text, onConfirm, onCancel, onAllow)
  local key = onAllow and ITEM_KEY or KEY
  if type(_G.StaticPopup_Show) ~= "function" or not register(key) then return false end
  -- A previous unanswered prompt counts as cancelled. One under the other key is also hidden: the game reuses a
  -- shown frame only for the same key, so it would stay on screen with buttons that do nothing.
  local previous = current
  if previous then
    answer("cancel", previous)
    if previous.key ~= key and type(_G.StaticPopup_Hide) == "function" then pcall(_G.StaticPopup_Hide, previous.key) end
  end
  -- `shown` stays false until the game returns a dialog: Era calls OnCancel itself when it has no free slot,
  -- and that is not the player declining.
  local data = { onConfirm = onConfirm, onCancel = onCancel, onAllow = onAllow, key = key }
  current = data
  local ok, dialog = pcall(_G.StaticPopup_Show, key, text, nil, data)
  if not ok or not dialog then
    -- The game may have called OnCancel itself when it could not show the dialog; either way this
    -- prompt is over and the caller decides what happens next.
    data.answered = true
    if current == data then current = nil end
    if ns.Log then ns.Log.Add("popup: could not be shown") end
    return false
  end
  data.shown = true
  if ns.Log then ns.Log.Add("popup: shown") end
  return true
end

-- Closes the question on screen, counted as the player declining it. Used before the profile changes, so no answer
-- reaches a purchase decided under other settings.
function Popup.Close()
  local previous = current
  if not previous then return false end
  answer("cancel", previous)
  if type(_G.StaticPopup_Hide) == "function" then pcall(_G.StaticPopup_Hide, previous.key) end
  return true
end

-- "After this you'll have 61g of the 100g for your level 40 mount.", or nil when the player still has enough
-- after paying, or when the price, gold or goal is unknown.
function Popup.FundLine(cost, env)
  env = env or _G
  if type(cost) ~= "number" or cost <= 0 or not ns.Milestones or type(env.GetMoney) ~= "function" then return nil end
  local ok, level, goal = pcall(ns.Milestones.Target, env)
  if not (ok and level) then return nil end
  local okMoney, have = pcall(env.GetMoney)
  if not okMoney or type(have) ~= "number" then return nil end
  local left = math.max(have - cost, 0)
  if left >= goal then return nil end
  local money = ns.UIHelpers.FormatMoney
  return L["After this you'll have %s of the %s for your level %d mount."]:format(money(left), money(goal), level)
end

-- The "Buy anyway?" question for a flagged purchase. onAllow, when given, adds the Always Allow button.
function Popup.Ask(verdict, onConfirm, onCancel, onAllow)
  local head = ns.UIHelpers.BannerText(verdict)
  local reason = verdict and verdict.reason or ""
  local cost = verdict and verdict.cost
  local earn = ns.EarnBack and ns.EarnBack.Line(cost)
  local okFund, fund = pcall(Popup.FundLine, cost)
  fund = okFund and fund or nil
  return Popup.Show(head .. "\n\n" .. tostring(reason) .. (earn and ("\n\n" .. earn) or "") .. (fund and ("\n\n" .. fund) or "")
    .. "\n\n" .. L["Buy anyway?"], onConfirm, onCancel, onAllow)
end

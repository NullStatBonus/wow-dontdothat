local addonName, ns = ...

local Popup = {}
ns.ConfirmPopup = Popup

local KEY = "DONTDOTHAT_CONFIRM"

-- Each prompt carries its own callbacks in the dialog's data, so another prompt, a re-used dialog, or the
-- game hiding it cannot clear them. `current` is only a fallback for a handler called without data.
local current

local function say(message)
  if _G.DEFAULT_CHAT_FRAME and _G.DEFAULT_CHAT_FRAME.AddMessage then
    pcall(_G.DEFAULT_CHAT_FRAME.AddMessage, _G.DEFAULT_CHAT_FRAME, "|cffff3333Don't Do That:|r " .. message)
  end
end

-- kind is "accept" or "cancel". Runs the matching callback once; a later answer for the same prompt is ignored.
local function answer(kind, data)
  data = data or current
  if type(data) ~= "table" or data.answered then return end
  data.answered = true
  if current == data then current = nil end
  if ns.Log then ns.Log.Add("popup: %s", kind) end
  local fn = kind == "accept" and data.onConfirm or data.onCancel
  if not fn then return end
  local ok, err = pcall(fn)
  if not ok then
    if ns.Log then ns.Log.Add("popup: the %s step failed: %s", kind, tostring(err)) end
    say(("that didn't work (%s)."):format(tostring(err)))
  end
end

local function register()
  if type(_G.StaticPopupDialogs) ~= "table" then return false end
  if _G.StaticPopupDialogs[KEY] then return true end
  _G.StaticPopupDialogs[KEY] = {
    text = "%s",
    button1 = _G.ACCEPT or "Accept",
    button2 = _G.CANCEL or "Cancel",
    -- Called as (dialog, data, ...). Returning nothing lets the game close the dialog.
    OnAccept = function(_, data) answer("accept", data) end,
    OnCancel = function(_, data) answer("cancel", data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    -- Addon dialogs use the last slot, so they never take over a slot the game's own dialogs rely on.
    preferredIndex = 3,
  }
  return true
end

-- Shows an Accept / Cancel dialog with this text. Returns true if it was shown, false when it cannot be, so the
-- caller can degrade (a banner, or leaving the game's own dialog alone).
function Popup.Show(text, onConfirm, onCancel)
  if type(_G.StaticPopup_Show) ~= "function" or not register() then return false end
  if current then answer("cancel", current) end -- a previous unanswered prompt counts as cancelled
  local data = { onConfirm = onConfirm, onCancel = onCancel }
  current = data
  local ok, dialog = pcall(_G.StaticPopup_Show, KEY, text, nil, data)
  if not ok or not dialog then
    -- The game may have called OnCancel itself when it could not show the dialog; either way this
    -- prompt is over and the caller decides what happens next.
    data.answered = true
    if current == data then current = nil end
    if ns.Log then ns.Log.Add("popup: could not be shown") end
    return false
  end
  if ns.Log then ns.Log.Add("popup: shown") end
  return true
end

-- The "Buy anyway?" question for a flagged purchase.
function Popup.Ask(verdict, onConfirm, onCancel)
  local head = ns.UIHelpers.BannerText(verdict)
  local reason = verdict and verdict.reason or ""
  local earn = ns.EarnBack and ns.EarnBack.Line(verdict and verdict.cost)
  return Popup.Show(head .. "\n\n" .. tostring(reason) .. (earn and ("\n\n" .. earn) or "") .. "\n\nBuy anyway?", onConfirm, onCancel)
end

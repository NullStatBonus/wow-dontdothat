local addonName, ns = ...
local L = ns.L

-- The small warning: 320 wide, height follows its text. A recommendation in words (tier-colored), a neutral title
-- (item or action and cost), then the reason and any earn-back line. Same hold and fade as the large banner; a newer
-- warning replaces the one on screen. Mouse-transparent except while Move places it.
-- Look comes from profile.toast = { bgAlpha, textAlpha, scale (percent), point = { point, relPoint, x, y } }.
-- The point's x and y are in UIParent units, so changing the scale keeps the toast where it was placed.
local Toast = {}
ns.Toast = Toast

local WIDTH, EDGE, ICON, HOLD, FADE = 320, 4, 24, 2.5, 1.5
local NAME = "DontDoThatToast"
local DEFAULT_POINT = { point = "TOP", relPoint = "TOP", x = 0, y = -160 }
local frame
local session -- the Move in progress: { profile = the profile table it started in }
local callbacks = {} -- target for AceDB profile callbacks during Move

local function H() return ns.UIHelpers end
local function call(obj, method, ...) return ns.Style.call(obj, method, ...) end

local function config()
  local p = ns.Style.Profile()
  return p and type(p.toast) == "table" and p.toast or nil
end

local function savedPoint()
  local c = config()
  local p = c and c.point
  if type(p) == "table" and type(p.point) == "string" and type(p.x) == "number" and type(p.y) == "number" then
    return p
  end
  return DEFAULT_POINT
end

-- The frame's own scale relative to UIParent: SetPoint offsets are in the frame's scaled units.
local function relScale()
  local ok, s = call(frame, "GetEffectiveScale")
  local okP, ps = call(UIParent, "GetEffectiveScale")
  if ok and okP and type(s) == "number" and type(ps) == "number" and s > 0 and ps > 0 then return s / ps end
  ok, s = call(frame, "GetScale")
  return (ok and type(s) == "number" and s > 0) and s or 1
end

local function anchor()
  local p = savedPoint()
  local k = relScale()
  frame:ClearAllPoints()
  frame:SetPoint(p.point, UIParent, type(p.relPoint) == "string" and p.relPoint or p.point, p.x / k, p.y / k)
end

local function apply()
  if not frame then return end
  local look = H().Appearance(config())
  -- The placeholder must be visible and grabbable even when the player dimmed everything to zero.
  if session then look.bg, look.text = 1, 1 end
  call(frame, "SetScale", look.scale)
  ns.Style.ApplySurface({ frame.bg, frame.edge }, { frame.icon, frame.recommendation, frame.title, frame.detail }, look)
  if not session then anchor() end
end

local function layout()
  local Hp = H()
  local left = EDGE + Hp.CONTENT_PAD
  local hasIcon = frame.icon:IsShown()
  local textLeft = hasIcon and (left + ICON + Hp.PAD) or left
  local textWidth = WIDTH - textLeft - Hp.CONTENT_PAD
  local y = Hp.CONTENT_PAD
  local height = 0
  for _, s in ipairs({ frame.recommendation, frame.title, frame.detail }) do
    s:SetWidth(textWidth)
    s:ClearAllPoints()
    if s:IsShown() then
      s:SetPoint("TOPLEFT", frame, "TOPLEFT", textLeft, -y)
      local h = s:GetStringHeight() or 12
      y = y + h + Hp.SPACE
      height = y
    end
  end
  height = math.max(height - Hp.SPACE, hasIcon and (Hp.CONTENT_PAD + ICON) or 0) + Hp.CONTENT_PAD
  frame:SetHeight(height)
end

local function setLine(s, text, color)
  if text and text ~= "" then
    s:SetText(text)
    if color then s:SetTextColor(color[1], color[2], color[3]) end
    s:Show()
  else
    s:SetText("")
    s:Hide()
  end
end

local function fill(content)
  local ink = H().INK
  local c = content.color or ink.cost
  frame.edge:SetColorTexture(c[1], c[2], c[3], 1)
  setLine(frame.recommendation, content.recommendation, c)
  setLine(frame.title, content.title, ink.primary)
  setLine(frame.detail, content.detail, ink.secondary)
  if content.icon and pcall(frame.icon.SetTexture, frame.icon, content.icon) then frame.icon:Show() else frame.icon:Hide() end
  layout()
end

local function stopMoving()
  call(frame, "StopMovingOrSizing")
  -- Keep the game's layout cache out of it: the profile holds the position.
  call(frame, "SetUserPlaced", false)
end

local function finish()
  session = nil -- before Hide, so OnHide does not cancel again
  call(frame, "SetScript", "OnKeyDown", nil)
  call(frame, "EnableKeyboard", false)
  call(frame, "UnregisterEvent", "PLAYER_REGEN_DISABLED")
  local db = ns.db
  if db and db.UnregisterCallback then
    for _, e in ipairs({ "OnProfileChanged", "OnProfileCopied", "OnProfileReset" }) do pcall(db.UnregisterCallback, callbacks, e) end
  end
  frame.controls:Hide()
  call(frame, "EnableMouse", false)
  call(frame, "SetFrameStrata", "HIGH")
  call(frame, "SetClampRectInsets", 0, 0, 0, 0)
  frame.isSample = false
  frame:Hide()
  apply()
end

-- Ends Move without saving: the toast goes back to the saved (or default) position.
function Toast.CancelMove()
  if not session then return end
  stopMoving()
  finish()
end

-- Saves the placed position into the profile Move started in, then ends Move. A profile switch voids it.
function Toast.FinishMove()
  if not session then return end
  stopMoving()
  local profile = ns.Style.Profile()
  if profile ~= session.profile or profile == nil then return Toast.CancelMove() end
  local ok, point, _, relPoint, x, y = pcall(frame.GetPoint, frame, 1)
  if ok and type(point) == "string" and type(x) == "number" and type(y) == "number" then
    profile.toast = type(profile.toast) == "table" and profile.toast or {}
    local k = relScale() -- stored in UIParent units, so a later scale change does not move it
    profile.toast.point = { point = point, relPoint = relPoint or point, x = x * k, y = y * k }
  end
  finish()
end

local function build()
  local f = CreateFrame("Frame", NAME, UIParent)
  frame = f
  f:SetSize(WIDTH, 60)
  call(f, "SetFrameStrata", "HIGH")
  call(f, "SetClampedToScreen", true)
  call(f, "SetMovable", true)
  call(f, "SetDontSavePosition", true)
  call(f, "EnableMouse", false)
  call(f, "RegisterForDrag", "LeftButton")
  f:Hide()

  f.bg = f:CreateTexture(nil, "BACKGROUND")
  f.bg:SetAllPoints(f)
  f.bg:SetColorTexture(0, 0, 0, 1)
  f.edge = f:CreateTexture(nil, "BORDER")
  f.edge:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
  f.edge:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
  f.edge:SetWidth(EDGE)
  f.icon = f:CreateTexture(nil, "ARTWORK")
  f.icon:SetSize(ICON, ICON)
  f.icon:SetPoint("TOPLEFT", f, "TOPLEFT", EDGE + H().CONTENT_PAD, -H().CONTENT_PAD)
  f.icon:Hide()

  f.recommendation = ns.Style.Font(f, "supporting")
  f.title = ns.Style.Font(f, "body")
  f.detail = ns.Style.Font(f, "supporting")

  -- Done / Cancel for Move, just under the placeholder (the clamp area grows to keep them on screen).
  local controls = CreateFrame("Frame", nil, f)
  controls:SetSize(2 * 96 + H().PAD, 24)
  controls:SetPoint("TOP", f, "BOTTOM", 0, -H().PAD)
  controls:Hide()
  local done = ns.Style.Button(controls, L["Done"], function() Toast.FinishMove() end)
  done:SetPoint("LEFT", controls, "LEFT", 0, 0)
  local cancel = ns.Style.Button(controls, L["Cancel"], function() Toast.CancelMove() end)
  cancel:SetPoint("RIGHT", controls, "RIGHT", 0, 0)
  f.controls = controls

  f:SetScript("OnDragStart", function() if session then call(f, "StartMoving") end end)
  f:SetScript("OnDragStop", function() stopMoving() end)
  -- Anything hiding the placeholder undoes the Move (Escape is caught by its OnKeyDown, see StartMove).
  f:SetScript("OnHide", function() Toast.CancelMove() end)

  local group = f:CreateAnimationGroup()
  local fade = group:CreateAnimation("Alpha")
  fade:SetFromAlpha(1)
  fade:SetToAlpha(0)
  fade:SetStartDelay(HOLD)
  fade:SetDuration(FADE)
  group:SetScript("OnFinished", function() f:Hide() end)
  f.group = group
  apply()
  return f
end

local function show(verdict, name, sample)
  local ok = pcall(function()
    -- A warning (or sample) arriving during Move takes the frame back; the tentative position is dropped.
    Toast.CancelMove()
    frame = frame or build()
    fill(H().Content(verdict, name))
    apply()
    frame.isSample = sample
    -- A sample is often previewed from the settings window (FULLSCREEN_DIALOG), so it draws above it.
    call(frame, "SetFrameStrata", sample and "TOOLTIP" or "HIGH")
    frame.group:Stop()
    frame:SetAlpha(1)
    frame:Show()
    frame.group:Play()
  end)
  return ok
end

function Toast.Show(verdict, name) return show(verdict, name, false) end

-- Same drawing as a real warning; touches no cooldown, chat or ledger. A real warning replaces it.
function Toast.ShowSample(verdict, name) return show(verdict, name, true) end

-- Hides the toast only when it is showing a sample, never a real warning or the Move placeholder.
function Toast.HideSample()
  if not (frame and frame.isSample) or session then return false end
  pcall(function()
    frame.group:Stop()
    frame:Hide()
  end)
  frame.isSample = false
  return true
end

-- Re-applies alpha, scale and position after a setting changed (position is left alone during Move).
function Toast.Refresh()
  pcall(apply)
end

function Toast.IsMoving() return session ~= nil end

-- Shows a draggable placeholder with Done and Cancel above the settings window. Returns false if it cannot.
function Toast.StartMove()
  if session then return true end
  -- Not in combat: the client limits keyboard handling there, so Escape could not undo the Move.
  if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then
    if ns.Prompt and ns.Prompt.Say then ns.Prompt.Say(L["Don't Do That: leave combat to move warnings."]) end
    return false
  end
  local ok = pcall(function()
    frame = frame or build()
    frame.group:Stop()
    session = { profile = ns.Style.Profile() }
    fill({
      recommendation = L["Move warnings"],
      title = L["Drag this to where warnings should appear."],
      detail = L["Done saves the position. Cancel or Escape puts it back."],
    })
    call(frame, "SetFrameStrata", "TOOLTIP") -- above the settings window (FULLSCREEN_DIALOG)
    call(frame, "EnableMouse", true)
    call(frame, "SetClampRectInsets", 0, 0, 0, -(24 + 2 * H().PAD))
    frame.controls:Show()
    frame.isSample = false
    -- Escape cancels Move here, on the placeholder, and goes no further: through UISpecialFrames the same press
    -- would also close the settings window. Every other key passes on to the game. Entering combat ends the Move,
    -- since the client limits keyboard handling there.
    call(frame, "RegisterEvent", "PLAYER_REGEN_DISABLED")
    call(frame, "SetScript", "OnEvent", function(_, event) if event == "PLAYER_REGEN_DISABLED" then Toast.CancelMove() end end)
    if call(frame, "SetPropagateKeyboardInput", true) then
      call(frame, "SetScript", "OnKeyDown", function(self, key)
        if key == "ESCAPE" then
          call(self, "SetPropagateKeyboardInput", false)
          -- End Move on the next frame, so the keyboard is released only after this press was kept from the game.
          local T = _G.C_Timer
          if T and T.After then T.After(0, function() Toast.CancelMove() end) else Toast.CancelMove() end
        else
          call(self, "SetPropagateKeyboardInput", true)
        end
      end)
      call(frame, "EnableKeyboard", true)
    end
    local db = ns.db
    if db and db.RegisterCallback then
      for _, e in ipairs({ "OnProfileChanged", "OnProfileCopied", "OnProfileReset" }) do
        pcall(db.RegisterCallback, callbacks, e, function() Toast.CancelMove() end)
      end
    end
    apply()
    anchor()
    frame:SetAlpha(1)
    frame:Show()
  end)
  if not ok then
    if session and frame then pcall(finish) end
    session = nil
    return false
  end
  return true
end

-- Puts the toast back at its default place. Changes only profile.toast.point.
function Toast.ResetPosition()
  Toast.CancelMove()
  local c = config()
  if c then c.point = nil end
  pcall(apply)
end

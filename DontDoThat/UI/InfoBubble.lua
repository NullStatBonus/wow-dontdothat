local addonName, ns = ...

local Bubble = {}
ns.InfoBubble = Bubble

local pinned
local WIDTH, CLOSE = 300, 24
local SAMPLE = {} -- owner of a pinned sample

-- The pinned explanation: a pure-black surface (profile.explanation = { bgAlpha, textAlpha, scale }) whose height
-- follows its text, with the native close button. Escape closes a real one; so does clicking the same indicator again.
local function buildPin()
  local H = ns.UIHelpers
  local f = CreateFrame("Frame", "DontDoThatExplanation", UIParent)
  f:SetSize(WIDTH, 70)
  f:SetFrameStrata("TOOLTIP")
  if f.SetClampedToScreen then pcall(f.SetClampedToScreen, f, true) end
  f.bg = f:CreateTexture(nil, "BACKGROUND")
  f.bg:SetAllPoints(f)
  f.bg:SetColorTexture(0, 0, 0, 1)
  f.text = ns.Style.Font(f, "body")
  f.text:SetPoint("TOPLEFT", f, "TOPLEFT", H.CONTENT_PAD, -H.CONTENT_PAD)
  f.text:SetWidth(WIDTH - H.CONTENT_PAD - CLOSE)
  local ink = H.INK.primary
  pcall(f.text.SetTextColor, f.text, ink[1], ink[2], ink[3])
  local ok, close = pcall(CreateFrame, "Button", nil, f, "UIPanelCloseButton")
  if not ok or not close then close = ns.Style.Button(f, "X", nil, CLOSE) end
  close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function() f:Hide() end)
  f.close = close
  f:SetScript("OnHide", function() f.owner = nil end)
  f:Hide()
  return f
end

local function applyLook()
  if not pinned then return end
  local p = ns.Style.Profile()
  local look = ns.UIHelpers.Appearance(p and p.explanation)
  if pinned.SetScale then pcall(pinned.SetScale, pinned, look.scale) end
  ns.Style.ApplySurface({ pinned.bg }, { pinned.text }, look) -- the native close button keeps full alpha
end

-- Pins text beside anchor (or mid-screen without one). owner is the indicator, or SAMPLE.
local function pin(owner, anchor, text)
  pinned = pinned or buildPin()
  pinned.text:SetText(text or "")
  -- Tall enough for the wrapped text, whatever its length.
  local pad = ns.UIHelpers.CONTENT_PAD
  pinned:SetHeight(math.max(CLOSE + pad, (pinned.text:GetStringHeight() or 0) + 2 * pad))
  pinned:ClearAllPoints()
  if anchor then pinned:SetPoint("TOPLEFT", anchor, "BOTTOMRIGHT", 4, 0)
  else pinned:SetPoint("CENTER", UIParent, "CENTER", 0, 120) end
  applyLook()
  -- The game's Escape hides a real explanation (only while it is shown). A sample is left out: it is often opened
  -- from the settings window, which the same Escape would also close; the sample's own timeout or X ends it.
  ns.Style.SetEscape(pinned, owner ~= SAMPLE)
  pinned:Show()
  pinned.owner = owner
end

function Bubble.Dismiss()
  if pinned then pcall(pinned.Hide, pinned) end
end

-- Re-applies the explanation's background/text alpha and scale after a setting changed.
function Bubble.RefreshAppearance()
  pcall(applyLook)
end

-- Pins a sample explanation through the same drawing; a real click replaces it. label (e.g. "Sample: Frostbolt")
-- heads the text so the sample reads as one. A real explanation already pinned stays: no sample is shown.
function Bubble.ShowSample(verdict, anchor, label)
  if pinned and pinned.owner ~= nil and pinned.owner ~= SAMPLE and pinned:IsShown() then return false end
  local text = ns.UIHelpers.RichText(verdict)
  if type(label) == "string" and label ~= "" then text = text and (label .. "\n\n" .. text) or label end
  return (pcall(pin, SAMPLE, anchor, text))
end

-- Dismisses the pinned explanation only when it is a sample.
function Bubble.DismissSample()
  if pinned and pinned.owner == SAMPLE then
    pcall(pinned.Hide, pinned)
    pinned.owner = nil
    return true
  end
  return false
end

function Bubble.IsSampleShown() return pinned ~= nil and pinned.owner == SAMPLE and pinned:IsShown() end

local DEFAULT_COLOR = { 1, 0.82, 0 }

-- Colors the label by the verdict's tier; hover turns it white.
function Bubble.Refresh(b, verdict)
  if not b or not b.label then return end
  if verdict ~= nil then b.verdict = verdict end
  local style = b.verdict and ns.UIHelpers.TierStyle(b.verdict.tier)
  b.baseColor = style and style.color or DEFAULT_COLOR
  pcall(b.label.SetTextColor, b.label, b.baseColor[1], b.baseColor[2], b.baseColor[3])
end

-- Creates an outlined "(i)" button on parent: hover shows the reason, click pins it until dismissed.
function Bubble.Create(parent, verdict)
  local ok, btn = pcall(function()
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(28, 18)
    local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    t:SetPoint("CENTER")
    t:SetText("(i)")
    pcall(function()
      local font, size = t:GetFont()
      if font then t:SetFont(font, size, "OUTLINE") end
    end)
    b.label = t
    b.verdict = verdict
    Bubble.Refresh(b)
    local function text() return ns.UIHelpers.RichText(b.verdict) end
    b:SetScript("OnEnter", function(self)
      pcall(function()
        t:SetTextColor(1, 1, 1)
        local parts = ns.UIHelpers.TooltipParts(b.verdict)
        if parts and _G.GameTooltip then
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
          GameTooltip:SetText(parts.heading, parts.color[1], parts.color[2], parts.color[3])
          if parts.reason then GameTooltip:AddLine(parts.reason, 1, 1, 1, true) end
          if parts.cost then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(parts.cost, 1, 0.82, 0)
          end
          if GameTooltip.SetMinimumWidth then pcall(GameTooltip.SetMinimumWidth, GameTooltip, 230) end
          GameTooltip:Show()
        end
      end)
    end)
    b:SetScript("OnLeave", function()
      pcall(function()
        local c = b.baseColor or DEFAULT_COLOR
        t:SetTextColor(c[1], c[2], c[3])
        GameTooltip:Hide()
        if GameTooltip.SetMinimumWidth then GameTooltip:SetMinimumWidth(0) end -- the width is shared with every tooltip
      end)
    end)
    b:SetScript("OnHide", function()
      pcall(function()
        if GameTooltip.SetMinimumWidth and GameTooltip:GetOwner() == b then GameTooltip:SetMinimumWidth(0) end
      end)
    end)
    b:SetScript("OnClick", function(self)
      pcall(function()
        if pinned and pinned:IsShown() and pinned.owner == self then pinned:Hide() return end
        pin(self, self, text())
      end)
    end)
    return b
  end)
  return ok and btn or nil
end

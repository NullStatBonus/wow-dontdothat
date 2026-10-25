local addonName, ns = ...

local Bubble = {}
ns.InfoBubble = Bubble

local pinned

local function buildPin()
  local f = CreateFrame("Frame", nil, UIParent, _G.BackdropTemplateMixin and "BackdropTemplate" or nil)
  f:SetSize(300, 90)
  f:SetFrameStrata("TOOLTIP")
  if f.SetBackdrop then
    f:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 } })
  end
  f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  f.text:SetPoint("TOPLEFT", 10, -10)
  f.text:SetPoint("BOTTOMRIGHT", -26, 10)
  f.text:SetJustifyH("LEFT")
  f.text:SetJustifyV("TOP")
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function() f:Hide() end)
  f:Hide()
  return f
end

function Bubble.Dismiss()
  if pinned then pcall(pinned.Hide, pinned) end
end

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
      end)
    end)
    b:SetScript("OnClick", function(self)
      pcall(function()
        pinned = pinned or buildPin()
        if pinned:IsShown() and pinned.owner == self then pinned:Hide() return end
        pinned.owner = self
        pinned.text:SetText(text() or "")
        -- Tall enough for the wrapped text, whatever its length.
        pinned:SetHeight(math.max(70, pinned.text:GetStringHeight() + 24))
        pinned:ClearAllPoints()
        pinned:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 4, 0)
        pinned:Show()
      end)
    end)
    return b
  end)
  return ok and btn or nil
end

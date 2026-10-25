local addonName, ns = ...

local Banner = {}
ns.AlertBanner = Banner

local HOLD, FADE = 2.5, 1.5
local frame

local function build()
  local f = CreateFrame("Frame", nil, UIParent)
  f:SetSize(700, 80)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
  if f.SetFrameStrata then f:SetFrameStrata("FULLSCREEN_DIALOG") end
  f:Hide()

  f.title = f:CreateFontString(nil, "OVERLAY")
  if not pcall(f.title.SetFontObject, f.title, "GameFontNormalHuge") then
    pcall(f.title.SetFont, f.title, "Fonts\\FRIZQT__.TTF", 28, "OUTLINE")
  end
  f.title:SetPoint("TOP", f, "TOP", 0, 0)

  f.detail = f:CreateFontString(nil, "OVERLAY")
  if not pcall(f.detail.SetFontObject, f.detail, "GameFontNormalLarge") then
    pcall(f.detail.SetFont, f.detail, "Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
  end
  f.detail:SetPoint("TOP", f.title, "BOTTOM", 0, -6)

  local group = f:CreateAnimationGroup()
  local fade = group:CreateAnimation("Alpha")
  fade:SetFromAlpha(1)
  fade:SetToAlpha(0)
  fade:SetStartDelay(HOLD)
  fade:SetDuration(FADE)
  group:SetScript("OnFinished", function() f:Hide() end)
  f.group = group
  return f
end

function Banner.Show(verdict, name)
  local ok, err = pcall(function()
    frame = frame or build()
    local title, detail = ns.UIHelpers.BannerText(verdict, name)
    local style = ns.UIHelpers.TierStyle(verdict and verdict.tier)
    local c = style and style.color or { 1, 0.2, 0.2 }
    frame.title:SetText(title)
    frame.title:SetTextColor(c[1], c[2], c[3])
    frame.detail:SetText(detail)
    frame.group:Stop()
    frame:SetAlpha(1)
    frame:Show()
    frame.group:Play()
  end)
  return ok
end

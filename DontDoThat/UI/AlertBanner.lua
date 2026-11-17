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

  -- The recommendation in words above the title, so the tier reads without its color.
  f.recommendation = f:CreateFontString(nil, "OVERLAY")
  if not pcall(f.recommendation.SetFontObject, f.recommendation, "GameFontNormalLarge") then
    pcall(f.recommendation.SetFont, f.recommendation, "Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
  end
  f.recommendation:SetPoint("BOTTOM", f, "TOP", 0, 4)

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

local function show(verdict, name, sample)
  local ok = pcall(function()
    frame = frame or build()
    local title, detail = ns.UIHelpers.BannerText(verdict, name)
    local style = ns.UIHelpers.TierStyle(verdict and verdict.tier)
    local c = style and style.color or { 1, 0.2, 0.2 }
    frame.recommendation:SetText(style and style.label or "")
    frame.recommendation:SetTextColor(c[1], c[2], c[3])
    frame.title:SetText(title)
    frame.title:SetTextColor(c[1], c[2], c[3])
    frame.detail:SetText(detail)
    frame.isSample = sample
    -- A sample sits above the settings window that previewed it; a real warning keeps its usual layer.
    if frame.SetFrameStrata then frame:SetFrameStrata(sample and "TOOLTIP" or "FULLSCREEN_DIALOG") end
    frame.group:Stop()
    frame:SetAlpha(1)
    frame:Show()
    frame.group:Play()
  end)
  return ok
end

-- With debug on, the log names who asked for each real banner (to find a stray caller).
local function traceCaller(verdict, name)
  if ns.Log and ns.db and ns.db.profile and ns.db.profile.debug and type(_G.debugstack) == "function" then
    pcall(ns.Log.Add, "visual: banner for %s from %s", tostring(name), ((_G.debugstack(3, 3, 0) or ""):gsub("\n", " | ")))
  end
end

function Banner.Show(verdict, name) traceCaller(verdict, name); return show(verdict, name, false) end

-- Same drawing as a real warning, for previews; a real warning replaces it.
function Banner.ShowSample(verdict, name) return show(verdict, name, true) end

-- Hides the banner only when it is showing a sample.
function Banner.HideSample()
  if not (frame and frame.isSample) then return false end
  pcall(function() frame.group:Stop(); frame:Hide() end)
  frame.isSample = false
  return true
end

local addonName, ns = ...

local Badge = {}
ns.Badge = Badge

-- Creates (once per parent) a small tier-colored mark and updates it for the verdict.
-- Hides it when the verdict is nil or "keep". Returns the badge frame or nil.
function Badge.Attach(parent, verdict)
  local ok, badge = pcall(function()
    if not parent then return nil end
    local b = parent.dontdothatBadge
    if not b then
      b = CreateFrame("Frame", nil, parent)
      b:SetSize(16, 16)
      b:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
      b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      b.text:SetPoint("CENTER")
      b.text:SetText("!")
      parent.dontdothatBadge = b
    end
    local style = verdict and verdict.tier ~= "keep" and ns.UIHelpers.TierStyle(verdict.tier)
    if not style then
      b:Hide()
    else
      b.text:SetTextColor(style.color[1], style.color[2], style.color[3])
      b:Show()
    end
    return b
  end)
  return ok and badge or nil
end

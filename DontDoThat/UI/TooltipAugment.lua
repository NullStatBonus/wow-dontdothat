local addonName, ns = ...

local Tip = {}
ns.TooltipAugment = Tip

-- Adds the warning line to a tooltip. Returns true if a line was added.
function Tip.Augment(tooltip, verdict)
  local text = ns.UIHelpers.TooltipText(verdict)
  if not text or not tooltip or not tooltip.AddLine then return false end
  local style = ns.UIHelpers.TierStyle(verdict.tier)
  local c = style.color
  local ok = pcall(function()
    tooltip:AddLine(text, c[1], c[2], c[3], true)
    if tooltip.Show then tooltip:Show() end
  end)
  return ok
end

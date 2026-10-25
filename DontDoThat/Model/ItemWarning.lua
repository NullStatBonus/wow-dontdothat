local addonName, ns = ...

-- Decides whether a purchase should be warned about.
local ItemWarning = {}
ns.ItemWarning = ItemWarning

local MODES = {
  off = {}, vendor = { vendor = true }, ah = { ah = true }, both = { vendor = true, ah = true },
}

-- surface: "vendor" or "ah". total: copper for the whole click. Missing modes count as Off.
function ItemWarning.Flagged(modes, category, surface, total, minPrice)
  local on = MODES[modes and modes[category] or "off"]
  if not (on and on[surface]) then return false end
  return type(total) == "number" and total >= (minPrice or 0)
end

function ItemWarning.Reason(category)
  local info = ns.ItemCategory.Info(category)
  return info and info.reason or ""
end

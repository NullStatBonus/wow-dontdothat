local addonName, ns = ...

local Milestones = {}
ns.Milestones = Milestones

-- Copper = gold * 10000. All values are editable data.
-- Level 40: riding and first mount combined into `riding` (per spec: 100g covers both), mount = 0.
-- Level 60: riding 1000g plus 200g per Epic mount (spec default).
Milestones.Defaults = {
  [40] = { riding = 100 * 10000, mount = 0 },
  [60] = { riding = 1000 * 10000, mount = 200 * 10000 },
}

-- The targets for one class: the defaults, with any milestone the class's rule data overrides (a Paladin's
-- Warhorse is a class perk, for example). A class milestone may also carry a `note` shown with it.
function Milestones.For(class)
  local out = {}
  for level, targets in pairs(Milestones.Defaults) do out[level] = targets end
  local data = class and ns.Rules and ns.Rules.GetClass and ns.Rules.GetClass(class)
  for level, targets in pairs(data and data.milestones or {}) do out[level] = targets end
  return out
end

-- Deferral is continuous: warnings stay active from the start until the level 60 mount is
-- acquired. `current` is the next unbought mount (40, then 60); it only drives progress display.
-- manualOverride: nil or { [40] = true, [60] = true } marking milestones complete.
-- stopAfter: 40 ends warnings once the level 40 mount is done; anything else waits for the level 60 mount.
-- Returns { current, state } with state "active" or "finished".
function Milestones.State(ridingLearned40, ridingLearned60, manualOverride, stopAfter)
  local o = manualOverride or {}
  local done60 = ridingLearned60 or o[60]
  local done40 = ridingLearned40 or o[40] or done60
  if done60 or (stopAfter == 40 and done40) then return { current = nil, state = "finished" } end
  return { current = done40 and 60 or 40, state = "active" }
end

return Milestones

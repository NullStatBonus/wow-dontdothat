local addonName, ns = ...

local Milestones = {}
ns.Milestones = Milestones

local GOLD = 10000

-- Copper = gold * 10000. All values are editable data.
-- WoW Forever: level 40 riding training includes the first mount (100g); level 60 is Journeyman riding (1,000g)
-- plus a 200g epic mount.
Milestones.Defaults = {
  [40] = { riding = 100 * GOLD, mount = 0 },
  [60] = { riding = 1000 * GOLD, mount = 200 * GOLD },
}
-- Classic Era (game data, 1.15.9): the racial riding skill is 20g and a level 40 mount 80g. There is no epic riding
-- lesson; a level 60 epic mount is 1,000g and needs only the racial riding skill.
Milestones.EraDefaults = {
  [40] = { riding = 20 * GOLD, mount = 80 * GOLD },
  [60] = { riding = 0, mount = 1000 * GOLD },
}
-- Price cuts at the mount vendor and riding trainer, as fractions. They add.
Milestones.Discounts = {
  era = { honored = 0.10, pvpRank3 = 0.10 },
  forever = { honored = 0.10 },
}

-- "era" or "forever", from the client's interface number (Era 1.15 is 11509, Forever 1.60 is 16001).
function Milestones.Client(env)
  env = env or _G
  if type(env.GetBuildInfo) ~= "function" then return "forever" end
  local ok, _, _, _, interface = pcall(env.GetBuildInfo)
  if ok and type(interface) == "number" and interface < 16000 then return "era" end
  return "forever"
end

-- The targets for one class: the client's defaults, with any milestone the class's rule data overrides (a
-- Paladin's Warhorse is a class perk, for example). A class milestone may also carry a `note` shown with it.
function Milestones.For(class, client)
  local out = {}
  local defaults = (client or Milestones.Client()) == "era" and Milestones.EraDefaults or Milestones.Defaults
  for level, targets in pairs(defaults) do out[level] = targets end
  local data = class and ns.Rules and ns.Rules.GetClass and ns.Rules.GetClass(class)
  for level, targets in pairs(data and data.milestones or {}) do out[level] = targets end
  return out
end

-- The gold to save for one milestone: copper, and the discount taken off (0 to 1). standing is
-- { honored = bool, pvpRank3 = bool } from Adapter.ReadDiscounts. A class's own target is never discounted.
function Milestones.Goal(level, class, client, standing)
  client = client or Milestones.Client()
  local t = Milestones.For(class, client)[level]
  if not t then return nil, 0 end
  local base = (t.riding or 0) + (t.mount or 0)
  local data = class and ns.Rules and ns.Rules.GetClass and ns.Rules.GetClass(class)
  if data and data.milestones and data.milestones[level] then return base, 0 end
  local cut, rates = 0, Milestones.Discounts[client] or {}
  standing = standing or {}
  for key, rate in pairs(rates) do
    if standing[key] then cut = cut + rate end
  end
  return math.floor(base * (1 - cut) + 0.5), cut
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

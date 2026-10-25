local addonName, ns = ...

local PlayerProfile = {}
ns.PlayerProfile = PlayerProfile

-- STUB, UNVERIFIED: static proficiencies per class. Extend or replace with real data.
-- armorUpgrades maps armor type -> level at which it is gained.
PlayerProfile.Proficiencies = {
  HUNTER = {
    armor = { "Cloth", "Leather" },
    armorUpgrades = { Mail = 40 },
    weapons = { "Bows", "Crossbows", "Guns", "Daggers", "Polearms", "Staves", "Swords", "Axes" },
  },
}

function PlayerProfile.GetProficiencies(class)
  return PlayerProfile.Proficiencies[class]
end

local function copyPoints(t)
  local out = {}
  for k, v in pairs(t or {}) do out[k] = v end
  return out
end

-- input = { class, level, treePoints | talentSets, classData, professions, activeTalents (set of names, nil = unknown), professionAsked (set),
--           ridingLearned40, ridingLearned60, milestoneOverride, stopAfter, leadMargin, plausibleSpecs, rules }
-- rules (optional) = the player's switches and thresholds, see Model/Settings.lua; the engine reads them from profile.rules.
-- talentSets (array, first = active) takes precedence; treePoints is the single-set form.
function PlayerProfile.Build(input)
  local sets = input.talentSets or { input.treePoints or {} }
  local plausible = input.plausibleSpecs
  if not plausible and input.classData and ns.SpecInference then
    plausible = ns.SpecInference.Infer(input.classData, sets, { leadMargin = input.leadMargin })
  end
  local milestone = input.milestone
  if not milestone and ns.Milestones then
    milestone = ns.Milestones.State(input.ridingLearned40, input.ridingLearned60, input.milestoneOverride, input.stopAfter)
  end
  return {
    class = input.class,
    level = input.level or 1,
    treePoints = copyPoints(sets[1]),
    plausibleSpecs = plausible or {},
    rules = input.rules,
    professions = input.professions or {},
    activeTalents = input.activeTalents,
    professionAsked = input.professionAsked or {},
    milestone = milestone or { current = nil, state = "finished" }, -- no milestone data: warn about nothing
    proficiencies = PlayerProfile.GetProficiencies(input.class),
  }
end

return PlayerProfile

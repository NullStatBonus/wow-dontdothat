local addonName, ns = ...

-- Builds the rules engine's player profile from live client state. Returns nil for a class
-- with no rule data, so unsupported classes get no warnings at all.
local Context = {}
ns.Context = Context

function Context.Profile(env)
  local player = ns.Adapter.ReadPlayer(env)
  if not player.class then return nil end
  local classData = ns.Rules.GetClass(player.class)
  if not classData then return nil end

  local tabs = ns.Adapter.ReadTalentTabs(env)
  local treePoints = {}
  for key, spec in pairs(classData.specs or {}) do
    local tab = spec.tree and tabs[spec.tree]
    treePoints[key] = tab and tab.points or 0
  end
  local riding = ns.Adapter.ReadRiding(env)
  local saved = ns.db and ns.db.profile
  local pick = ns.Settings and ns.Settings.SpecOverride(player.class, classData, saved)
  return ns.PlayerProfile.Build({
    plausibleSpecs = pick and { pick } or nil,
    stopAfter = ns.Settings and ns.Settings.StopAfter(saved),
    rules = ns.Settings and ns.Settings.RulesFor(player.class, saved),
    class = player.class,
    level = player.level,
    treePoints = treePoints,
    classData = classData,
    professions = ns.Adapter.ReadProfessions(env),
    activeTalents = ns.Adapter.ReadActiveTalents(env),
    professionAsked = saved and saved.professionAsked,
    ridingLearned40 = riding.apprentice,
    ridingLearned60 = riding.journeyman,
    milestoneOverride = saved and saved.milestoneOverride,
  })
end

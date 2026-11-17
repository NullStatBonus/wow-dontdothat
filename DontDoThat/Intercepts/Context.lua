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
    professionAsked = ns.Settings and ns.Settings.ProfessionAsked(),
    ridingLearned40 = riding.apprentice,
    ridingLearned60 = riding.journeyman,
    milestoneOverride = ns.Settings and ns.Settings.MilestoneOverride(),
  })
end

-- Is the player still saving for the mount they chose to stop at? The same answer trainers get from the
-- engine, for the guards that never build a profile. No profile (unsupported class) means no warnings; a fault
-- while building it keeps the warnings, so a bug here never switches the safeguards off.
function Context.Saving(env)
  local ok, p = pcall(Context.Profile, env or _G)
  if not ok then return true end
  return p ~= nil and p.milestone ~= nil and p.milestone.state == "active"
end

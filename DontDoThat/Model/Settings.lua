local addonName, ns = ...

-- Reads the player's rule settings (Rules and General pages) in the shapes the engine and intercepts
-- need. Pure: every function takes the saved profile table, or finds it in ns.db, and tolerates it
-- being absent so a missing database means "all defaults".
local Settings = {}
ns.Settings = Settings

Settings.RuleKinds = { "skipRank", "offSpec" }

local function saved()
  return ns.db and ns.db.profile
end

-- A whole number of zero or more, else nil.
function Settings.Number(value)
  if type(value) == "number" and value >= 0 and value == math.floor(value) then return value end
  return nil
end

local function tuning(p)
  p = p or saved()
  return p and p.tuning or {}
end

-- { defer = true, deferLow = false, info = false }: the tiers that ask "Buy anyway?" and play the sound.
-- Only defer by default. keep never counts.
function Settings.PromptTiers(p)
  local chosen = tuning(p).promptTiers
  local out = {}
  for _, tier in ipairs({ "defer", "deferLow", "info" }) do
    if chosen == nil then out[tier] = tier == "defer" else out[tier] = chosen[tier] == true end
  end
  return out
end

function Settings.PromptsFor(tier, p)
  return Settings.PromptTiers(p)[tier] == true
end

local function flag(p, key) return p == nil or p[key] ~= false end

-- How firmly the addon nudges: "mark" (marks only, never asks), "ask" (asks about what to wait on),
-- "everything" (also asks about low-value and informational items), or "custom" when the saved marks,
-- "Ask before buying" and prompt tiers match none of those. Derived, never stored. Sound is not part of it.
function Settings.Nudge(p)
  p = p or saved()
  if not flag(p, "warnings") then return "custom" end
  if not flag(p, "blockingConfirmations") then return "mark" end
  local tiers = Settings.PromptTiers(p)
  if tiers.defer and tiers.deferLow and tiers.info then return "everything" end
  if tiers.defer and not tiers.deferLow and not tiers.info then return "ask" end
  return "custom"
end

-- Sets the three values behind a nudge level. "custom" (or anything else) changes nothing.
function Settings.SetNudge(name, p)
  p = p or saved()
  if not p then return end
  local tiers
  if name == "mark" then
    p.warnings, p.blockingConfirmations = true, false
    return
  elseif name == "ask" then tiers = { defer = true, deferLow = false, info = false }
  elseif name == "everything" then tiers = { defer = true, deferLow = true, info = true }
  else return end
  p.warnings, p.blockingConfirmations = true, true
  p.tuning = p.tuning or {}
  p.tuning.promptTiers = tiers
end

-- The areas of "What to watch" that have a switch of their own. Other has none: it is the slot and COD switches.
Settings.Areas = { "spells", "professions", "shopping" }

function Settings.Watching(area, p)
  p = p or saved()
  return not (p and p.watch and p.watch[area] == false)
end

function Settings.SetWatching(area, on, p)
  p = p or saved()
  if not p then return end
  p.watch = p.watch or {}
  p.watch[area] = on and true or false
end

-- 40 or 60: the mount after which warnings stop.
function Settings.StopAfter(p)
  return tuning(p).stopAfter == 40 and 40 or 60
end

-- The skip revision the player picked, or nil for "the newest" (the default). A non-number is ignored.
function Settings.SkipRevision(p)
  local v = tuning(p).skipRevision
  if type(v) == "number" and v == math.floor(v) then return v end
  return nil
end

-- Saves the pick; nil goes back to following the newest revision.
function Settings.SetSkipRevision(revision, p)
  p = p or saved()
  if not p then return end
  p.tuning = p.tuning or {}
  p.tuning.skipRevision = revision
end

-- True while the profile has not been told about the newest revision: a new install, or an update that added one.
function Settings.RevisionNoticeDue(newest, p)
  p = p or saved()
  local told = p and p.revisionNotice
  return type(told) ~= "number" or told < newest
end

function Settings.MarkRevisionNotice(newest, p)
  p = p or saved()
  if p then p.revisionNotice = newest end
end

-- The settings the engine reads, copied so later edits don't reach a built profile. Nil values mean
-- "use the rule data".
function Settings.RulesFor(class, p)
  p = p or saved()
  local off = p and p.ruleOff or {}
  local t = tuning(p)
  local function set(from)
    local out = {}
    for k, v in pairs(from or {}) do if v then out[k] = true end end
    return out
  end
  return {
    offAbilities = set(off.abilities and off.abilities[class]),
    offTags = set(off.tags and off.tags[class]),
    offKinds = set(off.kinds),
    skipRevision = t.skipRevision, -- nil: the newest revision (the engine checks the number is one it has)
  }
end

-- Facts about this character (mount marks, professions asked about), kept apart from the shared settings.
local function charData() return ns.db and ns.db.char end

function Settings.MilestoneOverride(c)
  c = c or charData()
  return c and c.milestoneOverride
end

function Settings.ProfessionAsked(c)
  c = c or charData()
  return c and c.professionAsked
end

-- Remembers that this character was asked about learning a profession, so it is asked about only once.
function Settings.MarkProfessionAsked(profession, c)
  c = c or charData()
  if not c then return end
  c.professionAsked = c.professionAsked or {}
  c.professionAsked[profession] = true
end

-- Once per character: mount marks saved in the shared profile before they became per character are copied
-- to a character only when it is at least that milestone's level (a level 25 alt cannot have its level 40
-- mount). Profession answers are not copied: at worst a character is asked once more. The shared values stay
-- in the saved data, unused, so an older version still reads them.
function Settings.MigrateCharMarks(c, shared, level)
  if type(c) ~= "table" or c.migratedMarks then return end
  local old = type(shared) == "table" and shared.milestoneOverride
  if type(old) == "table" and type(level) == "number" then
    for _, milestone in ipairs({ 40, 60 }) do
      if old[milestone] == true and level >= milestone then
        c.milestoneOverride = c.milestoneOverride or {}
        c.milestoneOverride[milestone] = true
      end
    end
  end
  c.migratedMarks = true
end

-- Spell families whose ID changed when the spell data was rebuilt (0.14.0): old family ID -> new one.
Settings.RENAMED_FAMILIES = { PALADIN = { [25902] = 20473 }, PRIEST = { [401955] = 1309595 } }

-- Moves spell switches saved under an old family ID to the new one, and re-keys trainer records kept under it
-- (a rank seen once may never be seen again). A switch or record already saved under the new ID wins. Safe to run every load.
function Settings.MigrateFamilyIds(p, c, renamed)
  renamed = renamed or Settings.RENAMED_FAMILIES
  local abilities = type(p) == "table" and type(p.ruleOff) == "table" and p.ruleOff.abilities
  for class, map in pairs(renamed) do
    local mine = type(abilities) == "table" and abilities[class]
    for old, new in pairs(map) do
      if type(mine) == "table" then
        for _, key in ipairs({ old, tostring(old) }) do
          if mine[key] ~= nil then
            if mine[new] == nil then mine[new] = mine[key] end
            mine[key] = nil
          end
        end
      end
      if type(c) == "table" then
        for _, cache in ipairs({ c.catalog, c.costCache }) do
          if type(cache) == "table" then
            local moves = {}
            for key, record in pairs(cache) do
              local id, rest = tostring(key):match("^(%d+)([:#].*)$")
              local family = type(record) == "table" and record.familyId or tonumber(id)
              if family == old and rest then moves[#moves + 1] = { key, new .. rest } end
            end
            for _, m in ipairs(moves) do
              local record = cache[m[1]]
              cache[m[1]] = nil
              if cache[m[2]] == nil then
                if type(record) == "table" then record.familyId = new end
                cache[m[2]] = record
              end
            end
          end
        end
      end
    end
  end
end

-- Settings that record what the player has already done rather than how they like things.
local KEEP_ON_RESET = { professionAsked = true, milestoneOverride = true, revisionNotice = true, styleMarked = true }

-- A copy of a default value, so a later edit of the profile never changes the defaults table.
local function copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do out[k] = copy(v) end
  return out
end

-- Newer settings-library versions file a WoW Forever character as "Name Surname" instead of "Name - Realm". Moves
-- this character's saved data and profile choice from oldKey to the key the loaded library uses, once: the old
-- entries are removed, so a later run finds nothing. Data already under the new key is never overwritten.
-- sv is the raw saved table (db.sv); its char and profileKeys may be missing on a fresh install.
function Settings.MigrateCharKey(sv, db, oldKey)
  local newKey = db and db.keys and db.keys.char
  if type(sv) ~= "table" or type(oldKey) ~= "string" or type(newKey) ~= "string" or oldKey == newKey then return false end
  local moved = false
  if type(sv.char) == "table" and type(sv.char[oldKey]) == "table" and sv.char[newKey] == nil then
    sv.char[newKey], sv.char[oldKey] = sv.char[oldKey], nil
    moved = true
  end
  if type(sv.profileKeys) == "table" and sv.profileKeys[oldKey] ~= nil then
    local old = sv.profileKeys[oldKey]
    local okCurrent, current = pcall(db.GetCurrentProfile, db)
    local done = type(old) ~= "string" -- nothing usable to carry over
    if type(old) == "string" and okCurrent then
      -- A fresh key starts on Default; any other profile there was picked on purpose and stays.
      if old == current or current ~= "Default" then
        done = true
      elseif pcall(db.SetProfile, db, old) then
        done, moved = true, true
      end
    end
    if done then sv.profileKeys[oldKey] = nil end
  end
  return moved
end

-- MigrateCharKey for each earlier key in turn, so the data follows the loaded library in either direction. The key
-- in use is skipped; with two candidates holding data, the first moves and the second is never copied over it.
function Settings.MigrateCharKeys(sv, db, keys)
  local moved = false
  for _, key in ipairs(type(keys) == "table" and keys or {}) do
    local ok, did = pcall(Settings.MigrateCharKey, sv, db, key)
    moved = moved or (ok and did) or false
  end
  return moved
end

-- Puts every setting back to its default. AceDB copies defaults into the profile only when it loads, so each cleared
-- setting gets its default back here (defaults: the profile defaults, ns.defaults.profile when not given); otherwise
-- it would stay empty until the next reload. The defaults have no "*" keys, which AceDB would treat specially.
function Settings.ResetAll(p, defaults)
  p = p or saved()
  if not p then return end
  for key in pairs(p) do
    if not KEEP_ON_RESET[key] then p[key] = nil end
  end
  defaults = defaults or (ns.defaults and ns.defaults.profile)
  if type(defaults) == "table" then
    for key, value in pairs(defaults) do
      if p[key] == nil then p[key] = copy(value) end
    end
  end
  if ns.Log and ns.Log.Switch then ns.Log.Switch(false) elseif ns.Log and ns.Log.SetEnabled then ns.Log.SetEnabled(false) end
end

local STYLES = { toast = true, warning = true }

-- The on-screen message style: "toast" or "warning" (the large centered banner).
function Settings.WarningStyle(p)
  p = p or saved()
  local style = p and p.alert and p.alert.style
  return STYLES[style] and style or "toast"
end

-- What the saved data said before AceDB loaded it: each saved profile by name, with its style. AceDB copies
-- defaults into the saved tables at load, so afterwards a missing style looks like the default. raw is the
-- DontDoThatDB global. A saved alert entry that is not a table is dropped here so AceDB fills in the defaults.
function Settings.StyleBefore(raw)
  local before = { existed = type(raw) == "table", profiles = {} }
  local profiles = before.existed and type(raw.profiles) == "table" and raw.profiles or {}
  for name, p in pairs(profiles) do
    if type(p) == "table" and p.alert ~= nil and type(p.alert) ~= "table" then p.alert = nil end
    local alert = type(p) == "table" and p.alert or nil
    before.profiles[name] = { style = alert and alert.style or nil }
  end
  return before
end

-- Once per profile, before anything shows a warning: a profile saved by a version from before the
-- Toast/Warning choice keeps the large banner it always had. name is the profile in use (AceDB's current
-- profile); a profile first created now is new, not old. styleMarked has no default, so AceDB never strips it
-- at logout, and Reset all settings keeps it, so a fresh or reset profile is not mistaken for an old one at the
-- next login.
function Settings.ClassifyStyle(p, before, name)
  if type(p) ~= "table" or p.styleMarked then return end
  local saved = before and before.profiles or {}
  local old = saved[name or "Default"]
  -- An older database with no profile saved at all was using Default with nothing changed.
  if not old and before and before.existed and next(saved) == nil then old = {} end
  if old and not STYLES[old.style] then
    if type(p.alert) ~= "table" then p.alert = {} end
    p.alert.style = "warning"
  end
  p.styleMarked = true
end

-- Debug recording is for one session: it is switched off whenever the addon loads.
function Settings.ClearDebug(p)
  p = p or saved()
  if p then p.debug, p.traceItems = false, false end
end

-- The spec the player picked for a class, only when the class data has it.
function Settings.SpecOverride(class, classData, p)
  p = p or saved()
  local pick = p and p.specOverride and p.specOverride[class]
  if pick and classData and classData.specs and classData.specs[pick] then return pick end
  return nil
end

return Settings

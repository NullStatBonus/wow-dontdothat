local addonName, ns = ...

local Rules = ns.Rules or {}
ns.Rules = Rules

local classes, professions = {}, {}

function Rules.Load(data)
  local id = Rules.Validate(data)
  if data.class then classes[id] = data else professions[id] = data end
  return data
end

function Rules.GetClass(key) return classes[key] end

-- Sorted keys of every loaded class, e.g. { "HUNTER" }.
function Rules.ListClasses()
  local keys = {}
  for key in pairs(classes) do keys[#keys + 1] = key end
  table.sort(keys)
  return keys
end
function Rules.GetProfession(key) return professions[key] end

-- Sorted keys of every loaded profession, e.g. { "Herbalism", "Skinning" }.
function Rules.ListProfessions()
  local keys = {}
  for key in pairs(professions) do keys[#keys + 1] = key end
  table.sort(keys)
  return keys
end

-- Recognises a trainer row as one of a profession's rank tiers. A row can be named by the tier alone
-- ("Journeyman") or together with the profession ("Journeyman Herbalism", "Herbalism (Journeyman)").
-- Row naming on the real trainer is UNVERIFIED; a row that matches nothing is simply left alone.
-- Returns the profession key and the tier name, or nil.
function Rules.MatchProfessionTier(rowName)
  if type(rowName) ~= "string" then return nil end
  local wanted = rowName:lower()
  for _, key in ipairs(Rules.ListProfessions()) do
    local prof = professions[key]
    local pname = (prof.profession or key):lower()
    for _, tier in ipairs(prof.tiers or {}) do
      local tname = tier.name:lower()
      if wanted == tname or wanted == tname .. " " .. pname or wanted == pname .. " (" .. tname .. ")"
          or wanted == pname .. " " .. tname then
        return key, tier.name
      end
    end
  end
  return nil
end

local learn = { gathering = {}, reasons = {}, generic = "%s won't pay for itself before level 40." }

-- Rule data for the one-time "learning a profession" question (Rules/Data/ProfessionLearn.lua).
function Rules.SetProfessionLearn(data) learn = data end

-- Recognises the trainer row that teaches the first tier of a profession the player should be asked
-- about ("Apprentice Leatherworking" or "Leatherworking (Apprentice)"). Gathering professions and
-- everything else return nil. Row naming on the real trainer is UNVERIFIED.
function Rules.MatchProfessionLearn(rowName)
  if type(rowName) ~= "string" then return nil end
  local name = rowName:match("^Apprentice (.+)$") or rowName:match("^(.+) %(Apprentice%)$")
  if name and not learn.gathering[name] then return name end
end

-- Test hook: forget all loaded data.
function Rules.Reset()
  classes, professions = {}, {}
end

local SEVERITY = { keep = 0, info = 1, deferLow = 2, defer = 3 }

local function contains(list, name)
  for _, v in ipairs(list or {}) do
    if v == name then return true end
  end
  return false
end

local function sortedKeys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  return keys
end

local function specName(data, key)
  return data.specs[key].name or key
end

local function plausible(profile, data)
  local keys, seen = {}, {}
  for _, key in ipairs(profile.plausibleSpecs or {}) do
    if data.specs[key] and not seen[key] then seen[key] = true; keys[#keys + 1] = key end
  end
  if #keys == 0 then keys = sortedKeys(data.specs) end -- ambiguous: every spec is plausible
  return keys, seen
end

-- A talent-only spell is part of a rotation only while its talent is active. An unknown talent list
-- (nil) never hides a spell.
local function inRotation(profile, data, list, name)
  if not contains(list, name) then return false end
  if profile.activeTalents and contains(data.talentSpells, name) and not profile.activeTalents[name] then return false end
  return true
end

local function rankRow(data, action)
  local rows = data.ranks and data.ranks[action.family or action.name]
  return rows and action.rank and rows[action.rank], rows
end

local function verdict(profile, tier, source, reason, cost, isEstimate)
  local m = profile.milestone or {}
  return {
    tier = tier, cost = cost, costIsEstimate = cost ~= nil and isEstimate or false,
    reason = reason, milestone = m.current, source = source,
  }
end

local function keep(profile)
  return verdict(profile, "keep", "default", "No rule applies.")
end

-- Cost: the adapter-supplied price wins; otherwise a data estimate, marked as such.
local function costFor(action, estimate)
  if action.cost then return action.cost, false end
  return estimate, true
end

-- Player-facing wording. Keep it short and free of internal terms (tags, tiers, specs, rotations).
local WAIT_UNTIL_60 = "You won't need this until level 60."

-- A per-ability sentence wins, then a per-tag sentence from the rule data, then the default.
local function whyWait(data, name, tag)
  if data.why and data.why[name] then return data.why[name] end
  if tag and data.tagReasons and data.tagReasons[tag] then return data.tagReasons[tag] end
  return WAIT_UNTIL_60
end

-- The same sentence the player sees in a tooltip, for pages that list an ability without a purchase.
function Rules.WhyWait(data, name, tag) return whyWait(data, name, tag) end

local function evaluateSpell(profile, action, data)
  local name = action.family or action.name
  local rules = profile.rules or {}
  local offAbilities, offTags, offKinds = rules.offAbilities or {}, rules.offTags or {}, rules.offKinds or {}
  -- An ability the player switched off is never flagged, whatever else would apply.
  if offAbilities[name] then return verdict(profile, "keep", "disabled", "You turned off warnings for this.") end
  local row, rows = rankRow(data, action)
  local cost, isEstimate = costFor(action, row and row.cost)
  local function out(tier, source, reason) return verdict(profile, tier, source, reason, cost, isEstimate) end

  -- A skipped rank is judged on its own, even when the spell as a whole is kept.
  local skipped = data.skipRanks and data.skipRanks[name]
  if skipped and not offKinds.skipRank and action.rank and contains(skipped, action.rank) then
    return out("defer", "skipRank", "Only a small upgrade over the rank before it.")
  end

  local override = data.overrides and data.overrides[name]
  if override then
    if override == "keep" then return verdict(profile, "keep", "override", "Worth having.") end
    return out(override, "override", whyWait(data, name))
  end

  local keys, isPlausible = plausible(profile, data)
  local infoSpec
  for _, key in ipairs(keys) do
    local rot = data.specs[key].rotation
    if inRotation(profile, data, rot.core, name) then
      return verdict(profile, "keep", "rotation", "You'll use this a lot.")
    end
    if not infoSpec and inRotation(profile, data, rot.situational, name) then infoSpec = key end
  end
  if infoSpec then
    return out("info", "rotation", "Handy now and then, but you can get by without it.")
  end

  local bestTier, bestTag
  local tags = {}
  for _, t in ipairs((data.tags and data.tags[name]) or {}) do tags[#tags + 1] = t end
  for _, t in ipairs(action.tags or {}) do tags[#tags + 1] = t end
  for _, tag in ipairs(tags) do
    local tier = not offTags[tag] and data.tagTiers and data.tagTiers[tag]
    if tier and SEVERITY[tier] > (bestTier and SEVERITY[bestTier] or 0) then bestTier, bestTag = tier, tag end
  end
  if bestTier then
    return out(bestTier, "tag", whyWait(data, name, bestTag))
  end

  for _, key in ipairs(offKinds.offSpec and {} or sortedKeys(data.specs)) do
    local rot = data.specs[key].rotation
    if not isPlausible[key] and (inRotation(profile, data, rot.core, name) or inRotation(profile, data, rot.situational, name)) then
      return out("deferLow", "rotation", ("Mostly used by %s players, and your talents lean another way."):format(specName(data, key)))
    end
  end

  return keep(profile)
end

local function evaluateRecipeTier(profile, action)
  local prof = professions[action.profession or action.family]
  local skill = prof and profile.professions and profile.professions[prof.profession]
  if not skill then return keep(profile) end
  local rules = profile.rules or {}
  if rules.offKinds and rules.offKinds.professionCap then return keep(profile) end
  local tierRow
  for _, t in ipairs(prof.tiers) do
    if t.name == action.name then tierRow = t end
  end
  if not tierRow then return keep(profile) end
  local margin = rules.nearCapMargin or prof.nearCapMargin or 25
  local cap = skill.max
  if cap and skill.skill and cap - skill.skill > margin then
    local cost, isEstimate = costFor(action, tierRow.cost)
    return verdict(profile, prof.tier or "defer", "tag",
      ("Your %s skill is %d of %d. You won't need %s until you're closer to the cap."):format(
        prof.profession, skill.skill, cap, action.name), cost, isEstimate)
  end
  return keep(profile)
end

-- Asked once per profession: already known, or already asked, means nothing to say.
local function evaluateProfessionLearn(profile, action)
  local name = action.profession
  if (profile.professions or {})[name] or (profile.professionAsked or {})[name] then return keep(profile) end
  local reason = learn.reasons[name] or learn.generic:format(name)
  local v = verdict(profile, "defer", "professionLearn", reason, action.cost, false)
  v.profession = name
  return v
end

function Rules.Evaluate(profile, action)
  local m = profile.milestone
  if not (m and m.state == "active") then return keep(profile) end
  if action.kind == "professionLearn" then return evaluateProfessionLearn(profile, action) end
  if action.kind == "recipeTier" then return evaluateRecipeTier(profile, action) end
  local data = classes[profile.class]
  if not data then return keep(profile) end
  return evaluateSpell(profile, action, data)
end

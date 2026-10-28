local addonName, ns = ...

ns.Rules = ns.Rules or {}

local TIERS = { keep = true, info = true, deferLow = true, defer = true }
ns.Rules.TIERS = TIERS

local function fail(where, msg)
  error(("DontDoThat rule data (%s): %s"):format(where, msg), 0)
end

local function isInt(v)
  return type(v) == "number" and v == math.floor(v)
end

local function checkStringList(where, list)
  if type(list) ~= "table" then fail(where, "must be a list of names") end
  for i, name in ipairs(list) do
    if type(name) ~= "string" then fail(where .. "[" .. i .. "]", "must be a string") end
  end
end

local function checkCost(where, cost)
  if cost ~= nil and (not isInt(cost) or cost < 0) then
    fail(where, "must be nil or a non-negative integer (copper)")
  end
end

local function checkClass(d, where)
  if type(d.specs) ~= "table" or next(d.specs) == nil then fail(where, "specs must be a non-empty table") end
  for key, spec in pairs(d.specs) do
    local w = where .. " specs." .. tostring(key)
    if type(spec) ~= "table" or type(spec.rotation) ~= "table" then fail(w, "needs a rotation table") end
    checkStringList(w .. ".rotation.core", spec.rotation.core)
    checkStringList(w .. ".rotation.situational", spec.rotation.situational or {})
    if spec.rotation.needsReview ~= nil and type(spec.rotation.needsReview) ~= "boolean" then
      fail(w .. ".rotation.needsReview", "must be a boolean")
    end
  end
  for name, tags in pairs(d.tags or {}) do
    if type(name) ~= "string" then fail(where .. " tags", "keys must be ability names") end
    checkStringList(where .. " tags." .. name, tags)
    for _, tag in ipairs(tags) do
      if not (d.tagTiers or {})[tag] then fail(where .. " tags." .. name, "tag '" .. tag .. "' has no entry in tagTiers") end
    end
  end
  for tag, tier in pairs(d.tagTiers or {}) do
    if not TIERS[tier] then fail(where .. " tagTiers." .. tostring(tag), "unknown tier '" .. tostring(tier) .. "'") end
  end
  for name, tier in pairs(d.overrides or {}) do
    if not TIERS[tier] then fail(where .. " overrides." .. tostring(name), "unknown tier '" .. tostring(tier) .. "'") end
  end
  checkStringList(where .. " talentSpells", d.talentSpells or {})
  checkStringList(where .. " reviewed", d.reviewed or {})
  checkStringList(where .. " general", d.general or {})
  checkStringList(where .. " pet", d.pet or {})
  if d.grimoires ~= nil then
    if type(d.grimoires) ~= "table" then fail(where .. " grimoires", "must be a table") end
    checkStringList(where .. " grimoires.keep", d.grimoires.keep or {})
    if type(d.grimoires.reason) ~= "string" or d.grimoires.reason == "" then
      fail(where .. " grimoires.reason", "must be a plain-language sentence")
    end
  end
  for level, m in pairs(d.milestones or {}) do
    local w = where .. " milestones[" .. tostring(level) .. "]"
    if level ~= 40 and level ~= 60 then fail(w, "must be the level 40 or level 60 milestone") end
    if type(m) ~= "table" then fail(w, "must be a table") end
    checkCost(w .. ".riding", m.riding)
    checkCost(w .. ".mount", m.mount)
    if m.note ~= nil and type(m.note) ~= "string" then fail(w .. ".note", "must be a string") end
  end
  for name, ranks in pairs(d.skipRanks or {}) do
    local w = where .. " skipRanks." .. tostring(name)
    if type(ranks) ~= "table" or #ranks == 0 then fail(w, "must be a non-empty list of rank numbers") end
    for i, rank in ipairs(ranks) do
      if not isInt(rank) or rank < 1 then fail(w .. "[" .. i .. "]", "must be a rank number of 1 or more") end
    end
  end
  for family, rows in pairs(d.ranks or {}) do
    local w = where .. " ranks." .. tostring(family)
    if type(rows) ~= "table" or #rows == 0 then fail(w, "must be a non-empty list of rank rows") end
    local lastLevel = 0
    for i, row in ipairs(rows) do
      if row.rank ~= i then fail(w .. "[" .. i .. "]", "rank must be " .. i) end
      if not isInt(row.unlockLevel) or row.unlockLevel < lastLevel then
        fail(w .. "[" .. i .. "]", "unlockLevel must be an integer, not lower than the previous rank")
      end
      lastLevel = row.unlockLevel
      checkCost(w .. "[" .. i .. "].cost", row.cost)
    end
  end
  for name, level in pairs(d.abilityLevels or {}) do
    if not isInt(level) or level < 1 then fail(where .. " abilityLevels." .. tostring(name), "must be a level") end
  end
end

-- Raises a clear error (no traceback position) when data is malformed.
function ns.Rules.Validate(d)
  if type(d) ~= "table" then fail("?", "data must be a table") end
  local id = d.class
  if type(id) ~= "string" then fail("?", "needs a 'class' string") end
  checkClass(d, id)
  return id
end

-- Rule files are written with English spell names. Compile turns them into the form the engine uses: every
-- name becomes a spell family ID (see Model/SpellData.lua), a "~Prefix" key or entry stands for every family whose
-- name starts with the prefix, and a name that matches no spell raises an error that names the rule. The source
-- table is left alone. resolver = { id = function(name) -> key or nil, prefix = function(prefix) -> list of keys }.
function ns.Rules.Compile(d, resolver)
  local class = d.class
  local function keysFor(where, name)
    if type(name) ~= "string" then fail(class .. " " .. where, "spell names must be strings") end
    if name:sub(1, 1) == "~" then
      local ids = resolver.prefix(name:sub(2))
      if #ids == 0 then fail(class .. " " .. where, "no spell name starts with '" .. name:sub(2) .. "'") end
      return ids
    end
    local id = resolver.id(name)
    if id == nil then fail(class .. " " .. where, "no spell named '" .. name .. "' for this class") end
    return { id }
  end
  local function list(where, names)
    if names == nil then return nil end
    local out, seen = {}, {}
    for _, name in ipairs(names) do
      for _, id in ipairs(keysFor(where, name)) do
        if not seen[id] then seen[id] = true; out[#out + 1] = id end
      end
    end
    return out
  end
  local function map(where, from)
    if from == nil then return nil end
    local out = {}
    for name, value in pairs(from) do
      for _, id in ipairs(keysFor(where .. "." .. tostring(name), name)) do out[id] = value end
    end
    return out
  end
  local out = {}
  for k, v in pairs(d) do out[k] = v end
  out.specs = {}
  for key, spec in pairs(d.specs) do
    local rotation = {}
    for k, v in pairs(spec.rotation) do rotation[k] = v end
    rotation.core = list("specs." .. key .. ".rotation.core", spec.rotation.core)
    rotation.situational = list("specs." .. key .. ".rotation.situational", spec.rotation.situational)
    local copy = {}
    for k, v in pairs(spec) do copy[k] = v end
    copy.rotation = rotation
    out.specs[key] = copy
  end
  for _, field in ipairs({ "tags", "overrides", "why", "skipRanks", "ranks", "abilityLevels" }) do
    out[field] = map(field, d[field])
  end
  for _, field in ipairs({ "talentSpells", "reviewed", "general", "pet" }) do
    out[field] = list(field, d[field])
  end
  return out
end

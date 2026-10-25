local addonName, ns = ...

-- The only module that reads trainer, talent and player state from the client. Everything goes
-- through an injected environment table (default _G) and pcall, so a missing or restricted
-- function degrades to "no data" instead of an error. Shapes below were observed on
-- Classic Era 1.15.9 (see docs/contracts.md); WoW Forever is UNVERIFIED.
local Adapter = {}
ns.Adapter = Adapter

-- Keeps the count of results, so a nil in the middle (a header row with no subtext) does not cut the rest off.
local function pack(...) return { n = select("#", ...), ... } end

local function call(env, fname, ...)
  local f = env[fname]
  if type(f) ~= "function" then return nil end
  local res = pack(pcall(f, ...))
  if not res[1] then return nil end
  return unpack(res, 2, res.n)
end

local function parseRank(sub)
  if type(sub) ~= "string" then return nil end
  local n = sub:match("(%d+)")
  return n and tonumber(n) or nil
end

-- GetTrainerServiceInfo(i) -> name, subText ("Rank 3"), type ("available"|"unavailable"|"used"|"header")
-- GetTrainerServiceCost(i) -> copper; GetTrainerServiceLevelReq(i) -> level
-- Returns { ok, reason, rows, byIndex }. rows keep the client's order and original service indexes;
-- category headers are included with header = true.
function Adapter.ReadTrainer(env)
  env = env or _G
  local count = call(env, "GetNumTrainerServices")
  if type(count) ~= "number" then
    return { ok = false, reason = "GetNumTrainerServices unavailable", rows = {}, byIndex = {} }
  end
  local rows, byIndex = {}, {}
  for i = 1, count do
    local name, sub, kind, expanded = call(env, "GetTrainerServiceInfo", i)
    if name ~= nil then
      local row = { index = i, name = name, kind = kind, sub = sub }
      if kind == "header" then
        row.header = true
        row.expanded = expanded and true or false
      else
        row.family = name
        row.rank = parseRank(sub)
        row.cost = (call(env, "GetTrainerServiceCost", i))
        row.level = (call(env, "GetTrainerServiceLevelReq", i))
        row.icon = (call(env, "GetTrainerServiceIcon", i))
        row.available = kind == "available"
        row.learned = kind == "used"
      end
      rows[#rows + 1] = row
      byIndex[i] = row
    end
  end

  return { ok = true, rows = rows, byIndex = byIndex }
end

-- Returns { class = "HUNTER", level = 10 } with nil fields when unreadable.
function Adapter.ReadPlayer(env)
  env = env or _G
  local _, class = call(env, "UnitClass", "player")
  local level = call(env, "UnitLevel", "player")
  return { class = type(class) == "string" and class or nil, level = type(level) == "number" and level or nil }
end

-- GetTalentTabInfo(i): id-first shape (id, name, description, icon, pointsSpent, ...) observed on
-- Classic Era 1.15.9; the older (name, icon, pointsSpent) shape is also accepted.
-- Returns an array indexed by tab: { name = , points = }.
function Adapter.ReadTalentTabs(env)
  env = env or _G
  local tabs = {}
  local count = call(env, "GetNumTalentTabs")
  if type(count) ~= "number" then return tabs end
  for i = 1, count do
    local a, b, c, _, e = call(env, "GetTalentTabInfo", i)
    if a ~= nil then
      local name, points = a, c
      if type(a) == "number" and type(b) == "string" then name, points = b, e end
      tabs[i] = { name = name, points = type(points) == "number" and points or 0 }
    end
  end
  return tabs
end

-- Names of the talents the player has put at least one point into, as a set. Returns nil when the
-- client cannot say, so rules treat every talent as unknown rather than missing.
function Adapter.ReadActiveTalents(env)
  env = env or _G
  local tabCount = call(env, "GetNumTalentTabs")
  if type(tabCount) ~= "number" then return nil end
  local active = {}
  for tab = 1, tabCount do
    local count = call(env, "GetNumTalents", tab)
    for i = 1, type(count) == "number" and count or 0 do
      local name, _, _, _, rank = call(env, "GetTalentInfo", tab, i)
      if type(name) == "string" and type(rank) == "number" and rank > 0 then active[name] = true end
    end
  end
  return active
end

-- The trainer window's type filters. The list only holds rows that pass them, so a row missing from it
-- can only be read as "learned" while both of these are on.
function Adapter.ReadTrainerFilters(env)
  env = env or _G
  local function on(kind)
    local value = call(env, "GetTrainerServiceTypeFilter", kind)
    return value == true or value == 1
  end
  return { available = on("available"), unavailable = on("unavailable"), used = on("used") }
end

function Adapter.ReadNpcName(env)
  env = env or _G
  local name = call(env, "UnitName", "npc")
  return type(name) == "string" and name or nil
end

-- Riding is bought as a spell. Names come from the sources' wording for the two goals ("Apprentice
-- Riding" for the level 40 mount, "Journeyman Riding" for level 60) and are UNVERIFIED on Forever.
-- A spell the player knows is found by name in the spellbook.
local function knows(env, name)
  if type(env.C_Spell) == "table" and type(env.C_Spell.GetSpellInfo) == "function" then
    local ok, info = pcall(env.C_Spell.GetSpellInfo, name)
    if ok and type(info) == "table" and info.name then return true end
  end
  if type(env.GetSpellInfo) == "function" then
    local ok, found = pcall(env.GetSpellInfo, name)
    if ok and found then return true end
  end
  return false
end

function Adapter.ReadRiding(env)
  env = env or _G
  return { apprentice = knows(env, "Apprentice Riding"), journeyman = knows(env, "Journeyman Riding") }
end

-- GetSkillLineInfo(i) -> name, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank
-- (the Classic shape, UNVERIFIED on Forever; the debug report lists the lines it sees).
-- Returns { [lineName] = { skill = , max = } } for every line that is not a category header.
function Adapter.ReadProfessions(env)
  env = env or _G
  local out = {}
  local count = call(env, "GetNumSkillLines")
  if type(count) ~= "number" then return out end
  for i = 1, count do
    local name, isHeader, _, rank, _, _, maxRank = call(env, "GetSkillLineInfo", i)
    if type(name) == "string" and not isHeader and type(rank) == "number" then
      out[name] = { skill = rank, max = type(maxRank) == "number" and maxRank or nil }
    end
  end
  return out
end

-- Does the character know this spell? true or false, or nil when the client cannot say.
-- (C_SpellBook.IsSpellKnown and the older IsSpellKnown both exist on Classic Era 1.15.9.)
function Adapter.IsSpellKnown(env, id)
  env = env or _G
  if type(env.C_SpellBook) == "table" and type(env.C_SpellBook.IsSpellKnown) == "function" then
    local ok, known = pcall(env.C_SpellBook.IsSpellKnown, id)
    if ok then return known == true end
  end
  if type(env.IsSpellKnown) == "function" then
    local ok, known = pcall(env.IsSpellKnown, id)
    if ok then return known == true end
  end
  return nil
end

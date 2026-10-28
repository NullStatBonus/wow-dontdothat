local addonName, ns = ...

-- Looks things up in the bundled spell tables (Data/SpellData.lua, generated from the game's own
-- database tables). Gives spell IDs, so icons and "have I learned this?" come straight from the game
-- instead of waiting for a trainer visit.
local SpellData = {}
ns.SpellData = SpellData

local index = {}

local function classTables(classKey)
  return ns.SpellTables and ns.SpellTables[classKey]
end

function SpellData.Rows(classKey)
  local t = classTables(classKey)
  return t and t.rows or {}
end

-- name -> rows sorted by rank, for one class.
local function byName(classKey)
  if index[classKey] then return index[classKey] end
  local map = {}
  for _, row in ipairs(SpellData.Rows(classKey)) do
    map[row.name] = map[row.name] or {}
    table.insert(map[row.name], row)
  end
  for _, list in pairs(map) do
    table.sort(list, function(a, b) return (a.rank or 0) < (b.rank or 0) end)
  end
  index[classKey] = map
  return map
end

local families = {}

function SpellData.Reset() index, families = {}, {} end

-- A spell family is every rank of one spell, named by the lowest row ID the tables hold for that name in
-- the class. Tables list pet spells under the owning class, and no name repeats across kinds, so a name
-- is unique per class. A saved ID stays valid after the tables are regenerated, because FamilyOfId
-- accepts any ID the family has ever listed (primary or alternate).
local function extraRows(classKey)
  return ns.RuleSpells and ns.RuleSpells[classKey] or {}
end

-- Rows for the families: the trainer tables plus the spells only the rule files name (Data/RuleSpells.lua).
local function familyRows(classKey)
  local rows = {}
  for _, row in ipairs(SpellData.Rows(classKey)) do rows[#rows + 1] = row end
  for _, row in ipairs(extraRows(classKey)) do rows[#rows + 1] = row end
  return rows
end

local function familyIndex(classKey)
  if families[classKey] then return families[classKey] end
  local byNameId, byId, nameOf = {}, {}, {}
  for name, list in pairs(byName(classKey)) do
    local lowest
    for _, row in ipairs(list) do
      for _, id in ipairs(SpellData.Ids(row)) do
        if not lowest or id < lowest then lowest = id end
      end
    end
    byNameId[name], nameOf[lowest] = lowest, name
    for _, row in ipairs(list) do
      for _, id in ipairs(SpellData.Ids(row)) do byId[id] = lowest end
    end
  end
  -- A rule-file spell whose ID the trainer tables already hold is the same spell under another name (Classic
  -- Era and Forever name some spells differently), so its name becomes another name for that family. Any
  -- other ID of that name joins the same family, and a name the tables lack gets a family of its own.
  local fresh = {}
  for _, row in ipairs(extraRows(classKey)) do
    local existing = byId[row.id]
    if existing then
      byNameId[row.name] = byNameId[row.name] or existing
    else
      fresh[row.name] = fresh[row.name] or {}
      table.insert(fresh[row.name], row.id)
    end
  end
  for name, ids in pairs(fresh) do
    table.sort(ids)
    local family = byNameId[name]
    if not family then
      family = ids[1]
      byNameId[name], nameOf[family] = family, name
    end
    for _, id in ipairs(ids) do byId[id] = family end
  end
  families[classKey] = { byName = byNameId, byId = byId, nameOf = nameOf }
  return families[classKey]
end

-- The family ID for a spell name as the rule files write it (English), or nil when the class has no such spell.
function SpellData.FamilyId(classKey, name) return familyIndex(classKey).byName[name] end

-- The family a spell ID belongs to: any row ID or alternate, not only the family ID itself.
function SpellData.FamilyOfId(classKey, id) return familyIndex(classKey).byId[id] end

-- Every family whose English name starts with the prefix, sorted by ID. Rule data writes "~Create Firestone" for
-- the whole line of them (Create Firestone (Lesser), (Greater), ...).
function SpellData.FamiliesWithPrefix(classKey, prefix)
  local out = {}
  for name, id in pairs(familyIndex(classKey).byName) do
    if name:sub(1, #prefix) == prefix then out[#out + 1] = id end
  end
  table.sort(out)
  return out
end

-- The English name of a family, for tests and the debug report. Player-facing names come from the client.
function SpellData.FamilyName(classKey, familyId) return familyIndex(classKey).nameOf[familyId] end

function SpellData.Rank(classKey, name, rank)
  for _, row in ipairs(byName(classKey)[name] or {}) do
    if row.rank == rank then return row end
  end
end

-- Every ID that means this row: the primary plus any alternates.
function SpellData.Ids(row)
  local ids = { row.id }
  for _, alt in ipairs(row.alt or {}) do ids[#ids + 1] = alt end
  return ids
end

local function textureFromClient(env, id)
  if type(env.C_Spell) == "table" and type(env.C_Spell.GetSpellTexture) == "function" then
    local ok, icon = pcall(env.C_Spell.GetSpellTexture, id)
    if ok and icon then return icon end
  end
  if type(env.GetSpellInfo) == "function" then
    local ok, _, _, icon = pcall(env.GetSpellInfo, id)
    if ok and icon then return icon end
  end
  if type(env.GetSpellTexture) == "function" then
    local ok, icon = pcall(env.GetSpellTexture, id)
    if ok and icon then return icon end
  end
end

function SpellData.ClientName(env, id)
  if type(env.C_Spell) == "table" and type(env.C_Spell.GetSpellName) == "function" then
    local ok, name = pcall(env.C_Spell.GetSpellName, id)
    if ok and type(name) == "string" then return name end
  end
  if type(env.GetSpellInfo) == "function" then
    local ok, name = pcall(env.GetSpellInfo, id)
    if ok and type(name) == "table" then name = name.name end
    if ok and type(name) == "string" then return name end
  end
end

-- The name the game shows for a family, in the client's language. Falls back to the English name when the
-- client cannot say.
function SpellData.DisplayName(classKey, familyId, env)
  env = env or _G
  return SpellData.ClientName(env, familyId) or SpellData.FamilyName(classKey, familyId)
end

-- Localized spell name -> family ID for one class, built from the client's own names so a trainer row in any
-- language resolves. A name two families share maps to false (ambiguous), never to a guess. Without a usable
-- GetSpellInfo it holds the English names.
function SpellData.NameMap(classKey, env)
  env = env or _G
  local map = {}
  local fam = familyIndex(classKey)
  local function put(name, id)
    if map[name] == nil then map[name] = id elseif map[name] ~= id then map[name] = false end
  end
  local heard = {}
  for _, row in ipairs(familyRows(classKey)) do
    local family = fam.byId[row.id]
    for _, id in ipairs(SpellData.Ids(row)) do
      local localized = SpellData.ClientName(env, id)
      if localized then put(localized, family); heard[family] = true end
    end
  end
  -- A family the client did not name keeps its English name, so an unreadable client degrades to today's behavior.
  for name, id in pairs(fam.byName) do
    if not heard[id] then put(name, id) end
  end
  return map
end

-- The game's icon for a spell ID (a family ID is the ID of its lowest row, so it names a real spell).
function SpellData.IconFor(id, env)
  return textureFromClient(env or _G, id)
end

-- The price: one seen at a trainer, else the one listed for that trainer (Data/TrainerPrices.lua), else an
-- estimate from the spell's level. Second value is true for anything not seen at a real trainer.
function SpellData.Cost(classKey, row)
  if row.cost then return row.cost, false end
  local listed = ns.TrainerPrices and ns.TrainerPrices[classKey]
  if listed then
    for _, id in ipairs(SpellData.Ids(row)) do
      if listed[id] then return listed[id], true end
    end
  end
  local t = classTables(classKey)
  local table_ = t and t["costByLevel_" .. tostring(row.kind)]
  local cost = table_ and table_[row.level]
  return cost, true
end

-- Services for the ledger. known(row) -> true, false, or nil when the game cannot say.
-- Only spells with a price (seen or estimated) can cost anything, so only those are listed.
function SpellData.Services(classKey, known)
  local out = {}
  for _, rows in pairs(byName(classKey)) do
    for i, row in ipairs(rows) do
      local cost, isEstimate = SpellData.Cost(classKey, row)
      if cost and (row.level or 0) > 1 then
        out[#out + 1] = {
          familyId = familyIndex(classKey).byId[row.id], name = row.name, rank = row.rank, unlockLevel = row.level, cost = cost,
          costIsEstimate = isEstimate,
          learned = known and known(row) or nil, id = row.id,
        }
      end
    end
  end
  table.sort(out, function(a, b)
    if a.name ~= b.name then return a.name < b.name end
    return (a.rank or 0) < (b.rank or 0)
  end)
  return out
end

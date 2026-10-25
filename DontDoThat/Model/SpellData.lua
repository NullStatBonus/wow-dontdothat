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

function SpellData.Reset() index = {} end

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

-- The game's icon for a spell name, found through its lowest-rank ID. Searches every bundled class.
function SpellData.IconFor(name, env)
  env = env or _G
  for classKey in pairs(ns.SpellTables or {}) do
    if type(ns.SpellTables[classKey]) == "table" then
      for _, row in ipairs(byName(classKey)[name] or {}) do
        for _, id in ipairs(SpellData.Ids(row)) do
          local icon = textureFromClient(env, id)
          if icon then return icon end
        end
      end
    end
  end
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
          family = row.name, name = row.name, rank = row.rank, unlockLevel = row.level, cost = cost,
          costIsEstimate = isEstimate,
          learned = known and known(row) or nil, id = row.id,
        }
      end
    end
  end
  table.sort(out, function(a, b)
    if a.family ~= b.family then return a.family < b.family end
    return (a.rank or 0) < (b.rank or 0)
  end)
  return out
end

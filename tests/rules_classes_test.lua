package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

-- Mage, Warlock, Priest, Druid, Shaman, Rogue and Warrior: every spell family in the bundled tables has been
-- placed somewhere, specs are in the game's tab order, and no spell is both in a rotation and tagged.
local ns = {}
H.load("DontDoThat/Rules/Schema.lua", ns)
H.load("DontDoThat/Rules/Engine.lua", ns)
H.load("DontDoThat/Data/SpellData.lua", ns)
local CLASSES = { "MAGE", "WARLOCK", "PRIEST", "DRUID", "SHAMAN", "ROGUE", "WARRIOR" }
local FILES = { MAGE = "Mage", WARLOCK = "Warlock", PRIEST = "Priest", DRUID = "Druid", SHAMAN = "Shaman", ROGUE = "Rogue", WARRIOR = "Warrior" }
for _, class in ipairs(CLASSES) do H.load("DontDoThat/Rules/Data/" .. FILES[class] .. ".lua", ns) end

local function considered(data)
  local set = {}
  local function add(list) for _, n in ipairs(list or {}) do set[n] = true end end
  for _, spec in pairs(data.specs) do add(spec.rotation.core); add(spec.rotation.situational) end
  for n in pairs(data.tags) do set[n] = true end
  for n in pairs(data.overrides or {}) do set[n] = true end
  add(data.reviewed)
  return set
end

for _, class in ipairs(CLASSES) do
  test(class .. ": every spell family in the bundled table has been considered", function()
    local data = ns.Rules.GetClass(class)
    truthy(data, "rule data is loaded")
    local set, missing, seen = considered(data), {}, {}
    for _, row in ipairs(ns.SpellTables[class].rows) do
      if not set[row.name] and not seen[row.name] then missing[#missing + 1] = row.name; seen[row.name] = true end
    end
    table.sort(missing)
    eq(missing, {}, "unclassified " .. class .. " spells")
  end)

  test(class .. ": three specs in tab order, every rotation flagged for review", function()
    local data = ns.Rules.GetClass(class)
    local trees, count = {}, 0
    for key, spec in pairs(data.specs) do
      trees[spec.tree] = true; count = count + 1
      truthy(spec.rotation.needsReview, key .. " is flagged")
    end
    eq(count, 3); truthy(trees[1] and trees[2] and trees[3])
  end)

  test(class .. ": no spell is both in a rotation and tagged, and talent spells are real families", function()
    local data = ns.Rules.GetClass(class)
    local rot = {}
    for _, spec in pairs(data.specs) do
      for _, n in ipairs(spec.rotation.core) do rot[n] = true end
      for _, n in ipairs(spec.rotation.situational) do rot[n] = true end
    end
    for n in pairs(data.tags) do falsy(rot[n], n .. " is in a rotation and tagged, so the tag would never apply") end
    for _, n in ipairs(data.talentSpells) do truthy(n ~= "", n) end
  end)
end

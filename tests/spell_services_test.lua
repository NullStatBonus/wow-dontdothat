local H = require("harness")
local ns = {}
H.load("DontDoThat/Model/SpellData.lua", ns)

ns.SpellTables = { PRIEST = { rows = {
  { id = 1, name = "Smite", rank = 1, level = 1, kind = "class", cost = 10 },
  { id = 2, name = "Smite", rank = 2, level = 6, kind = "class", cost = 100 },
  { id = 3, name = "Lightwell", rank = 1, level = 40, kind = "class", cost = 180 },
  { id = 4, name = "Lightwell", rank = 2, level = 50, kind = "class", cost = 500 },
  { id = 5, name = "Stoneform", rank = nil, level = 1, kind = "racial", cost = 50 },
  { id = 6, name = "Gift of the Naaru", rank = 1, level = 20, kind = "racial", cost = 340 },
  { id = 7, name = "Whatever Effect", rank = 1, level = 20, kind = "effect", cost = 340 },
} } }
ns.Rules = { GetClass = function() return { talentSpells = { 3 } } end }
H.load("DontDoThat/Model/SpellData.lua", ns)

local function names(list)
  local out = {}
  for _, s in ipairs(list) do out[#out + 1] = s.name .. ":" .. tostring(s.rank) end
  return table.concat(out, ",")
end

test("Services lists only class and pet spells, and skips the first rank of a talent", function()
  eq(names(ns.SpellData.Services("PRIEST")), "Lightwell:2,Smite:2")
end)

test("Services keeps false from the spellbook, and leaves learned unset when the game cannot say", function()
  local list = ns.SpellData.Services("PRIEST", function(row) if row.id == 2 then return false end end)
  for _, s in ipairs(list) do if s.name == "Smite" then eq(s.learned, false) end end
  eq(ns.SpellData.Services("PRIEST")[1].learned, nil)
end)

local H = require("harness")

local function fresh(global)
  local ns = { db = { global = global or { icons = {} } } }
  H.load("DontDoThat/Model/Icons.lua", ns)
  return ns
end

test("icons are remembered by name and looked up first", function()
  local ns = fresh()
  ns.Icons.Remember("Arcane Shot", 132213)
  eq(ns.Icons.Lookup("Arcane Shot", {}), 132213)
  ns.Icons.Remember("Arcane Shot", 5)
  eq(ns.Icons.Lookup("Arcane Shot", {}), 5, "a newer icon replaces the old one")
end)

test("a spell not seen at a trainer falls back to the spellbook, then to a question mark", function()
  local ns = fresh()
  eq(ns.Icons.Lookup("Wing Clip", { GetSpellInfo = function() return "Wing Clip", "Rank 1", 132309 end }), 132309)
  eq(ns.Icons.Lookup("Wing Clip", { C_Spell = { GetSpellInfo = function() return { iconID = 7 } end } }), 7)
  eq(ns.Icons.Lookup("Wing Clip", {}), ns.Icons.Fallback)
  eq(ns.Icons.Lookup("Wing Clip", { GetSpellInfo = function() error("no") end }), ns.Icons.Fallback)
end)

test("remembering ignores bad input and works without saved variables", function()
  local ns = fresh()
  ns.Icons.Remember(nil, 1); ns.Icons.Remember("X", nil); ns.Icons.Remember(5, 1)
  eq(next(ns.db.global.icons), nil)
  local bare = { db = nil }
  H.load("DontDoThat/Model/Icons.lua", bare)
  bare.Icons.Remember("X", 1)
  eq(bare.Icons.Lookup("X", {}), bare.Icons.Fallback)
end)

local H = require("harness")

local function fresh(global)
  local ns = { db = { global = global or { icons = {} } } }
  H.load("DontDoThat/Model/Icons.lua", ns)
  return ns
end

test("icons are remembered by spell family ID and looked up first", function()
  local ns = fresh()
  ns.Icons.Remember(3044, 132213)
  eq(ns.Icons.Lookup(3044, {}), 132213)
  ns.Icons.Remember(3044, 5)
  eq(ns.Icons.Lookup(3044, {}), 5, "a newer icon replaces the old one")
end)

test("a spell not seen at a trainer falls back to the spellbook, then to a question mark", function()
  local ns = fresh()
  eq(ns.Icons.Lookup(2974, { GetSpellInfo = function() return "Wing Clip", "Rank 1", 132309 end }), 132309)
  eq(ns.Icons.Lookup(2974, { C_Spell = { GetSpellInfo = function() return { iconID = 7 } end } }), 7)
  eq(ns.Icons.Lookup(2974, {}), ns.Icons.Fallback)
  eq(ns.Icons.Lookup(2974, { GetSpellInfo = function() error("no") end }), ns.Icons.Fallback)
end)

test("remembering ignores bad input and works without saved variables", function()
  local ns = fresh()
  ns.Icons.Remember(nil, 1); ns.Icons.Remember(7, nil); ns.Icons.Remember("X", 1)
  eq(next(ns.db.global.icons), nil)
  local bare = { db = nil }
  H.load("DontDoThat/Model/Icons.lua", bare)
  bare.Icons.Remember(7, 1)
  eq(bare.Icons.Lookup(7, {}), bare.Icons.Fallback)
end)

package.path = "./tests/?.lua;" .. package.path
local T = require("classtest")

local p = T.new("PRIEST", "Priest")

test("priest: shared core is kept for every spec", function()
  for _, specs in ipairs({ { "DISC" }, { "HOLY" }, { "SHADOW" }, {} }) do
    for _, n in ipairs({ "Power Word: Fortitude", "Shadow Word: Pain", "Power Word: Shield", "Renew", "Flash Heal", "Mind Blast", "Lesser Heal", "Heal", "Inner Fire", "Resurrection" }) do
      eq(p.tier(n, specs), "keep", n)
    end
  end
end)

test("priest: Smite is core for Discipline and Holy, and Holy Fire stays low value", function()
  eq(p.tier("Holy Fire", { "HOLY" }), "deferLow"); eq(p.eval("Holy Fire", {}).source, "tag")
  for _, n in ipairs({ "Smite" }) do
    eq(p.tier(n, { "DISC" }), "keep", n); eq(p.tier(n, { "HOLY" }), "keep", n); eq(p.tier(n, {}), "keep", n)
    truthy(p.eval(n, { "SHADOW" }).source ~= "tag", n)
  end
end)

test("priest: Shadow core follows the Shadow spec", function()
  for _, n in ipairs({ "Devouring Plague" }) do
    eq(p.tier(n, { "SHADOW" }), "keep", n)
    truthy(p.tier(n, { "DISC" }) ~= "keep", n)
  end
  eq(p.tier("Mind Flay", { "SHADOW" }, { ["Mind Flay"] = true }), "keep")
  eq(p.tier("Mind Flay", { "DISC" }, { ["Mind Flay"] = true }), "info")
  eq(p.tier("Vampiric Embrace", { "SHADOW" }, { ["Vampiric Embrace"] = true }), "keep")
  eq(p.tier("Shadowform", { "SHADOW" }, { ["Shadowform"] = true }), "keep")
end)

test("priest: talent spells are ignored without the talent", function()
  truthy(p.eval("Mind Flay", { "SHADOW" }, {}).source ~= "rotation")
  truthy(p.eval("Shadowform", { "SHADOW" }, {}).source ~= "rotation")
end)

test("priest: Greater Heal is core for Holy only", function()
  eq(p.tier("Greater Heal", { "HOLY" }), "keep"); eq(p.tier("Greater Heal", { "SHADOW" }), "info")
end)

test("priest: utility spells are optional", function()
  for _, n in ipairs({ "Dispel Magic", "Cure Disease", "Abolish Disease", "Psychic Scream", "Starshards", "Desperate Prayer", "Touch of Weakness" }) do
    eq(p.tier(n, { "SHADOW" }), "info", n)
  end
end)

test("priest: low-value and PvP spells are defer-low-value", function()
  for _, n in ipairs({ "Mana Burn", "Mind Soothe", "Mind Vision", "Fear Ward", "Feedback", "Mind Control", "Holy Fire", "Shackle Undead", "Fade" }) do eq(p.tier(n, { "SHADOW" }), "deferLow", n) end
end)

test("priest: group and endgame spells wait", function()
  for _, n in ipairs({ "Prayer of Fortitude", "Prayer of Spirit", "Shadow Protection", "Prayer of Mending", "Divine Spirit", "Lightwell" }) do
    eq(p.tier(n, { "SHADOW" }), "defer", n)
  end
end)

test("priest: Psychic Scream keeps rank 1 and skips ranks 2 to 4", function()
  truthy(p.tier("Psychic Scream", { "SHADOW" }, nil, 1) ~= "defer")
  for rank = 2, 4 do
    local v = p.eval("Psychic Scream", { "SHADOW" }, nil, rank)
    eq(v.tier, "defer", "r" .. rank); eq(v.source, "skipRank")
  end
end)

test("priest: generated rank skips apply", function()
  for n, ranks in pairs({ ["Renew"] = { 10 }, ["Power Word: Shield"] = { 10 }, ["Inner Fire"] = { 6 } }) do
    for _, r in ipairs(ranks) do
      local v = p.eval(n, { "HOLY" }, nil, r)
      eq(v.tier, "defer", n .. " r" .. r); eq(v.source, "skipRank")
    end
  end
  truthy(p.eval("Renew", { "HOLY" }, nil, 9).source ~= "skipRank")
  truthy(p.eval("Power Word: Shield", { "HOLY" }, nil, 9).source ~= "skipRank")
  truthy(p.eval("Inner Fire", { "HOLY" }, nil, 5).source ~= "skipRank")
  truthy(p.eval("Greater Heal", { "HOLY" }, nil, 5).source ~= "skipRank", "Greater Heal r5 is bought by Icy Veins")
  for _, n in ipairs({ "Renew", "Power Word: Shield", "Inner Fire", "Psychic Scream", "Smite", "Mind Blast" }) do
    truthy(p.eval(n, { "HOLY" }, nil, 1).source ~= "skipRank", n .. " r1 never skipped")
  end
end)

test("priest: Resurrection and the Shadow interrupt are worth buying, the unverified Forever spells are optional", function()
  for _, specs in ipairs({ { "DISC" }, { "HOLY" }, { "SHADOW" }, {} }) do eq(p.tier("Resurrection", specs), "keep") end
  eq(p.tier("Silence", { "SHADOW" }, { Silence = true }), "keep"); truthy(p.eval("Silence", { "SHADOW" }, {}).source ~= "rotation")
  eq(p.tier("Vampiric Touch", { "SHADOW" }), "info"); eq(p.tier("Shadow Word: Death", { "SHADOW" }), "info")
end)

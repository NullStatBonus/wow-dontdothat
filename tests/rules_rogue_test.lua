package.path = "./tests/?.lua;" .. package.path
local T = require("classtest")

local r = T.new("ROGUE", "Rogue")

test("rogue: the shared core is kept for every spec", function()
  for _, spec in ipairs({ "ASSN", "COMBAT", "SUBT" }) do
    for _, n in ipairs({ "Sinister Strike", "Eviscerate", "Slice and Dice", "Stealth", "Garrote", "Cheap Shot",
      "Gouge", "Sap", "Evasion", "Sprint", "Kick", "Vanish", "Kidney Shot" }) do eq(r.tier(n, { spec }), "keep", n .. " " .. spec) end
  end
end)

test("rogue: Backstab is kept for dagger specs and informational for Combat", function()
  eq(r.tier("Backstab", { "ASSN" }), "keep"); eq(r.tier("Backstab", { "SUBT" }), "keep")
  eq(r.tier("Backstab", { "COMBAT" }), "info"); eq(r.tier("Backstab", {}), "keep")
end)

test("rogue: spec-specific spells are judged by the leaning spec", function()
  eq(r.tier("Mutilate", { "ASSN" }), "keep"); truthy(r.tier("Mutilate", { "COMBAT" }) ~= "keep", "Mutilate for Combat")
  eq(r.tier("Ambush", { "SUBT" }), "keep"); truthy(r.tier("Ambush", { "COMBAT" }) ~= "keep", "Ambush for Combat")
  eq(r.tier("Rupture", { "ASSN" }), "keep"); eq(r.tier("Rupture", { "COMBAT" }), "info")
  eq(r.tier("Hemorrhage", { "SUBT" }, { Hemorrhage = true }), "keep")
end)

test("rogue: Gouge and Kick keep rank 1 and skip the higher ranks", function()
  for _, c in ipairs({ { "Gouge", 2, 5 }, { "Kick", 2, 4 } }) do
    eq(r.tier(c[1], { "COMBAT" }, nil, 1), "keep", c[1] .. " r1")
    for rank = c[2], c[3] do
      local v = r.eval(c[1], { "COMBAT" }, nil, rank)
      eq(v.tier, "defer", c[1] .. " r" .. rank); eq(v.source, "skipRank")
    end
  end
end)

test("rogue: expert-guide rank skips follow the generated list", function()
  for _, c in ipairs({ { "Backstab", 9 }, { "Eviscerate", 9 } }) do
    eq(r.eval(c[1], { "SUBT" }, nil, c[2]).source, "skipRank", c[1] .. " r" .. c[2])
  end
  for _, c in ipairs({ { "Backstab", 1 }, { "Backstab", 7 }, { "Backstab", 8 }, { "Eviscerate", 1 }, { "Eviscerate", 8 }, { "Ambush", 6 }, { "Sinister Strike", 8 } }) do
    truthy(r.eval(c[1], { "SUBT" }, nil, c[2]).source ~= "skipRank", c[1] .. " r" .. c[2])
  end
end)

test("rogue: utility tools are optional", function()
  for _, n in ipairs({ "Pick Pocket", "Blind", "Safe Fall", "Crippling Poison" }) do eq(r.tier(n, { "COMBAT" }), "info", n) end
  eq(r.tier("Distract", { "COMBAT" }), "deferLow"); eq(r.eval("Distract", {}).source, "tag")
  eq(r.tier("Kick", { "COMBAT" }, nil, 1), "keep")
end)

test("rogue: Expose Armor, Feint and trap tools are defer-low-value", function()
  for _, n in ipairs({ "Expose Armor", "Feint", "Detect Traps", "Disarm Trap" }) do eq(r.tier(n, { "COMBAT" }), "deferLow", n) end
end)

test("rogue: Instant and Deadly Poison are kept, other poisons are defer-low-value", function()
  eq(r.tier("Instant Poison II", { "COMBAT" }), "keep"); eq(r.tier("Deadly Poison III", { "ASSN" }), "keep")
  eq(r.tier("Wound Poison II", { "COMBAT" }), "deferLow"); eq(r.tier("Mind-numbing Poison II", { "COMBAT" }), "deferLow")
  eq(r.eval("Dual Wield", {}).source, "override")
end)

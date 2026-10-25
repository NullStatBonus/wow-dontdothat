package.path = "./tests/?.lua;" .. package.path
local T = require("classtest")

local m = T.new("MAGE", "Mage")

test("mage: core spells are kept for every spec", function()
  for _, specs in ipairs({ { "ARCANE" }, { "FIRE" }, { "FROST" }, {} }) do
    for _, n in ipairs({ "Arcane Intellect", "Conjure Food", "Conjure Water", "Frost Nova", "Polymorph", "Blink", "Frost Armor", "Ice Armor", "Mage Armor" }) do
      eq(m.tier(n, specs), "keep", n)
    end
  end
end)

test("mage: spec core follows the spec, and undecided talents keep everything", function()
  eq(m.tier("Fireball", { "FIRE" }), "keep"); eq(m.tier("Frostbolt", { "FROST" }), "keep")
  eq(m.tier("Fireball", {}), "keep"); eq(m.tier("Frostbolt", {}), "keep")
  eq(m.tier("Scorch", {}), "deferLow"); eq(m.tier("Arcane Missiles", {}), "keep")
  local v = m.eval("Fireball", { "FROST" })
  eq(v.tier, "deferLow"); eq(v.source, "rotation")
  eq(m.tier("Cone of Cold", { "FROST" }), "keep"); eq(m.tier("Cone of Cold", { "FIRE" }), "deferLow")
  eq(m.tier("Scorch", { "FIRE" }), "deferLow")
  eq(m.tier("Arcane Missiles", { "ARCANE" }), "keep"); eq(m.tier("Arcane Missiles", { "FIRE" }), "deferLow")
  eq(m.tier("Flamestrike", { "FIRE" }), "keep"); eq(m.tier("Blizzard", { "FROST" }), "keep")
end)

test("mage: Scorch, Pyroblast and Blast Wave stay low value, Arcane Missiles is Arcane core", function()
  for _, n in ipairs({ "Scorch", "Pyroblast", "Blast Wave" }) do
    local v = m.eval(n, { "FIRE" }, { Pyroblast = true, ["Blast Wave"] = true })
    eq(v.tier, "deferLow", n); eq(v.source, "tag", n)
  end
  eq(m.tier("Arcane Missiles", { "ARCANE" }), "keep"); eq(m.eval("Arcane Missiles", { "FIRE" }).source, "rotation")
end)

test("mage: Counterspell, the interrupt, is worth buying for every spec", function()
  for _, specs in ipairs({ { "ARCANE" }, { "FIRE" }, { "FROST" }, {} }) do eq(m.tier("Counterspell", specs), "keep") end
end)

test("mage: Dampen Magic, Amplify Magic and the Wards are defer-low-value with a plain reason", function()
  for _, n in ipairs({ "Dampen Magic", "Amplify Magic", "Fire Ward", "Frost Ward", "Polymorph: Cow" }) do
    local v = m.eval(n, { "FIRE" })
    eq(v.tier, "deferLow", n); truthy(v.reason ~= "", n)
  end
end)

test("mage: Teleports are optional, Portals and Arcane Brilliance wait", function()
  eq(m.eval("Teleport: Stormwind", { "FROST" }).source, "rotation")
  eq(m.tier("Teleport: Stormwind", { "FROST" }), "info")
  eq(m.tier("Portal: Stormwind", { "FROST" }), "defer")
  eq(m.tier("Arcane Brilliance", { "FROST" }), "defer")
end)

test("mage: skipped ranks come only from the expert guides", function()
  eq(m.tier("Pyroblast", { "FIRE" }, nil, 2), "defer")
  truthy(m.tier("Pyroblast", { "FIRE" }, nil, 3) ~= "defer")
  truthy(m.tier("Cone of Cold", { "FROST" }, nil, 4) ~= "defer")
  truthy(m.tier("Flamestrike", { "FIRE" }, nil, 5) ~= "defer")
  eq(m.tier("Frostbolt", { "FROST" }, nil, 11), "defer")
  eq(m.tier("Conjure Food", { "FROST" }, nil, 7), "defer")
  truthy(m.tier("Fireball", { "FROST" }, nil, 5) ~= "defer")
end)

test("mage: rank 1 is never skipped", function()
  for _, n in ipairs({ "Pyroblast", "Frostbolt", "Fireball", "Cone of Cold" }) do
    truthy(m.tier(n, { "FROST" }, nil, 1) ~= "defer", n)
  end
end)

test("mage: Ice Barrier counts only once its talent is active", function()
  truthy(m.eval("Ice Barrier", { "FROST" }, {}).source ~= "rotation")
  eq(m.tier("Ice Barrier", { "FROST" }, { ["Ice Barrier"] = true }), "keep")
end)

test("mage: Frostbolt ranks 1-10 and Frost Nova ranks are never skipped", function()
  for rank = 1, 10 do truthy(m.tier("Frostbolt", { "FROST" }, nil, rank) ~= "defer", "Frostbolt r" .. rank) end
  for rank = 1, 4 do truthy(m.tier("Frost Nova", { "FROST" }, nil, rank) ~= "defer", "Frost Nova r" .. rank) end
end)

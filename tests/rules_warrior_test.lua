package.path = "./tests/?.lua;" .. package.path
local T = require("classtest")

local w = T.new("WARRIOR", "Warrior")

test("warrior: the essential attacks and utility are kept", function()
  for _, n in ipairs({ "Heroic Strike", "Battle Shout", "Rend", "Charge", "Overpower", "Execute", "Bloodrage", "Sunder Armor" }) do
    eq(w.tier(n, { "ARMS" }), "keep", n)
  end
end)

test("warrior: Hamstring, Pummel and Shield Bash are kept for every spec, Thunder Clap and Slam are low value", function()
  for _, spec in ipairs({ "ARMS", "FURY", "PROT" }) do
    for _, n in ipairs({ "Hamstring", "Pummel", "Shield Bash" }) do eq(w.tier(n, { spec }, nil, n == "Shield Bash" and 1 or nil), "keep", spec .. " " .. n) end
    eq(w.tier("Thunder Clap", { spec }), "deferLow", spec); eq(w.tier("Slam", { spec }), "deferLow", spec)
  end
end)

test("warrior: Fury and Protection spells follow the chosen spec", function()
  eq(w.tier("Whirlwind", { "FURY" }), "keep"); eq(w.tier("Whirlwind", { "ARMS" }), "info")
  eq(w.tier("Berserker Stance", { "FURY" }), "keep"); eq(w.tier("Defensive Stance", { "PROT" }), "keep")
  eq(w.tier("Cleave", { "FURY" }), "keep"); eq(w.tier("Cleave", { "ARMS" }), "info")
  truthy(w.eval("Taunt", { "ARMS" }).tier ~= "keep")
end)

test("warrior: PvP and group-only spells wait", function()
  eq(w.tier("Disarm", { "ARMS" }), "deferLow"); eq(w.tier("Intimidating Shout", { "ARMS" }), "deferLow")
  eq(w.tier("Challenging Shout", { "ARMS" }), "defer")
end)

test("warrior: ranks the Wowhead and Icy Veins guides skip are skipped, and rank 1 never is", function()
  local skips = { ["Heroic Strike"] = { 9, 9 }, ["Rend"] = { 5, 7 }, ["Overpower"] = { 2, 4 }, ["Thunder Clap"] = { 2, 6 },
    ["Cleave"] = { 2, 5 }, ["Mocking Blow"] = { 2, 5 }, ["Intercept"] = { 2, 3 }, ["Pummel"] = { 2, 2 },
    ["Slam"] = { 2, 5 } }
  for name, r in pairs(skips) do
    for rank = r[1], r[2] do eq(w.eval(name, { "ARMS" }, nil, rank).source, "skipRank", name .. " r" .. rank) end
    truthy(w.eval(name, { "ARMS" }, nil, 1).source ~= "skipRank", name .. " r1")
    truthy(w.eval(name, { "ARMS" }, nil, r[1] - 1).source ~= "skipRank", name .. " r" .. (r[1] - 1))
  end
end)

test("warrior: Shield Bash keeps rank 1 and skips ranks 2 and 3, Demoralizing Shout is never skipped", function()
  truthy(w.tier("Shield Bash", { "ARMS" }, nil, 1) ~= "defer")
  for rank = 2, 3 do
    local v = w.eval("Shield Bash", { "ARMS" }, nil, rank)
    eq(v.tier, "defer", "r" .. rank); eq(v.source, "skipRank")
  end
  for rank = 1, 5 do truthy(w.tier("Demoralizing Shout", { "ARMS" }, nil, rank) ~= "defer", "Demoralizing Shout r" .. rank) end
end)

test("warrior: spec abilities need their talent", function()
  truthy(w.eval("Mortal Strike", { "ARMS" }, {}).source ~= "rotation")
  eq(w.tier("Mortal Strike", { "ARMS" }, { ["Mortal Strike"] = true }), "keep")
  eq(w.tier("Revenge", { "PROT" }), "keep"); truthy(w.tier("Revenge", { "ARMS" }) ~= "keep")
  eq(w.eval("Plate Mail", {}).source, "override")
end)

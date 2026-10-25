package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = {}
H.load("DontDoThat/Rules/Schema.lua", ns)
H.load("DontDoThat/Rules/Engine.lua", ns)
H.load("DontDoThat/Rules/Data/Herbalism.lua", ns)
H.load("DontDoThat/Rules/Data/Skinning.lua", ns)

local function eval(prof, tierName, skill, max, state)
  return ns.Rules.Evaluate({
    class = "HUNTER", professions = { [prof] = { skill = skill, max = max } },
    milestone = { current = 40, state = state or "active" },
  }, { kind = "recipeTier", name = tierName, profession = prof })
end

test("professions: tier flagged while skill is far from cap", function()
  local v = eval("Herbalism", "Journeyman", 30, 75)
  eq(v.tier, "defer"); eq(v.cost, 500); eq(v.costIsEstimate, true)
  eq(v.reason, "Your Herbalism skill is 30 of 75. You won't need Journeyman until you're closer to the cap.")
  eq(eval("Skinning", "Expert", 100, 150).tier, "defer")
end)

test("professions: not flagged near the cap", function()
  eq(eval("Herbalism", "Journeyman", 60, 75).tier, "keep")
  eq(eval("Skinning", "Journeyman", 75, 75).tier, "keep")
end)

test("professions: unknown profession or tier is keep; finished deferral keeps", function()
  eq(eval("Herbalism", "Grandmaster", 1, 75).tier, "keep")
  eq(ns.Rules.Evaluate({ professions = {}, milestone = { state = "active" } }, { kind = "recipeTier", name = "Journeyman", profession = "Herbalism" }).tier, "keep")
  eq(eval("Herbalism", "Journeyman", 30, 75, "finished").tier, "keep")
end)

test("professions: all four tiers present", function()
  local d = ns.Rules.GetProfession("Skinning")
  eq(#d.tiers, 4)
  eq(d.tiers[1].name, "Apprentice"); eq(d.tiers[4].name, "Artisan")
end)

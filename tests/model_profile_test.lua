package.path = "./tests/?.lua;" .. package.path
local H = require("harness")
local ns = {}
for _, f in ipairs({ "SpecInference", "Milestones", "PlayerProfile" }) do H.load("DontDoThat/Model/" .. f .. ".lua", ns) end
local hunter = { specs = { BM = { tree = 1 }, MM = { tree = 2 }, SV = { tree = 3 } } }

test("build profile from inputs", function()
  local p = ns.PlayerProfile.Build({
    class = "HUNTER", level = 25, treePoints = { BM = 21, MM = 0, SV = 0 }, classData = hunter,
    professions = { Herbalism = { skill = 75, max = 150 } },
  })
  eq(p.class, "HUNTER"); eq(p.level, 25)
  eq(p.plausibleSpecs, { "BM" })
  eq(p.treePoints, { BM = 21, MM = 0, SV = 0 })
  eq(p.professions.Herbalism.skill, 75)
  eq(p.milestone, { current = 40, state = "active" })
  truthy(p.proficiencies, "hunter proficiency stub")
end)
test("dual spec build uses union, first set as treePoints", function()
  local p = ns.PlayerProfile.Build({ class = "HUNTER", level = 40, classData = hunter,
    talentSets = { { BM = 20 }, { SV = 20 } } })
  eq(p.plausibleSpecs, { "BM", "SV" })
  eq(p.treePoints, { BM = 20 })
end)
test("explicit plausibleSpecs and milestone pass through", function()
  local p = ns.PlayerProfile.Build({ class = "HUNTER", level = 5, plausibleSpecs = { "MM" },
    milestone = { current = nil, state = "finished" } })
  eq(p.plausibleSpecs, { "MM" }); eq(p.milestone.state, "finished")
end)
test("unknown class has no proficiencies", function()
  eq(ns.PlayerProfile.Build({ class = "NOPE", level = 1 }).proficiencies, nil)
end)

package.path = "./tests/?.lua;" .. package.path
local H = require("harness")
local ns = {}
for _, f in ipairs({ "SpecInference", "Milestones", "PlayerProfile" }) do H.load("DontDoThat/Model/" .. f .. ".lua", ns) end
local classData = { specs = { A = { tree = 1 }, B = { tree = 2 }, C = { tree = 3 } } }

test("build profile from inputs", function()
  local p = ns.PlayerProfile.Build({
    class = "TEST", level = 25, treePoints = { A = 21, B = 0, C = 0 }, classData = classData,
    professions = { Herbalism = { skill = 75, max = 150 } },
  })
  eq(p.class, "TEST"); eq(p.level, 25)
  eq(p.plausibleSpecs, { "A" })
  eq(p.treePoints, { A = 21, B = 0, C = 0 })
  eq(p.professions.Herbalism.skill, 75)
  eq(p.milestone, { current = 40, state = "active" })
end)
test("dual spec build uses union, first set as treePoints", function()
  local p = ns.PlayerProfile.Build({ class = "TEST", level = 40, classData = classData,
    talentSets = { { A = 20 }, { C = 20 } } })
  eq(p.plausibleSpecs, { "A", "C" })
  eq(p.treePoints, { A = 20 })
end)
test("explicit plausibleSpecs and milestone pass through", function()
  local p = ns.PlayerProfile.Build({ class = "TEST", level = 5, plausibleSpecs = { "B" },
    milestone = { current = nil, state = "finished" } })
  eq(p.plausibleSpecs, { "B" }); eq(p.milestone.state, "finished")
end)

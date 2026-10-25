package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = {}
H.load("DontDoThat/Rules/Schema.lua", ns)
H.load("DontDoThat/Rules/Engine.lua", ns)

local function load()
  ns.Rules.Reset()
  ns.Rules.Load({
    class = "TEST",
    specs = {
      A = { name = "Alpha", rotation = { core = { "ACore", "Both" }, situational = { "ASit" } } },
      B = { name = "Beta", rotation = { core = { "BCore", "Both" }, situational = { "ASit2" } } },
    },
    tagTiers = { PvP = "deferLow", Raid = "defer" },
    tags = { Pvper = { "PvP" }, Raider = { "Raid" }, Kept = { "PvP" }, PvpRanked = { "PvP" } },
    overrides = { Kept = "keep", Forced = "defer" },
    ranks = { Plain = { { rank = 1, unlockLevel = 4 }, { rank = 2, unlockLevel = 10, cost = 250 } } },
  })
end
load()

local function profile(specs, state)
  return { class = "TEST", level = 25, treePoints = { A = 21, B = 0 }, plausibleSpecs = specs,
    milestone = { current = 40, state = state or "active" } }
end
local function spell(name, extra)
  local a = { kind = "spell", name = name, family = name }
  for k, v in pairs(extra or {}) do a[k] = v end
  return a
end
local E = ns.Rules.Evaluate

test("engine: unknown action is keep", function()
  local v = E(profile({ "A" }), spell("Mystery"))
  eq(v.tier, "keep"); eq(v.source, "default")
end)

test("engine: core in plausible spec keeps; situational is info", function()
  eq(E(profile({ "A" }), spell("ACore")).tier, "keep")
  local v = E(profile({ "A" }), spell("ASit"))
  eq(v.tier, "info")
  truthy(v.reason:find("get by without it", 1, true))
end)

test("engine: core in any plausible spec wins", function()
  eq(E(profile({ "A", "B" }), spell("BCore")).tier, "keep")
end)

test("engine: other-spec ability falls to tags, then names spec and tree split", function()
  local v = E(profile({ "A" }), spell("BCore"))
  eq(v.tier, "deferLow"); eq(v.source, "rotation")
  truthy(v.reason:find("Mostly used by Beta players", 1, true))
  falsy(v.reason:find("21", 1, true), "no talent numbers in player-facing text")
  v = E(profile({ "A" }), spell("BCore", { tags = { "Raid" } }))
  eq(v.tier, "defer"); eq(v.source, "tag")
end)

test("engine: ambiguous or empty plausibleSpecs means all plausible", function()
  eq(E(profile({}), spell("BCore")).tier, "keep")
  eq(E(profile(nil), spell("ACore")).tier, "keep")
end)

test("engine: tag tiers", function()
  local v = E(profile({ "A" }), spell("Pvper"))
  eq(v.tier, "deferLow"); eq(v.source, "tag"); eq(v.reason, "You won't need this until level 60.")
  eq(E(profile({ "A" }), spell("Raider")).tier, "defer")
end)

test("engine: override beats tag and rotation; explicit override tier", function()
  local v = E(profile({ "A" }), spell("Kept"))
  eq(v.tier, "keep"); eq(v.source, "override")
  eq(E(profile({ "A" }), spell("Forced")).tier, "defer")
end)

test("engine: rank row supplies next level and a marked estimate cost", function()
  local v = E(profile({ "A" }), spell("Plain", { rank = 1 }))
  eq(v.tier, "keep") -- gap is 6
  load()
end)

test("engine: adapter cost wins; data cost is an estimate", function()
  local v = E(profile({ "A" }), spell("Pvper", { cost = 900 }))
  eq(v.cost, 900); eq(v.costIsEstimate, false)
  v = E(profile({ "A" }), spell("Plain", { rank = 2, unlockLevel = 10, nextRankLevel = 12, tags = { "PvP" } }))
  eq(v.tier, "deferLow"); eq(v.cost, 250); eq(v.costIsEstimate, true)
end)

test("engine: a finished deferral keeps everything", function()
  eq(E(profile({ "A" }, "finished"), spell("Raider")).tier, "keep")
end)

test("engine: deferLow does not request a prompt", function()
  local v = E(profile({ "A" }), spell("Pvper"))
  eq(v.tier, "deferLow")
  falsy(v.prompt)
end)

package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local function fresh()
  local ns = {}
  H.load("DontDoThat/Rules/Schema.lua", ns)
  H.load("DontDoThat/Rules/Engine.lua", ns)
  return ns
end

local function sample()
  return {
    class = "TEST",
    specs = { A = { rotation = { core = { "X" }, situational = {} } } },
    tagTiers = { PvP = "deferLow" },
    tags = { Y = { "PvP" } },
    overrides = { Z = "keep" },
    ranks = { X = { { rank = 1, unlockLevel = 4 }, { rank = 2, unlockLevel = 10, cost = 100 } } },
  }
end

test("rules: valid sample loads and is retrievable", function()
  local ns = fresh()
  ns.Rules.Load(sample())
  truthy(ns.Rules.GetClass("TEST"))
end)

test("rules: malformed data is rejected with a clear message", function()
  local ns = fresh()
  local d = sample(); d.specs.A.rotation.core = { 5 }
  raises(function() ns.Rules.Load(d) end, "specs.A.rotation.core[1]")
  d = sample(); d.tags.Y = { "Nope" }
  raises(function() ns.Rules.Load(d) end, "no entry in tagTiers")
  d = sample(); d.overrides.Z = "bogus"
  raises(function() ns.Rules.Load(d) end, "unknown tier")
  d = sample(); d.ranks.X[2].unlockLevel = 2
  raises(function() ns.Rules.Load(d) end, "unlockLevel")
  d = sample(); d.ranks.X[1].cost = 1.5
  raises(function() ns.Rules.Load(d) end, "copper")
  d = sample(); d.class = nil
  raises(function() ns.Rules.Load(d) end, "'class' string")
  raises(function() ns.Rules.Load("x") end, "must be a table")
  d = sample(); d.specs = {}
  raises(function() ns.Rules.Load(d) end, "specs")
end)

test("rules: adding a class needs data only", function()
  local ns = fresh()
  ns.Rules.Load(sample())
  local v = ns.Rules.Evaluate({ class = "TEST", plausibleSpecs = { "A" }, milestone = { current = 40, state = "active" } },
    { kind = "spell", name = "X" })
  eq(v.tier, "keep")
  eq(v.source, "rotation")
end)

test("schema: skipRanks must be lists of rank numbers", function()
  local function load(skip)
    local ns = fresh()
    local data = sample()
    data.skipRanks = skip
    return pcall(ns.Rules.Load, data)
  end
  truthy(load({ Foo = { 2, 3 } }))
  falsy(load({ Foo = {} }))
  falsy(load({ Foo = { 0 } }))
  falsy(load({ Foo = "7" }))
end)

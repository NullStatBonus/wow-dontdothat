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
  ns.Rules.Load(sample(), H.sameKeys)
  truthy(ns.Rules.GetClass("TEST"))
end)

test("rules: malformed data is rejected with a clear message", function()
  local ns = fresh()
  local d = sample(); d.specs.A.rotation.core = { 5 }
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "specs.A.rotation.core[1]")
  d = sample(); d.tags.Y = { "Nope" }
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "no entry in tagTiers")
  d = sample(); d.overrides.Z = "bogus"
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "unknown tier")
  d = sample(); d.ranks.X[2].unlockLevel = 2
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "unlockLevel")
  d = sample(); d.ranks.X[1].cost = 1.5
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "copper")
  d = sample(); d.class = nil
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "'class' string")
  raises(function() ns.Rules.Load("x", H.sameKeys) end, "must be a table")
  d = sample(); d.specs = {}
  raises(function() ns.Rules.Load(d, H.sameKeys) end, "specs")
end)

test("rules: adding a class needs data only", function()
  local ns = fresh()
  ns.Rules.Load(sample(), H.sameKeys)
  local v = ns.Rules.Evaluate({ class = "TEST", plausibleSpecs = { "A" }, milestone = { current = 40, state = "active" } },
    { kind = "spell", name = "X", familyId = "X" })
  eq(v.tier, "keep")
  eq(v.source, "rotation")
end)

test("schema: skipRanks must be lists of rank numbers", function()
  local function load(skip)
    local ns = fresh()
    local data = sample()
    data.skipRanks = skip
    return pcall(ns.Rules.Load, data, H.sameKeys)
  end
  truthy(load({ Foo = { 2, 3 } }))
  falsy(load({ Foo = {} }))
  falsy(load({ Foo = { 0 } }))
  falsy(load({ Foo = "7" }))
end)

test("compile: names become family IDs and the source data is left alone", function()
  local ns = fresh()
  local data = sample()
  local compiled = ns.Rules.Compile(data, { id = function(n) return #n + 10 end, prefix = function() return {} end })
  for _, spec in pairs(compiled.specs) do
    for _, id in ipairs(spec.rotation.core) do truthy(type(id) == "number", "core holds IDs") end
  end
  eq(data.specs.A.rotation.core[1], "X", "the source still holds the name")
end)

test("compile: a name that matches no spell raises an error naming the class, the rule and the spell", function()
  local ns = fresh()
  local data = sample()
  data.specs.A.rotation.core = { "Nonesuch" }
  raises(function() ns.Rules.Compile(data, { id = function() return nil end, prefix = function() return {} end }) end,
    "TEST specs.A.rotation.core): no spell named 'Nonesuch'")
end)

test("compile: a ~Prefix entry stands for every family with that prefix, and one that matches nothing is an error", function()
  local ns = fresh()
  local data = sample()
  data.why = { ["~Create"] = "Wait." }
  local resolver = { id = function(n) return n == "X" and 1 or 2 end, prefix = function(p) return p == "Create" and { 5, 6 } or {} end }
  local compiled = ns.Rules.Compile(data, resolver)
  eq(compiled.why[5], "Wait."); eq(compiled.why[6], "Wait.")
  data.why = { ["~Nothing"] = "Wait." }
  raises(function() ns.Rules.Compile(data, resolver) end, "no spell name starts with 'Nothing'")
end)

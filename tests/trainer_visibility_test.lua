package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = {}
H.load("DontDoThat/Rules/Schema.lua", ns)
H.load("DontDoThat/Rules/Engine.lua", ns)
H.load("DontDoThat/Rules/Data/Hunter.lua", ns)
H.load("DontDoThat/Model/TrainerVisibility.lua", ns)
local TV = ns.TrainerVisibility

local function rows(tiers)
  local out = {}
  for i, tier in ipairs(tiers) do out[i] = { index = 100 + i, name = "S" .. i, tier = tier } end
  return out
end
local function byTier(service) return { tier = service.tier } end

test("flagged rows are hidden when the filter is on", function()
  local r = TV.Compute(rows({ "defer", "deferLow", "keep" }), byTier, { enabled = true })
  eq(#r.visible, 1)
  eq(r.visible[1].name, "S3")
  eq(r.hiddenCount, 2)
end)

test("keep and informational rows stay", function()
  local r = TV.Compute(rows({ "keep", "info", "keep" }), byTier, { enabled = true })
  eq(#r.visible, 3)
  eq(r.hiddenCount, 0)
end)

test("filter unchecked shows every row", function()
  local r = TV.Compute(rows({ "defer", "deferLow", "keep" }), byTier, { enabled = false })
  eq(#r.visible, 3)
  eq(r.hiddenCount, 0)
end)

test("no options means no filtering", function()
  eq(#TV.Compute(rows({ "defer" }), byTier).visible, 1)
end)

test("a visible row resolves to the service index it displays", function()
  local r = TV.Compute(rows({ "defer", "keep", "deferLow", "info", "keep" }), byTier, { enabled = true })
  eq(#r.visible, 3)
  eq(TV.IndexAt(r, 1), 102)
  eq(TV.IndexAt(r, 2), 104)
  eq(TV.IndexAt(r, 3), 105)
  eq(TV.IndexAt(r, 4), nil)
end)

test("order is preserved and services are not copied or renumbered", function()
  local input = rows({ "keep", "defer", "info" })
  local r = TV.Compute(input, byTier, { enabled = true })
  truthy(r.visible[1] == input[1] and r.visible[2] == input[3], "same table objects, original order")
end)

test("services without an index fall back to their list position", function()
  local r = TV.Compute({ { tier = "keep" }, { tier = "defer" }, { tier = "keep" } }, byTier, { enabled = true })
  eq(TV.IndexAt(r, 2), 3)
end)

test("already learned services are never hidden", function()
  local input = rows({ "defer", "defer" })
  input[1].learned = true
  local r = TV.Compute(input, byTier, { enabled = true })
  eq(#r.visible, 1)
  truthy(r.visible[1] == input[1])
  eq(r.hiddenCount, 1)
end)

test("a failing evaluation fails open", function()
  local r = TV.Compute(rows({ "defer", "defer" }), function(s)
    if s.name == "S1" then error("boom") end
    return { tier = "defer" }
  end, { enabled = true })
  eq(#r.visible, 1)
  eq(r.visible[1].name, "S1")
  eq(r.errors, 1)
  eq(r.hiddenCount, 1)
end)

test("a header whose rows are all hidden disappears, others stay", function()
  local list = {
    { index = 1, header = true, name = "Beast Mastery" },
    { index = 2, tier = "defer" },
    { index = 3, tier = "deferLow" },
    { index = 4, header = true, name = "Marksmanship" },
    { index = 5, tier = "keep" },
    { index = 6, tier = "defer" },
    { index = 7, header = true, name = "Survival" },
    { index = 8, tier = "defer" },
  }
  local r = TV.Compute(list, byTier, { enabled = true })
  eq(#r.visible, 2)
  eq(r.visible[1].index, 4)
  eq(r.visible[2].index, 5)
  eq(r.hiddenCount, 4, "headers are not counted")
  eq(TV.IndexAt(r, 2), 5)
end)

test("headers all stay when the filter is off", function()
  local list = { { header = true }, { tier = "defer" } }
  eq(#TV.Compute(list, byTier, { enabled = false }).visible, 2)
end)

test("empty or nil service list is handled", function()
  eq(TV.Compute({}, byTier, { enabled = true }).hiddenCount, 0)
  eq(#TV.Compute(nil, byTier, { enabled = true }).visible, 0)
end)

-- With the real engine and Hunter data.

local function profile(state)
  return { class = "HUNTER", level = 25, treePoints = { BM = 21, MM = 0, SV = 0 }, plausibleSpecs = { "BM" },
    milestone = { current = 40, state = state } }
end
local function hunterRows()
  local out = {}
  for i, name in ipairs({ "Serpent Sting", "Distracting Shot", "Scatter Shot", "Arcane Shot" }) do
    out[i] = { index = i, name = name, action = { kind = "spell", name = name, family = name } }
  end
  return out
end

test("with the Hunter rules, defer and PvP rows are hidden", function()
  local p = profile("active")
  local r = TV.Compute(hunterRows(), function(s) return ns.Rules.Evaluate(p, s.action) end, { enabled = true })
  eq(#r.visible, 2)
  eq(r.visible[1].name, "Serpent Sting")
  eq(r.visible[2].name, "Arcane Shot")
  eq(r.hiddenCount, 2)
end)

test("a finished deferral hides nothing", function()
  local p = profile("finished")
  local r = TV.Compute(hunterRows(), function(s) return ns.Rules.Evaluate(p, s.action) end, { enabled = true })
  eq(#r.visible, 4)
  eq(r.hiddenCount, 0)
end)

test("an unsupported class hides nothing", function()
  local p = profile("active")
  p.class = "MAGE"
  local r = TV.Compute(hunterRows(), function(s) return ns.Rules.Evaluate(p, s.action) end, { enabled = true })
  eq(#r.visible, 4)
end)

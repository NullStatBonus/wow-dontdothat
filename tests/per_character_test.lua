package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local function settings()
  local ns = {}
  H.load("DontDoThat/Model/Settings.lua", ns)
  return ns
end

test("shared mount marks move only to characters at that level", function()
  local S = settings().Settings
  local shared = { milestoneOverride = { [40] = true, [60] = true }, professionAsked = { [3908] = true } }
  local main, alt, mid = {}, {}, {}
  S.MigrateCharMarks(main, shared, 60)
  eq(main.milestoneOverride, { [40] = true, [60] = true })
  S.MigrateCharMarks(alt, shared, 25)
  eq(alt.milestoneOverride, nil, "a level 25 alt cannot have its level 40 mount")
  S.MigrateCharMarks(mid, shared, 45)
  eq(mid.milestoneOverride, { [40] = true })
  eq(alt.professionAsked, nil, "profession answers are not copied")
  truthy(alt.migratedMarks)
end)

test("migration runs once per character", function()
  local S = settings().Settings
  local c = {}
  S.MigrateCharMarks(c, { milestoneOverride = {} }, 60)
  S.MigrateCharMarks(c, { milestoneOverride = { [60] = true } }, 60)
  eq(c.milestoneOverride, nil, "a mark set later in the shared profile is not copied")
end)

test("marks and profession answers are read from this character", function()
  local ns = settings()
  ns.db = { profile = { milestoneOverride = { [40] = true }, professionAsked = { [3908] = true } }, char = {} }
  eq(ns.Settings.MilestoneOverride(), nil)
  eq(ns.Settings.ProfessionAsked(), nil)
  ns.Settings.MarkProfessionAsked(2108)
  eq(ns.db.char.professionAsked, { [2108] = true })
  eq(ns.db.profile.professionAsked, { [3908] = true }, "the shared value is left alone")
end)

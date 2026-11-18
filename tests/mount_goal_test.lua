package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local GOLD = 10000

local function fresh()
  local ns = { version = "0.1.0" }
  for _, f in ipairs({ "UI/Helpers.lua", "Data/Sounds.lua", "Data/SpellData.lua", "Data/RuleSpells.lua", "Data/SkipRevisions.lua",
    "Data/TalentData.lua", "Model/SpellData.lua", "Rules/Schema.lua", "Rules/Engine.lua", "Rules/Data/Hunter.lua",
    "Rules/Data/Paladin.lua", "Rules/Data/Warlock.lua", "Model/Milestones.lua", "Intercepts/Adapter.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  return ns
end

test("the client is told by its interface number", function()
  local M = fresh().Milestones
  eq(M.Client({ GetBuildInfo = function() return "1.15.9", "70576", "", 11509 end }), "era")
  eq(M.Client({ GetBuildInfo = function() return "1.60.1", "70790", "", 16001 end }), "forever")
  eq(M.Client({}), "forever", "unknown keeps the Forever goals")
end)

test("default goals per client", function()
  local M = fresh().Milestones
  eq(M.Goal(40, "HUNTER", "era"), 100 * GOLD)
  eq(M.Goal(60, "HUNTER", "era"), 1000 * GOLD)
  eq(M.Goal(40, "HUNTER", "forever"), 100 * GOLD)
  eq(M.Goal(60, "HUNTER", "forever"), 1200 * GOLD)
end)

test("discounts add, and Forever has no PvP rank discount", function()
  local M = fresh().Milestones
  local goal, cut = M.Goal(60, "HUNTER", "era", { honored = true })
  eq(goal, 900 * GOLD); eq(cut, 0.10)
  goal, cut = M.Goal(60, "HUNTER", "era", { honored = true, pvpRank3 = true })
  eq(goal, 800 * GOLD); eq(cut, 0.20)
  eq(M.Goal(40, "HUNTER", "era", { pvpRank3 = true }), 90 * GOLD)
  eq(M.Goal(60, "HUNTER", "forever", { honored = true, pvpRank3 = true }), 1080 * GOLD)
  eq(M.Goal(60, "HUNTER", "forever", {}), 1200 * GOLD, "nothing earned")
end)

test("a class's own target is never discounted", function()
  local M = fresh().Milestones
  local goal, cut = M.Goal(40, "PALADIN", "era", { honored = true, pvpRank3 = true })
  eq(goal, 10 * GOLD); eq(cut, 0)
  eq(M.Goal(60, "PALADIN", "era", { honored = true }), 900 * GOLD, "the level 60 default still is")
end)

test("reading discounts: home faction standing and PvP rank", function()
  local A = fresh().Adapter
  local function env(race, standing, rankIndex, rankNumber)
    return {
      UnitRace = function() return "x", race end,
      GetFactionInfoByID = function(id) return "f", "", (id == A.HomeFaction[race]) and standing or 4 end,
      UnitPVPRank = function() return rankIndex end,
      GetPVPRankInfo = rankNumber and function() return "r", rankNumber end or nil,
    }
  end
  eq(A.ReadDiscounts(env("Human", 6, 0)), { honored = true, pvpRank3 = false })
  eq(A.ReadDiscounts(env("Troll", 5, 7, 3)), { honored = false, pvpRank3 = true })
  eq(A.ReadDiscounts(env("Orc", 8, 7)).pvpRank3, true, "without GetPVPRankInfo, index 7 is rank 3")
  eq(A.ReadDiscounts(env("Orc", 8, 6)).pvpRank3, false, "rank 2")
  eq(A.ReadDiscounts({ C_Reputation = { GetFactionDataByID = function() return { reaction = 7 } end },
    UnitRace = function() return "x", "Gnome" end }).honored, true, "the Forever reputation call")
  eq(A.ReadDiscounts({}), { honored = false, pvpRank3 = false }, "nothing readable, no discount")
end)

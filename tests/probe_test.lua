local H = require("harness")

local function load()
  local ns = {}
  H.load("DontDoThat/Debug/Probe.lua", ns)
  return ns.Probe
end

local function trainerEnv()
  local rows = {
    { "Serpent Sting", "Rank 3", "used", 100, 18 },
    { "Serpent Sting", "Rank 4", "available", 200, 26 },
    { "Serpent Sting", "Rank 5", "unavailable", 300, 34 },
    { "Arcane Shot", "Rank 1", "available", 50, 6 },
    { "Arcane Shot", "Rank 2", "available", 90, 12 },
    { "Hunter Skills", "", "header" },
  }
  return {
    GetNumTrainerServices = function() return #rows end,
    GetTrainerServiceInfo = function(i) local r = rows[i]; return r[1], r[2], r[3] end,
    GetTrainerServiceCost = function(i) return rows[i][4] end,
    GetTrainerServiceLevelReq = function(i) return rows[i][5] end,
  }
end

test("existence reports present, missing, and namespace members", function()
  local P = load()
  local text = table.concat(P.Existence({
    GetTalentInfo = function() end,
    C_Trainer = { GetNumTrainerServices = function() end, Foo = 1 },
  }), "\n")
  truthy(text:find("GetTalentInfo: function", 1, true))
  truthy(text:find("LearnTalent: missing", 1, true))
  truthy(text:find("C_Trainer.*: present, 1 functions: GetNumTrainerServices", 1, true))
  truthy(text:find("C_SpellBook.*: missing", 1, true))
end)

test("run completes with an empty environment", function()
  local P = load()
  local text = P.Run({}, {})
  falsy(text:find("== Probe ==", 1, true), "Export supplies the heading")
  truthy(text:find("GetBuildInfo: ERROR not available", 1, true))
  truthy(text:find("Trainer snapshot", 1, true))
end)

test("run records errors and secret values and keeps going", function()
  local P = load()
  local secretToken = {}
  local env = {
    GetBuildInfo = function() return "1.0.0", "123", "Jan 1 2026", 16001 end,
    UnitLevel = function() error("restricted") end,
    UnitClass = function() return secretToken end,
    issecretvalue = function(v) return v == secretToken end,
  }
  local text = P.Run(env, {})
  truthy(text:find("interface: 16001", 1, true))
  truthy(text:find("UnitLevel(player): ERROR", 1, true))
  truthy(text:find("<secret>", 1, true))
  truthy(text:find("[SECRET]", 1, true))
  truthy(text:find("GetNumTalentTabs()", 1, true))
end)

test("a throwing probe in the list does not abort the report", function()
  local P = load()
  table.insert(P.Probes, { name = "boom", fn = function() error("kaput") end })
  local text = P.Run({}, {})
  truthy(text:find("boom: ERROR", 1, true))
  truthy(text:find("Observations", 1, true))
end)

test("trainer snapshot lists services and skips headers", function()
  local P = load()
  local snap = P.TrainerSnapshot(trainerEnv())
  truthy(snap.ok)
  eq(#snap.services, 5)
  eq(snap.headers[1], { index = 6, name = "Hunter Skills" })
  eq(snap.services[2].name, "Serpent Sting")
  eq(snap.services[2].rank, 4)
  eq(snap.services[2].level, 26)
  eq(snap.services[2].cost, 200)
  truthy(snap.services[2].available)
  truthy(snap.services[1].learned)
end)

test("trainer snapshot degrades without the API", function()
  local P = load()
  local snap = P.TrainerSnapshot({})
  falsy(snap.ok)
  truthy(snap.reason:find("missing", 1, true))
  local snap2 = P.TrainerSnapshot({ GetNumTrainerServices = function() error("x") end })
  falsy(snap2.ok)
end)

test("rank skips detect higher rank available with lower unlearned", function()
  local P = load()
  local skips = P.RankSkips(P.TrainerSnapshot(trainerEnv()).services)
  eq(skips, { { name = "Arcane Shot", rank = 2, lowerUnlearned = 1 } })
end)

test("rank skips are stored once and reported", function()
  local P = load()
  local saved = {}
  local snap = P.TrainerSnapshot(trainerEnv())
  P.RecordRankSkips(snap, saved)
  P.RecordRankSkips(snap, saved)
  eq(#P.ObservationLines(saved), 3)
  truthy(table.concat(P.ObservationLines(saved), "\n"):find("Arcane Shot rank 2", 1, true))
end)

test("talent points per tree", function()
  local P = load()
  local tp = P.TalentPoints({
    GetNumTalentTabs = function() return 3 end,
    GetTalentTabInfo = function(i) return "Tree" .. i, "icon", i * 2 end,
  })
  truthy(tp.ok)
  eq(tp.trees[3], { index = 3, name = "Tree3", points = 6 })
  falsy(P.TalentPoints({}).ok)
end)

test("talent points handle the id-first shape seen on Classic Era 1.15.9", function()
  local P = load()
  local tp = P.TalentPoints({
    GetNumTalentTabs = function() return 2 end,
    GetTalentTabInfo = function(i)
      return 360 + i, "Tree" .. i, "", 132164, i * 3, "Background"
    end,
  })
  truthy(tp.ok)
  eq(tp.trees[2], { index = 2, name = "Tree2", points = 6 })
end)

test("globals matching lists names containing each pattern", function()
  local P = load()
  local lines = P.GlobalsMatching({
    GetNumTrainerServices = function() end, BuyTrainerService = function() end,
    LearnTalent = function() end, Unrelated = function() end, NotAFunction = 5,
  }, { "Trainer", "wipe" })
  eq(lines[1], "  *Trainer*: 2 match(es): BuyTrainerService GetNumTrainerServices")
  eq(lines[2], "  *wipe*: 0 match(es)")
end)

test("respec quotes and interceptions are recorded in the given store", function()
  local P = load()
  local saved = { respecQuotes = {}, interceptions = {}, rankSkips = {} }
  P.RecordRespecQuote(2, 50000, saved)
  P.RecordInterception("trainer", "blocked", saved)
  P.RecordInterception("trainer", "blocked", saved)
  eq(saved.respecQuotes[1].count, 2)
  eq(saved.respecQuotes[1].copper, 50000)
  eq(saved.interceptions.trainer.blocked.n, 2)
  local text = P.Run(trainerEnv(), saved)
  truthy(text:find("respec quote: count=2 copper=50000", 1, true))
  truthy(text:find("interception trainer -> blocked: x2", 1, true))
  truthy(text:find("rank skipping possible: Arcane Shot", 1, true))
end)

test("respec quotes are bounded", function()
  local P = load()
  local saved = { respecQuotes = {}, interceptions = {}, rankSkips = {} }
  for i = 1, 60 do P.RecordRespecQuote(i, i, saved) end
  eq(#saved.respecQuotes, 50)
  eq(saved.respecQuotes[1].count, 11)
end)

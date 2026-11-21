package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = {}
for _, f in ipairs({ "Data/SpellData.lua", "Data/RuleSpells.lua", "Data/SkipRevisions.lua", "Data/TalentData.lua", "Model/SpellData.lua", "Rules/Schema.lua", "Rules/Engine.lua", "Rules/Data/Hunter.lua", "Rules/Data/ProfessionLearn.lua", "Model/SpecInference.lua",
  "Model/Milestones.lua", "Model/PlayerProfile.lua", "Intercepts/Adapter.lua", "Intercepts/Context.lua" }) do
  H.load("DontDoThat/" .. f, ns)
end

-- Forever has no GetNumTalentTabs: points come from C_Traits nodes. Spell -> talent -> tab per Data/TalentData.lua.
local NODES = {
  [1] = { rank = 1, spell = 19434 }, -- Aimed Shot, Marksmanship (tab 2)
  [2] = { rank = 3, spell = 19556 }, -- a Beast Mastery talent (tab 1)
  [3] = { rank = 2, spell = 19295 }, -- a Survival talent (tab 3)
  [4] = { rank = 0, spell = 19290 }, -- unspent: no points
  [5] = { rank = 4, spell = 1 },     -- not a talent: ignored
}

local function foreverEnv()
  return {
    UnitClass = function() return "Hunter", "HUNTER", 3 end,
    UnitLevel = function() return 40 end,
    C_ClassTalents = { GetActiveConfigID = function() return 1 end },
    C_Traits = {
      GetConfigInfo = function() return { treeIDs = { 9 } } end,
      GetTreeNodes = function() return { 1, 2, 3, 4, 5 } end,
      GetNodeInfo = function(_, id) return { currentRank = NODES[id].rank, activeEntry = { entryID = id } } end,
      GetEntryInfo = function(_, id) return { definitionID = id } end,
      GetDefinitionInfo = function(id) return { spellID = NODES[id].spell } end,
    },
  }
end

test("a client without talent tabs gets points per tab from its trait nodes", function()
  local tabs = ns.Adapter.ReadTalentTabs(foreverEnv())
  eq(tabs[1].points, 3)
  eq(tabs[2].points, 1)
  eq(tabs[3].points, 2)
  eq(ns.Adapter.ReadTalentTabs({}), {})
end)

test("Context.Profile gets nonzero tree points for the right spec in a client without talent tabs", function()
  ns.db = nil
  local p = ns.Context.Profile(foreverEnv())
  local specs = ns.Rules.GetClass("HUNTER").specs
  local seen = 0
  for key, spec in pairs(specs) do
    eq(p.treePoints[key], ({ 3, 1, 2 })[spec.tree], "tree " .. spec.tree)
    seen = seen + 1
  end
  eq(seen, 3)
end)

test("the talent points per tree are logged once, and again when they change", function()
  local logs = {}
  ns.Log = { Add = function(fmt, ...) logs[#logs + 1] = fmt:format(...) end }
  NODES[2].rank = 5
  ns.Context.Profile(foreverEnv())
  ns.Context.Profile(foreverEnv())
  NODES[1].rank = 2
  ns.Context.Profile(foreverEnv())
  NODES[1].rank, NODES[2].rank = 1, 3
  ns.Log = nil
  eq(logs, { "spec: talent points per tree 1=5 2=1 3=2", "spec: talent points per tree 1=5 2=2 3=2" })
end)

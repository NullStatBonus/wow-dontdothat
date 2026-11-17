package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

-- The settings tables checked by the bundled AceConfigRegistry, the way the game checks them before drawing.

local function fresh(profile)
  local ns = { version = "0.1.0" }
  for _, f in ipairs({ "UI/Helpers.lua", "Data/Sounds.lua", "Data/SpellData.lua", "Data/RuleSpells.lua", "Data/SkipRevisions.lua", "Data/TalentData.lua", "Model/SpellData.lua", "Rules/Schema.lua", "Rules/Engine.lua",
    "Rules/Data/Hunter.lua", "Rules/Data/Warrior.lua", "Rules/Data/Mage.lua", "Data/TrainerPrices.lua",
    "Model/Ledger.lua", "Model/Savings.lua", "Model/Milestones.lua", "Model/Settings.lua", "Model/SkipRevision.lua", "Model/ItemCategory.lua", "Options/Options.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  ns.db = { profile = profile or {} }
  return ns
end

-- Loads the real LibStub, CallbackHandler and AceConfigRegistry, runs fn with them, then puts LibStub back, so
-- the stub-based tests in the same run are not affected.
local function withRealRegistry(fn)
  local saved = { LibStub = _G.LibStub }
  _G.LibStub = nil
  local ok, err = pcall(function()
    for _, f in ipairs({ "LibStub/LibStub.lua", "CallbackHandler-1.0/CallbackHandler-1.0.lua", "AceConfig-3.0/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua" }) do
      dofile("DontDoThat/Libs/" .. f)
    end
    fn(_G.LibStub("AceConfigRegistry-3.0"))
  end)
  _G.LibStub = saved.LibStub
  truthy(ok, tostring(err))
end

test("every settings table passes the bundled AceConfigRegistry validation", function()
  local ns = fresh({})
  withRealRegistry(function(registry)
    registry:ValidateOptionsTable(ns.Options.Root(), "DontDoThat")
    ns.Options.PanelTables() -- built with the panel's titles
    for name, group in pairs(ns.Options.PanelTables()) do registry:ValidateOptionsTable(group, name) end
  end)
end)

test("the tables still validate with Custom nudge, Warning style and the addon off", function()
  local ns = fresh({ enabled = false, alerts = false, warnings = false, alert = { style = "warning", banner = false } })
  withRealRegistry(function(registry)
    registry:ValidateOptionsTable(ns.Options.Root(), "DontDoThat")
    for name, group in pairs(ns.Options.PanelTables()) do registry:ValidateOptionsTable(group, name) end
  end)
end)

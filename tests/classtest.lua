-- Shared setup for the per-class rule tests: loads the engine and one class's rule data.
local H = require("harness")

local M = {}

function M.new(class, file)
  local ns = {}
  H.loadSpellTables(ns)
  H.load("DontDoThat/Rules/Schema.lua", ns)
  H.load("DontDoThat/Rules/Engine.lua", ns)
  H.load("DontDoThat/Rules/Data/" .. file .. ".lua", ns)
  local self = { ns = ns, data = ns.Rules.GetClass(class) }
  -- specs: plausible spec keys ({} = undecided); talents: set of active talent names, or nil when unknown.
  function self.eval(name, specs, talents, rank)
    local profile = { class = class, level = 25, plausibleSpecs = specs or {}, activeTalents = H.talentSet(ns, class, talents),
      milestone = { current = 40, state = "active" } }
    return ns.Rules.Evaluate(profile, { kind = "spell", name = name, familyId = H.fid(ns, class, name), rank = rank })
  end
  function self.tier(name, specs, talents, rank) return self.eval(name, specs, talents, rank).tier end
  return self
end

return M

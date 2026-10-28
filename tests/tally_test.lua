local H = require("harness")

local ns = {}
H.loadSpellTables(ns)
H.load("DontDoThat/Rules/Schema.lua", ns)
H.load("DontDoThat/Rules/Engine.lua", ns)
H.load("DontDoThat/Rules/Data/ProfessionLearn.lua", ns)
H.load("DontDoThat/Model/Ledger.lua", ns)
H.load("DontDoThat/Intercepts/Adapter.lua", ns)
H.load("DontDoThat/Model/Tally.lua", ns)

local function env(guid, name)
  return {
    UnitGUID = function() return guid end,
    UnitName = function() return name end,
    GetTrainerServiceTypeFilter = function() return true end,
  }
end
local function trainer(rows) return { ok = true, rows = rows } end
local function row(name, id, rank, cost)
  return { name = name, familyId = id, rank = rank, level = 10, cost = cost, available = true }
end

test("the trainer is identified by GUID, falling back to the name", function()
  eq(ns.Adapter.ReadNpcId(env("Creature-0-1-2", "Hunter Trainer")), "Creature-0-1-2")
  eq(ns.Adapter.ReadNpcId({ UnitName = function() return "Hunter Trainer" end }), "Hunter Trainer")
  eq(ns.Adapter.ReadNpcId({}), nil)
end)

test("two trainers that share a name are told apart, so one cannot make the other's spells look bought", function()
  ns.Tally.Reset()
  ns.db = { char = { catalog = {}, costCache = {} } }
  ns.Tally.ObserveLive(env("Creature-A", "Hunter Trainer"), trainer({ row("Aimed Shot", 19434, 1, 400) }))
  ns.Tally.ObserveLive(env("Creature-B", "Hunter Trainer"), trainer({ row("Serpent Sting", 1978, 1, 400) }))
  local aimed = ns.db.char.catalog["19434#1"]
  truthy(aimed, "the catalog is keyed by spell family")
  eq(aimed.state, "open", "the other trainer's list did not mark it bought")
  eq(aimed.trainer, "Creature-A")
end)

test("a spell gone from the same trainer's complete list counts as bought", function()
  ns.Tally.Reset()
  ns.db = { char = { catalog = {}, costCache = {} } }
  local e = env("Creature-A", "Hunter Trainer")
  ns.Tally.ObserveLive(e, trainer({ row("Aimed Shot", 19434, 1, 400), row("Serpent Sting", 1978, 1, 400) }))
  ns.Tally.ObserveLive(e, trainer({ row("Serpent Sting", 1978, 1, 400) }))
  eq(ns.db.char.catalog["19434#1"].state, "learned")
  eq(ns.db.char.catalog["1978#1"].state, "open")
  eq(ns.db.char.costCache[ns.Ledger.CostKey(1978, 1)], 400, "prices are cached by spell family")
end)

test("a spell outside the bundled tables is tracked by the spell ID the tooltip gave, not its name", function()
  ns.Tally.Reset()
  ns.db = { char = { catalog = {}, costCache = {} } }
  local e = env("Creature-P", "Cooking Trainer")
  local recipe = { name = "Zrecipe", spellId = 2551, rank = nil, level = 5, cost = 100, available = true }
  local other = { name = "Zother", spellId = 2552, rank = nil, level = 5, cost = 100, available = true }
  ns.Tally.ObserveLive(e, trainer({ recipe, other }))
  truthy(ns.db.char.catalog["2551#0"], "keyed by spell ID")
  eq(ns.db.char.catalog["2551#0"].spellId, 2551)
  recipe.name = "Different name in another language"
  ns.Tally.ObserveLive(e, trainer({ { name = "Different name in another language", spellId = 2551, level = 5, cost = 100, available = true } }))
  eq(ns.db.char.catalog["2551#0"].state, "open", "the same spell under another name is still the same row")
  eq(ns.db.char.catalog["2552#0"].state, "learned", "the row that vanished is bought")
end)

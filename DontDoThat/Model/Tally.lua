local addonName, ns = ...

-- The gold-saved tally. A trainer window lists only spells you haven't learned, so "learned" is
-- inferred: a row that was on a trainer's list before and is gone now has been bought. Every row ever
-- seen is kept in a catalog saved with the character.
--
-- Two things can make rows vanish without a purchase, and both are guarded against:
--   * a collapsed category (its rows are hidden from the list), and
--   * a type filter switched off (the Available or Unavailable checkboxes).
local Tally = {}
ns.Tally = Tally

local lastSignature = {}

function Tally.Reset() lastSignature = {} end

local function keyOf(name, rank)
  return tostring(name) .. "#" .. tostring(rank or 0)
end

-- catalog: { [key] = { name, rank, level, cost, trainer, group, state = "open" | "learned" } }
-- trainer: Adapter.ReadTrainer result. filters: Adapter.ReadTrainerFilters result.
function Tally.Observe(catalog, npc, trainer, filters)
  if type(catalog) ~= "table" or not npc or type(trainer) ~= "table" or not trainer.ok then return false end
  local present, collapsed = {}, {}
  local group
  for _, row in ipairs(trainer.rows) do
    if row.header then
      group = row.name
      if row.expanded == false then collapsed[group] = true end
    else
      local key = keyOf(row.name, row.rank)
      present[key] = true
      local record = catalog[key] or {}
      record.name, record.rank, record.level, record.cost = row.name, row.rank, row.level, row.cost
      record.trainer, record.group = npc, group
      record.state = row.learned and "learned" or "open"
      catalog[key] = record
    end
  end
  -- Gone from a complete list means bought. Only rows last seen at this very trainer can be judged.
  if filters and filters.available and filters.unavailable then
    for key, record in pairs(catalog) do
      if record.state == "open" and record.trainer == npc and not present[key] and not collapsed[record.group] then
        record.state = "learned"
      end
    end
  end
  return true
end

-- Does the spellbook know any ID of this bundled spell? true / false, or nil when the game cannot say.
local function spellbookKnows(env, row)
  local answer
  for _, id in ipairs(ns.SpellData.Ids(row)) do
    local known = ns.Adapter.IsSpellKnown(env, id)
    if known == true then return true end
    if known == false then answer = false end
  end
  return answer
end

-- The ledger's view of the world. The bundled spell tables are the backbone: every spell the class can
-- learn, with its level and price, and "learned" taken straight from the spellbook. Trainer visits add
-- to that: a price a trainer actually showed beats the bundled one, and spells the bundle does not
-- know about (another class, a profession) come from the catalog alone. Merged by name and rank.
function Tally.Services(catalog, classKey, env)
  env = env or _G
  local services, bundledNames = {}, {}
  if classKey and ns.SpellData then
    local bundled = ns.SpellData.Services(classKey, function(row) return spellbookKnows(env, row) end)
    for _, svc in ipairs(bundled) do
      bundledNames[svc.name] = true
      local record = catalog and catalog[keyOf(svc.name, svc.rank)]
      if svc.learned == nil then
        -- The game could not say, so use what the trainer windows showed.
        svc.learned = record ~= nil and record.state == "learned"
      end
      if record and record.cost then svc.cost, svc.costIsEstimate = record.cost, false end
      svc.available = not svc.learned
      services[#services + 1] = svc
    end
  end
  for _, record in pairs(catalog or {}) do
    -- A spell the bundle covers is described by the bundle, whatever ranks an older client lists for it.
    if not bundledNames[record.name] then
      services[#services + 1] = {
        family = record.name, name = record.name, rank = record.rank, unlockLevel = record.level,
        cost = record.cost, learned = record.state == "learned", available = record.state ~= "learned",
      }
    end
  end
  return services
end

function Tally.Compute(profile, catalog, state, costCache, env)
  local result = ns.Ledger.Compute(profile, Tally.Services(catalog, profile.class, env), ns.Rules, costCache)
  return result, ns.Ledger.Totals(state, result)
end

-- Makes sure the saved tables have every field the ledger needs.
function Tally.Init(db)
  if not (db and db.char) then return end
  db.char.catalog = db.char.catalog or {}
  db.char.costCache = db.char.costCache or {}
  db.char.ledger = db.char.ledger or {}
  for key, value in pairs(ns.Ledger.NewState()) do
    if db.char.ledger[key] == nil then db.char.ledger[key] = value end
  end
end

-- Called with a live trainer read. Skips repeats of the same list.
function Tally.ObserveLive(env, trainer)
  local db = ns.db and ns.db.char
  if not (db and db.catalog and trainer and trainer.ok) then return end
  local npc = ns.Adapter.ReadNpcName(env)
  if not npc then return end
  local filters = ns.Adapter.ReadTrainerFilters(env)
  local signature = table.concat({ #trainer.rows, tostring(filters.available), tostring(filters.unavailable),
    tostring(filters.used) }, "|")
  if lastSignature[npc] == signature then return end
  lastSignature[npc] = signature
  Tally.Observe(db.catalog, npc, trainer, filters)
  for _, row in ipairs(trainer.rows) do
    if not row.header and row.cost then ns.Ledger.RecordCost(db.costCache, row.name, row.rank, row.cost) end
  end
end

local function money(copper)
  return ns.UIHelpers.FormatMoney(copper or 0) or "0c"
end

-- The numbers for the Tally page: { verified, projected, spentAgainst, resets = { text, ... } }, or nil
-- and a message when they can't be worked out.
function Tally.Entries()
  local db = ns.db and ns.db.char
  if not (db and db.catalog) then return nil, "The tally isn't available right now." end
  local okProfile, profile = pcall(ns.Context.Profile, _G)
  if not okProfile or not profile then return nil, "Log in on a supported character to see your tally." end
  local _, totals = Tally.Compute(profile, db.catalog, db.ledger or ns.Ledger.NewState(), db.costCache, _G)
  local ledger = db.ledger or {}
  local resets = {}
  if (ledger.respecsAvoided or 0) + (ledger.respecsPerformed or 0) > 0 then
    resets[#resets + 1] = ("Talent resets: skipped %d, done %d"):format(ledger.respecsAvoided or 0, ledger.respecsPerformed or 0)
  end
  if (ledger.petResetsAvoided or 0) + (ledger.petResetsPerformed or 0) > 0 then
    resets[#resets + 1] = ("Pet resets: skipped %d, done %d"):format(ledger.petResetsAvoided or 0, ledger.petResetsPerformed or 0)
  end
  return { verified = totals.verified, projected = totals.projected, spentAgainst = totals.spentAgainst, resets = resets,
    avoidedCount = ledger.itemsAvoided or 0, avoided = ledger.itemsAvoidedCopper or 0 }
end

-- The same numbers as plain-language lines.
function Tally.Summary()
  local entries, message = Tally.Entries()
  if not entries then return { message } end
  local lines = {
    "|cff33e633Kept for sure:|r " .. money(entries.verified),
    "|cff9d9d9dYou skipped these and already learned a better version.|r",
    "",
    "|cffffd100Kept so far:|r " .. money(entries.projected),
    "|cff9d9d9dThings you could buy right now but haven't.|r",
    "",
    "|cffff3333Spent on things the addon marked:|r " .. money(entries.spentAgainst),
    "|cff33e633Purchases you turned down:|r " .. entries.avoidedCount .. " (" .. money(entries.avoided) .. ")",
  }
  if #entries.resets > 0 then
    lines[#lines + 1] = ""
    for _, line in ipairs(entries.resets) do lines[#lines + 1] = line end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "|cff9d9d9dPrices are the ones trainers showed you, or an estimate for spells you haven't seen priced.|r"
  return lines
end

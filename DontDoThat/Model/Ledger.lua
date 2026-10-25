local addonName, ns = ...

local Ledger = {}
ns.Ledger = Ledger

-- UNVERIFIED (fan-site beta reports): 1st respec 1g, 2nd 5g, then +5g per step, capped at 50g.
-- Copper. steps = explicit leading costs; increment applies after them; cap bounds every result.
Ledger.DefaultRespecTable = {
  steps = { 1 * 10000, 5 * 10000 },
  increment = 5 * 10000,
  cap = 50 * 10000,
}

-- UNVERIFIED (Patch 1.7-era report, not confirmed for Forever): the Pet Trainer's untrain fee starts at
-- 10s and rises with each use to a 10g cap. The step size is a PLACEHOLDER. Observed quotes are recorded
-- by Debug/Capture so this table can be corrected.
Ledger.DefaultPetResetTable = {
  steps = { 10 * 100 },
  increment = 10 * 100,
  cap = 10 * 10000,
}

-- count = ordinal of the reset (1 = first). Returns copper.
local function escalatingCost(count, tbl)
  if not count or count < 1 then return 0 end
  local steps = tbl.steps or {}
  local cost
  if steps[count] then
    cost = steps[count]
  else
    cost = (steps[#steps] or 0) + (count - #steps) * (tbl.increment or 0)
  end
  if tbl.cap and cost > tbl.cap then cost = tbl.cap end
  return cost
end

function Ledger.RespecCost(count, tbl)
  return escalatingCost(count, tbl or Ledger.DefaultRespecTable)
end

function Ledger.PetResetCost(count, tbl)
  return escalatingCost(count, tbl or Ledger.DefaultPetResetTable)
end

function Ledger.NewState()
  return {
    respecsAvoided = 0, respecsPerformed = 0, respecSavings = 0,
    petResetsAvoided = 0, petResetsPerformed = 0, petResetSavings = 0,
    itemsAvoided = 0, itemsAvoidedCopper = 0,
    spentAgainst = 0, costCache = {},
  }
end

function Ledger.CostKey(family, rank)
  return tostring(family) .. tostring(rank)
end

function Ledger.RecordCost(costCache, family, rank, cost)
  if costCache and cost then costCache[Ledger.CostKey(family, rank)] = cost end
end

-- The declined respec would have been the next one.
function Ledger.RecordRespecAvoided(state, tbl)
  state.respecSavings = state.respecSavings + Ledger.RespecCost(state.respecsPerformed + 1, tbl)
  state.respecsAvoided = state.respecsAvoided + 1
end

-- actualCost (copper) is optional; the table estimate is used otherwise.
function Ledger.RecordRespecPerformed(state, tbl, actualCost)
  state.spentAgainst = state.spentAgainst + (actualCost or Ledger.RespecCost(state.respecsPerformed + 1, tbl))
  state.respecsPerformed = state.respecsPerformed + 1
end

-- The declined pet reset would have been the next one.
function Ledger.RecordPetResetAvoided(state, tbl)
  state.petResetSavings = state.petResetSavings + Ledger.PetResetCost(state.petResetsPerformed + 1, tbl)
  state.petResetsAvoided = state.petResetsAvoided + 1
end

function Ledger.RecordPetResetPerformed(state, tbl, actualCost)
  state.spentAgainst = state.spentAgainst + (actualCost or Ledger.PetResetCost(state.petResetsPerformed + 1, tbl))
  state.petResetsPerformed = state.petResetsPerformed + 1
end

-- A declined vendor or auction purchase. Kept apart from verified and projected savings.
function Ledger.RecordItemAvoided(state, copper)
  state.itemsAvoided = (state.itemsAvoided or 0) + 1
  state.itemsAvoidedCopper = (state.itemsAvoidedCopper or 0) + (copper or 0)
end

function Ledger.RecordItemPerformed(state, copper)
  state.spentAgainst = state.spentAgainst + (copper or 0)
end

-- Cost precedence: observed cache, then the service's data cost, then the engine verdict's cost.
-- Only the cache counts as observed; anything else is flagged costIsEstimate.
local function resolveCost(costCache, service, verdict)
  local observed = costCache and costCache[Ledger.CostKey(service.family, service.rank)]
  if observed then return observed, false end
  return service.cost or verdict.cost, true
end

local function higherRankLearned(services, svc)
  for _, other in ipairs(services) do
    if other.learned and other.family == svc.family and (other.rank or 0) > (svc.rank or 0) then
      return true
    end
  end
  return false
end

function Ledger.Compute(profile, services, engine, costCache)
  local result = { verified = 0, projected = 0, spentAgainst = 0, items = {} }
  for _, svc in ipairs(services) do
    local eligible = svc.learned or (svc.available and (svc.unlockLevel or 0) <= profile.level)
    if eligible then
      local verdict = engine.Evaluate(profile, {
        kind = "spell", name = svc.name, family = svc.family, rank = svc.rank,
        unlockLevel = svc.unlockLevel, cost = svc.cost,
      })
      if verdict and verdict.tier ~= "keep" then
        local cost, isEstimate = resolveCost(costCache, svc, verdict)
        local status
        if svc.learned then
          status = "spent"
          result.spentAgainst = result.spentAgainst + (cost or 0)
        elseif higherRankLearned(services, svc) then
          status = "verified"
          result.verified = result.verified + (cost or 0)
        else
          status = "projected"
          result.projected = result.projected + (cost or 0)
        end
        result.items[#result.items + 1] = {
          family = svc.family, name = svc.name, rank = svc.rank, cost = cost,
          costIsEstimate = isEstimate, status = status, tier = verdict.tier,
        }
      end
    end
  end
  return result
end

-- Combines a Compute result with the respec and pet reset counters held in state.
function Ledger.Totals(state, result)
  return {
    verified = result.verified,
    projected = result.projected + state.respecSavings + state.petResetSavings,
    spentAgainst = result.spentAgainst + state.spentAgainst,
  }
end

return Ledger

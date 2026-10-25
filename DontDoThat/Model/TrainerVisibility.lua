local addonName, ns = ...

-- Decides which trainer rows the "Recommended" filter shows. Pure: services and a
-- verdict function go in, plain tables come out. Rows are never reordered or
-- renumbered, so a visible row always resolves to the service index it displays.
local TrainerVisibility = {}
ns.TrainerVisibility = TrainerVisibility

local HIDDEN_TIERS = { defer = true, deferLow = true }

-- services: array of { index = originalServiceIndex, learned = bool, ... }
-- verdictFor(service) -> Verdict (see docs/contracts.md)
-- opts: { enabled = bool }  enabled is the Recommended filter being checked and the addon on.
-- Returns { visible = { service, ... }, hiddenCount = n, errors = n }
--
-- Category headers (service.header = true) are not evaluated or counted. While the filter
-- is on, a header goes only when it has rows under it and every one of them is hidden.
function TrainerVisibility.Compute(services, verdictFor, opts)
  local result = { visible = {}, hiddenCount = 0, errors = 0 }
  local enabled = opts and opts.enabled
  local list = services or {}
  local hidden = {}
  for position, service in ipairs(list) do
    if service.index == nil then service.index = position end
    if enabled and not service.header and not service.learned then
      -- A failing evaluation fails open: the row stays visible.
      local ok, verdict = pcall(verdictFor, service)
      if not ok then
        result.errors = result.errors + 1
      elseif type(verdict) == "table" and HIDDEN_TIERS[verdict.tier] then
        hidden[position] = true
        result.hiddenCount = result.hiddenCount + 1
      end
    end
  end
  if enabled then
    -- Walk backwards so each header knows whether any row below it survives.
    -- A header with no rows under it at all is collapsed, so it stays.
    local survivorBelow, rowsBelow = false, 0
    for position = #list, 1, -1 do
      if list[position].header then
        if rowsBelow > 0 and not survivorBelow then hidden[position] = true end
        survivorBelow, rowsBelow = false, 0
      else
        rowsBelow = rowsBelow + 1
        if not hidden[position] then survivorBelow = true end
      end
    end
  end
  for position, service in ipairs(list) do
    if not hidden[position] then result.visible[#result.visible + 1] = service end
  end
  return result
end

-- The service index a click on the row at this visible position must send.
function TrainerVisibility.IndexAt(result, position)
  local service = result.visible[position]
  return service and service.index or nil
end

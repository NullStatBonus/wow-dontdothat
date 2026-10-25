local addonName, ns = ...

-- Turns a cost into "about how long to grind that back", using the per-level rates in Data/GoldRates.lua.
local EarnBack = {}
ns.EarnBack = EarnBack

-- Copper per hour for this level: the highest band that starts at or below it.
function EarnBack.Rate(level, bands)
  bands = bands or ns.GoldRates
  local rate
  for _, band in ipairs(bands) do
    if level >= band.minLevel then rate = band.perHour end
  end
  return rate or bands[1].perHour
end

function EarnBack.Seconds(copper, level, bands)
  return copper / EarnBack.Rate(level or 1, bands) * 3600
end

local function plural(n, word) return n .. " " .. word .. (n == 1 and "" or "s") end

-- "under a minute", "about 40 minutes", "about 3 hours 10 minutes".
function EarnBack.Describe(copper, level, bands)
  if type(copper) ~= "number" or copper <= 0 then return nil end
  local minutes = EarnBack.Seconds(copper, level, bands) / 60
  if minutes < 1 then return "under a minute" end
  if minutes < 120 then return "about " .. plural(math.floor(minutes + 0.5), "minute") end
  local total = math.floor(minutes / 5 + 0.5) * 5
  local h, m = math.floor(total / 60), total % 60
  if m == 0 then return "about " .. plural(h, "hour") end
  return ("about %s %s"):format(plural(h, "hour"), plural(m, "minute"))
end

-- The line shown on prompts, or nil when there is no cost to talk about.
function EarnBack.Line(copper, level)
  level = level or (type(_G.UnitLevel) == "function" and _G.UnitLevel("player")) or nil
  if not level or level < 1 then return nil end
  local text = EarnBack.Describe(copper, level)
  if not text then return nil end
  if text == "under a minute" then return ("At level %d, that's under a minute of grinding to earn back."):format(level) end
  return ("At level %d, that's %s of grinding to earn back."):format(level, text)
end

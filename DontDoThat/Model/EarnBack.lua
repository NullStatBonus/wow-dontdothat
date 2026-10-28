local addonName, ns = ...
local L = ns.L

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

local function minutes_(n) return (n == 1 and L["%d minute"] or L["%d minutes"]):format(n) end
local function hours_(n) return (n == 1 and L["%d hour"] or L["%d hours"]):format(n) end

-- "under a minute", "about 40 minutes", "about 3 hours 10 minutes". The second value is true for "under a minute".
function EarnBack.Describe(copper, level, bands)
  if type(copper) ~= "number" or copper <= 0 then return nil end
  local minutes = EarnBack.Seconds(copper, level, bands) / 60
  if minutes < 1 then return L["under a minute"], true end
  if minutes < 120 then return L["about %s"]:format(minutes_(math.floor(minutes + 0.5))) end
  local total = math.floor(minutes / 5 + 0.5) * 5
  local h, m = math.floor(total / 60), total % 60
  if m == 0 then return L["about %s"]:format(hours_(h)) end
  return L["about %s %s"]:format(hours_(h), minutes_(m))
end

-- The line shown on prompts, or nil when there is no cost to talk about.
function EarnBack.Line(copper, level)
  level = level or (type(_G.UnitLevel) == "function" and _G.UnitLevel("player")) or nil
  if not level or level < 1 then return nil end
  local text, under = EarnBack.Describe(copper, level)
  if not text then return nil end
  if under then return (L["At level %d, that's under a minute of grinding to earn back."]):format(level) end
  return (L["At level %d, that's %s of grinding to earn back."]):format(level, text)
end

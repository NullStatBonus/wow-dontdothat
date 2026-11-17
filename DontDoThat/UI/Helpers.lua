local addonName, ns = ...
local L = ns.L

-- Pure helpers shared by the UI modules. No frames, no WoW calls.
local H = {}
ns.UIHelpers = H

function H.FormatMoney(copper)
  if type(copper) ~= "number" or copper < 0 then return nil end
  copper = math.floor(copper)
  local g = math.floor(copper / 10000)
  local s = math.floor(copper / 100) % 100
  local c = copper % 100
  local parts = {}
  if g > 0 then parts[#parts + 1] = g .. "g" end
  if s > 0 then parts[#parts + 1] = s .. "s" end
  if c > 0 or #parts == 0 then parts[#parts + 1] = c .. "c" end
  return table.concat(parts, " ")
end

local TIERS = {
  keep = { label = L["Keep"], color = { 0.2, 0.9, 0.2 } },
  info = { label = L["Optional"], color = { 0.4, 0.7, 1.0 } },
  deferLow = { label = L["Not worth buying yet"], color = { 1.0, 0.82, 0.0 } },
  defer = { label = L["Save your gold"], color = { 1.0, 0.2, 0.2 } },
}

function H.TierStyle(tier)
  local t = TIERS[tier]
  if not t then return nil end
  return { label = t.label, color = { t.color[1], t.color[2], t.color[3] } }
end

function H.CostText(verdict)
  local m = verdict and H.FormatMoney(verdict.cost)
  if not m then return nil end
  return (verdict.costIsEstimate and "~" or "") .. m
end

-- Three short lines: what to do, why, and what it costs. Nil when the verdict warrants no message.
function H.TooltipText(verdict)
  if type(verdict) ~= "table" then return nil end
  local style = TIERS[verdict.tier]
  if not style or verdict.tier == "keep" then return nil end
  local lines = { style.label }
  if verdict.reason and verdict.reason ~= "" then lines[#lines + 1] = tostring(verdict.reason) end
  local cost = H.FormatMoney(verdict.cost)
  if cost then lines[#lines + 1] = (verdict.costIsEstimate and L["Costs about %s"] or L["Costs %s"]):format(cost) end
  return table.concat(lines, "\n")
end

-- The tooltip as separate pieces, so each can be styled: a colored heading, the reason, and the cost.
-- Nil when the verdict warrants no message.
function H.TooltipParts(verdict)
  if type(verdict) ~= "table" then return nil end
  local style = TIERS[verdict.tier]
  if not style or verdict.tier == "keep" then return nil end
  local cost = H.FormatMoney(verdict.cost)
  return {
    heading = style.label,
    color = { style.color[1], style.color[2], style.color[3] },
    reason = (verdict.reason and verdict.reason ~= "") and tostring(verdict.reason) or nil,
    cost = cost and ((verdict.costIsEstimate and L["Costs about %s"] or L["Costs %s"]):format(cost)) or nil,
  }
end

local function hex(color)
  return ("%02x%02x%02x"):format(math.floor(color[1] * 255 + 0.5), math.floor(color[2] * 255 + 0.5), math.floor(color[3] * 255 + 0.5))
end

-- The same message with color codes and a blank line between parts, for text that cannot be styled
-- piece by piece (the pinned message).
function H.RichText(verdict)
  local parts = H.TooltipParts(verdict)
  if not parts then return nil end
  local out = { "|cff" .. hex(parts.color) .. parts.heading .. "|r" }
  if parts.reason then out[#out + 1] = parts.reason end
  if parts.cost then out[#out + 1] = "|cffffd100" .. parts.cost .. "|r" end
  return table.concat(out, "\n\n")
end

function H.BannerText(verdict, name)
  verdict = verdict or {}
  local head = tostring(name or verdict.name or L["This purchase"])
  local cost = H.FormatMoney(verdict.cost)
  if cost then head = (verdict.costIsEstimate and L["%s costs about %s."] or L["%s costs %s."]):format(head, cost) end
  local detail = tostring(verdict.reason or "")
  local earn = ns.EarnBack and ns.EarnBack.Line(verdict.cost)
  if earn then detail = detail .. (detail ~= "" and "\n" or "") .. earn end
  return head, detail
end

-- Local visual tokens for the addon's own surfaces (toast, pinned explanation): a 4-unit base,
-- 8-unit compact padding, 12-unit content padding, 16-unit section gaps; native font objects by role.
H.SPACE, H.PAD, H.CONTENT_PAD, H.SECTION = 4, 8, 12, 16
H.FONTS = { supporting = "GameFontHighlightSmall", body = "GameFontHighlight", heading = "GameFontNormal" }
H.INK = { primary = { 0.867, 0.867, 0.867 }, secondary = { 0.667, 0.667, 0.667 }, cost = { 1, 0.82, 0 } }

-- A whole-number percentage within lo..hi; anything else gives the default.
function H.Percent(value, lo, hi, default)
  local n = tonumber(value)
  if not n or n ~= n or n < lo or n > hi then return default end
  return math.floor(n + 0.5)
end

-- The look of one owned surface from a profile table ({ bgAlpha, textAlpha, scale }), as 0..1 alphas and a scale factor.
function H.Appearance(cfg)
  cfg = type(cfg) == "table" and cfg or {}
  return {
    bg = H.Percent(cfg.bgAlpha, 0, 100, 100) / 100,
    text = H.Percent(cfg.textAlpha, 0, 100, 100) / 100,
    scale = H.Percent(cfg.scale, 50, 200, 100) / 100,
  }
end

-- What a warning surface shows, piece by piece: the recommendation in words (so the tier reads without its color),
-- a neutral title (item or action and cost, estimates marked), and the reason with any earn-back line.
-- A missing tier gives no recommendation and a missing cost gives no price; nothing is made up.
function H.Content(verdict, name)
  verdict = type(verdict) == "table" and verdict or {}
  local style = TIERS[verdict.tier]
  local title, detail = H.BannerText(verdict, name)
  return {
    recommendation = style and style.label or nil,
    color = style and { style.color[1], style.color[2], style.color[3] } or nil,
    title = title,
    detail = detail ~= "" and detail or nil,
    icon = verdict.icon,
  }
end

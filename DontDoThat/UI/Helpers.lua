local addonName, ns = ...

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
  keep = { label = "Keep", color = { 0.2, 0.9, 0.2 } },
  info = { label = "Optional", color = { 0.4, 0.7, 1.0 } },
  deferLow = { label = "Not worth buying yet", color = { 1.0, 0.82, 0.0 } },
  defer = { label = "Save your gold", color = { 1.0, 0.2, 0.2 } },
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
  if cost then lines[#lines + 1] = (verdict.costIsEstimate and "Costs about " or "Costs ") .. cost end
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
    cost = cost and ((verdict.costIsEstimate and "Costs about " or "Costs ") .. cost) or nil,
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
  local head = tostring(name or verdict.name or "This purchase")
  local cost = H.FormatMoney(verdict.cost)
  if cost then head = head .. " costs " .. (verdict.costIsEstimate and "about " or "") .. cost .. "." end
  local detail = tostring(verdict.reason or "")
  local earn = ns.EarnBack and ns.EarnBack.Line(verdict.cost)
  if earn then detail = detail .. (detail ~= "" and "\n" or "") .. earn end
  return head, detail
end

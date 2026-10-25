local addonName, ns = ...

-- Pure Lua. treePoints tables are keyed by spec key: { BM = 21, MM = 0, SV = 0 }.
-- classData.specs = { BM = { tree = 1, role = "dps" }, ... }; role is optional.
local SpecInference = {}
ns.SpecInference = SpecInference

SpecInference.DefaultLeadMargin = 5

local function sortedSpecKeys(classData)
  local keys = {}
  for key in pairs(classData.specs or {}) do keys[#keys + 1] = key end
  table.sort(keys, function(a, b)
    local ta, tb = classData.specs[a].tree or 0, classData.specs[b].tree or 0
    if ta ~= tb then return ta < tb end
    return a < b
  end)
  return keys
end

function SpecInference.Depth(treePoints, specKey)
  return treePoints and treePoints[specKey] or 0
end

-- One talent set -> array of spec keys (in tree order).
local function inferSet(classData, treePoints, opts, keys)
  local margin = opts.leadMargin or SpecInference.DefaultLeadMargin
  local best, bestPts, secondPts, total = nil, -1, -1, 0
  for _, key in ipairs(keys) do
    local pts = SpecInference.Depth(treePoints, key)
    total = total + pts
    if pts > bestPts then
      best, secondPts, bestPts = key, bestPts, pts
    elseif pts > secondPts then
      secondPts = pts
    end
  end
  if total == 0 or not best then return keys end
  if secondPts < 0 then secondPts = 0 end
  local lead = bestPts - secondPts
  -- Hysteresis: a spec already narrowed to stays narrowed above a lower release margin.
  local prev = opts.previous
  if prev and #prev == 1 and prev[1] == best then
    margin = opts.releaseMargin or math.max(1, math.ceil(margin / 2))
  end
  if lead >= margin then return { best } end
  return keys
end

-- treePointsByTalentSet: array of 1 or 2 tables. Returns the union across sets.
function SpecInference.Infer(classData, treePointsByTalentSet, opts)
  opts = opts or {}
  local keys = sortedSpecKeys(classData)
  local sets = treePointsByTalentSet
  if #sets == 0 then sets = { {} } end
  local seen = {}
  for _, points in ipairs(sets) do
    for _, key in ipairs(inferSet(classData, points, opts, keys)) do seen[key] = true end
  end
  local result = {}
  for _, key in ipairs(keys) do
    if seen[key] then result[#result + 1] = key end
  end
  return result
end

-- Role shared by every plausible spec, or nil when mixed or unknown.
function SpecInference.Role(classData, treePoints, opts)
  local role
  for _, key in ipairs(SpecInference.Infer(classData, { treePoints or {} }, opts)) do
    local r = classData.specs[key].role
    if r then
      if role and role ~= r then return nil end
      role = r
    end
  end
  return role
end

return SpecInference

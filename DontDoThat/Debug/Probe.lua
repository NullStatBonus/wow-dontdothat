local addonName, ns = ...

-- In-game API probe. Every WoW access goes through an injected environment table
-- (default _G) and is pcall-wrapped, so the report completes even when calls
-- error or return restricted ("secret") values. All API names below are
-- CANDIDATES: their existence on WoW Forever is exactly what this probe reports.
local Probe = {}
ns.Probe = Probe

local MAX_QUOTES = 50

local boundStore

local function newStore()
  return { respecQuotes = {}, interceptions = {}, rankSkips = {} }
end

function Probe.Init(saved)
  boundStore = saved or newStore()
  boundStore.respecQuotes = boundStore.respecQuotes or {}
  boundStore.interceptions = boundStore.interceptions or {}
  boundStore.rankSkips = boundStore.rankSkips or {}
  return boundStore
end

local function store(s)
  if s then
    s.respecQuotes = s.respecQuotes or {}
    s.interceptions = s.interceptions or {}
    s.rankSkips = s.rankSkips or {}
    return s
  end
  if not boundStore then Probe.Init() end
  return boundStore
end

local function now()
  return time and time() or 0
end

---------------------------------------------------------------------------
-- Safe helpers

-- issecretvalue is a Midnight-era global; unverified on Forever, so optional.
local function isSecret(env, v)
  local f = env.issecretvalue
  if type(f) ~= "function" then return false end
  local ok, res = pcall(f, v)
  return ok and res == true
end

local function describe(env, v)
  if isSecret(env, v) then return "<secret>" end
  local ok, s = pcall(tostring, v)
  if not ok then return "<unprintable>" end
  if type(v) == "string" then return ("%q"):format(s) end
  return s
end

-- Calls fn(...) and returns { ok=bool, err=string|nil, secret=bool, n=count, values={...} }.
local function safeCall(env, fn, ...)
  local packed = { pcall(fn, ...) }
  if not packed[1] then
    return { ok = false, err = tostring(packed[2]), values = {}, n = 0 }
  end
  local res = { ok = true, values = {}, n = #packed - 1 }
  for i = 2, #packed do
    res.values[i - 1] = packed[i]
    if isSecret(env, packed[i]) then res.secret = true end
  end
  return res
end

local function resolve(env, path)
  local cur = env
  for part in path:gmatch("[^%.]+") do
    if type(cur) ~= "table" then return nil end
    local ok, nxt = pcall(function() return cur[part] end)
    if not ok then return nil end
    cur = nxt
  end
  return cur
end

local function summarize(env, res)
  if not res.ok then return "ERROR " .. res.err end
  local parts = {}
  for i = 1, math.min(res.n, 6) do parts[#parts + 1] = describe(env, res.values[i]) end
  local text = (#parts == 0) and "ok (no values)" or ("ok -> " .. table.concat(parts, ", "))
  if res.secret then text = text .. " [SECRET]" end
  return text
end

---------------------------------------------------------------------------
-- Candidate API existence

Probe.Candidates = {
  { group = "Legacy trainer", names = { "GetNumTrainerServices", "GetTrainerServiceInfo",
      "GetTrainerServiceCost", "GetTrainerServiceLevelReq", "BuyTrainerService", "SelectTrainerService" } },
  { group = "Modern trainer", names = { "C_Trainer.*" } },
  { group = "Talents", names = { "LearnTalent", "GetTalentInfo", "GetNumTalentTabs", "GetTalentTabInfo",
      "C_Traits.*", "C_ClassTalents.*", "C_SpecializationInfo.*" } },
  { group = "Respec", names = { "ConfirmTalentWipe", "GetTalentWipeCost", "ResetTalents",
      "C_ClassTalents.*" } },
  { group = "Spellbook", names = { "C_SpellBook.*" } },
  { group = "Menus (filter dropdowns)", names = { "Menu.*", "MenuUtil.*", "UIDropDownMenu_AddButton",
      "UIDropDownMenu_Initialize", "SetTrainerServiceTypeFilter" } },
  { group = "Tooltips", names = { "GameTooltip", "TooltipDataProcessor" } },
  { group = "Sounds", names = { "PlaySound", "PlaySoundFile" } },
  { group = "Addons", names = { "C_AddOns.*", "GetAddOnMetadata", "LibStub", "issecretvalue" } },
}

local function listMembers(env, path)
  local base = path:gsub("%.%*$", "")
  local t = resolve(env, base)
  if type(t) ~= "table" then return nil end
  local names = {}
  local ok = pcall(function()
    for k, v in pairs(t) do
      if type(k) == "string" and type(v) == "function" then names[#names + 1] = k end
    end
  end)
  if not ok then return nil end
  table.sort(names)
  return names
end

function Probe.Existence(env)
  env = env or _G
  local lines = {}
  for _, g in ipairs(Probe.Candidates) do
    lines[#lines + 1] = "[" .. g.group .. "]"
    for _, name in ipairs(g.names) do
      if name:find("%.%*$") then
        local members = listMembers(env, name)
        if members then
          lines[#lines + 1] = ("  %s: present, %d functions: %s"):format(name, #members, table.concat(members, " "))
        else
          lines[#lines + 1] = "  " .. name .. ": missing"
        end
      else
        local v = resolve(env, name)
        lines[#lines + 1] = ("  %s: %s"):format(name, v == nil and "missing" or type(v))
      end
    end
  end
  return lines
end

---------------------------------------------------------------------------
-- Read-only call probes: { name, fn(env) } -> fn returns the values to record.
-- Add entries to this table to probe more.

local function callIfPresent(env, path, ...)
  local f = resolve(env, path)
  if type(f) ~= "function" then error("not available", 0) end
  return f(...)
end

Probe.Probes = {
  { name = "GetBuildInfo", fn = function(env) return callIfPresent(env, "GetBuildInfo") end },
  { name = "UnitClass(player)", fn = function(env) return callIfPresent(env, "UnitClass", "player") end },
  { name = "UnitLevel(player)", fn = function(env) return callIfPresent(env, "UnitLevel", "player") end },
  { name = "GetNumTrainerServices()", fn = function(env) return callIfPresent(env, "GetNumTrainerServices") end },
  { name = "GetTrainerServiceInfo(1)", fn = function(env) return callIfPresent(env, "GetTrainerServiceInfo", 1) end },
  { name = "GetNumTalentTabs()", fn = function(env) return callIfPresent(env, "GetNumTalentTabs") end },
  { name = "GetTalentTabInfo(1)", fn = function(env) return callIfPresent(env, "GetTalentTabInfo", 1) end },
  { name = "GetTalentInfo(1,1)", fn = function(env) return callIfPresent(env, "GetTalentInfo", 1, 1) end },
  { name = "GetTalentWipeCost()", fn = function(env) return callIfPresent(env, "GetTalentWipeCost") end },
  { name = "GetTalentClearInfo()", fn = function(env) return callIfPresent(env, "GetTalentClearInfo") end },
  { name = "GetNumUnspentTalents()", fn = function(env) return callIfPresent(env, "GetNumUnspentTalents") end },
  { name = "GetNextTalentLevel()", fn = function(env) return callIfPresent(env, "GetNextTalentLevel") end },
  { name = "C_ClassTalents.GetActiveConfigID()", fn = function(env) return callIfPresent(env, "C_ClassTalents.GetActiveConfigID") end },
  { name = "C_SpecializationInfo.GetSpecialization()", fn = function(env) return callIfPresent(env, "C_SpecializationInfo.GetSpecialization") end },
  { name = "C_AddOns.GetAddOnMetadata(Interface)", fn = function(env)
      return callIfPresent(env, "C_AddOns.GetAddOnMetadata", addonName, "Interface") end },
}

function Probe.CallResults(env)
  env = env or _G
  local lines = {}
  for _, p in ipairs(Probe.Probes) do
    local res = safeCall(env, p.fn, env)
    lines[#lines + 1] = ("  %s: %s"):format(p.name, summarize(env, res))
  end
  return lines
end

function Probe.BuildInfo(env)
  env = env or _G
  local res = safeCall(env, function() return callIfPresent(env, "GetBuildInfo") end)
  if not res.ok then return { "  GetBuildInfo: " .. summarize(env, res) } end
  -- Classic-family return order: version, build, date, interface (unverified for Forever).
  local v = res.values
  return {
    "  version: " .. describe(env, v[1]),
    "  build: " .. describe(env, v[2]),
    "  date: " .. describe(env, v[3]),
    "  interface: " .. describe(env, v[4]),
  }
end

---------------------------------------------------------------------------
-- Trainer snapshot

local function firstValue(env, path, ...)
  local f = resolve(env, path)
  if type(f) ~= "function" then return nil, "missing" end
  local res = safeCall(env, f, ...)
  if not res.ok then return nil, res.err end
  if res.secret then return nil, "secret" end
  return res.values[1], nil, res.values
end

local function parseRank(sub)
  if type(sub) ~= "string" then return nil end
  local n = sub:match("(%d+)")
  return n and tonumber(n) or nil
end

-- Legacy API shape assumed from Classic (unverified on Forever):
--   GetTrainerServiceInfo(i) -> name, subText ("Rank 3"), serviceType ("available"|"unavailable"|"used"|"header")
--   GetTrainerServiceCost(i) -> copper; GetTrainerServiceLevelReq(i) -> level
-- Returns { ok=bool, reason=string|nil, services={...} }.
function Probe.TrainerSnapshot(env)
  env = env or _G
  local count, why = firstValue(env, "GetNumTrainerServices")
  if type(count) ~= "number" then
    return { ok = false, reason = "GetNumTrainerServices: " .. tostring(why or "no numeric result"), services = {} }
  end
  local services, headers = {}, {}
  for i = 1, count do
    local name, werr, vals = firstValue(env, "GetTrainerServiceInfo", i)
    if name == nil then
      services[#services + 1] = { index = i, error = werr or "no name" }
    elseif vals[3] == "header" then
      headers[#headers + 1] = { index = i, name = name }
    else
      local cost = firstValue(env, "GetTrainerServiceCost", i)
      local level = firstValue(env, "GetTrainerServiceLevelReq", i)
      local status = vals[3]
      services[#services + 1] = {
        index = i, name = name, rank = parseRank(vals[2]), subText = vals[2],
        level = level, cost = cost, status = status,
        available = status == "available", learned = status == "used",
      }
    end
  end
  return { ok = true, services = services, headers = headers }
end

-- Names of spells where a higher rank is available while a lower rank is unlearned.
-- Returns an array of { name=, rank=, lowerUnlearned= }.
function Probe.RankSkips(services)
  local byName, out = {}, {}
  for _, s in ipairs(services or {}) do
    if s.name and s.rank then
      byName[s.name] = byName[s.name] or {}
      table.insert(byName[s.name], s)
    end
  end
  local names = {}
  for name in pairs(byName) do names[#names + 1] = name end
  table.sort(names)
  for _, name in ipairs(names) do
    for _, hi in ipairs(byName[name]) do
      if hi.available then
        for _, lo in ipairs(byName[name]) do
          if lo.rank < hi.rank and not lo.learned then
            out[#out + 1] = { name = name, rank = hi.rank, lowerUnlearned = lo.rank }
            break
          end
        end
      end
    end
  end
  return out
end

-- Remembers rank-skip observations in the store (deduplicated by name+rank).
function Probe.RecordRankSkips(snapshot, saved)
  local s = store(saved)
  for _, skip in ipairs(Probe.RankSkips(snapshot.services)) do
    local key = skip.name .. "#" .. skip.rank
    if not s.rankSkips[key] then
      s.rankSkips[key] = { name = skip.name, rank = skip.rank, lowerUnlearned = skip.lowerUnlearned, t = now() }
    end
  end
end

---------------------------------------------------------------------------
-- Talent points per tree

-- GetNumTalentTabs(), GetTalentTabInfo(i): two return shapes are handled, see below.
function Probe.TalentPoints(env)
  env = env or _G
  local count, why = firstValue(env, "GetNumTalentTabs")
  if type(count) ~= "number" then
    return { ok = false, reason = "GetNumTalentTabs: " .. tostring(why or "no numeric result"), trees = {} }
  end
  local trees = {}
  for i = 1, count do
    local first, werr, vals = firstValue(env, "GetTalentTabInfo", i)
    if first == nil then
      trees[#trees + 1] = { index = i, error = werr or "no result" }
    else
      -- Observed on Classic Era 1.15.9: id, name, description, icon, pointsSpent, background.
      -- Older Classic builds returned name, icon, pointsSpent.
      local name, points = vals[1], vals[3]
      if type(vals[1]) == "number" and type(vals[2]) == "string" then
        name, points = vals[2], vals[5]
      end
      trees[#trees + 1] = { index = i, name = name, points = type(points) == "number" and points or nil }
    end
  end
  return { ok = true, trees = trees }
end

---------------------------------------------------------------------------
-- Observations

function Probe.RecordRespecQuote(count, copper, saved)
  local q = store(saved).respecQuotes
  q[#q + 1] = { count = count, copper = copper, t = now() }
  while #q > MAX_QUOTES do table.remove(q, 1) end
end

function Probe.RecordInterception(surface, outcome, saved)
  local s = store(saved).interceptions
  surface, outcome = tostring(surface), tostring(outcome)
  s[surface] = s[surface] or {}
  local o = s[surface][outcome]
  if not o then
    o = { n = 0 }
    s[surface][outcome] = o
  end
  o.n = o.n + 1
  o.last = now()
end

local function sortedKeys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys)
  return keys
end

function Probe.ObservationLines(saved)
  local s = store(saved)
  local lines = {}
  if #s.respecQuotes == 0 then
    lines[#lines + 1] = "  respec quotes: none observed"
  else
    for _, q in ipairs(s.respecQuotes) do
      lines[#lines + 1] = ("  respec quote: count=%s copper=%s t=%s"):format(tostring(q.count), tostring(q.copper), tostring(q.t))
    end
  end
  local surfaces = sortedKeys(s.interceptions)
  if #surfaces == 0 then lines[#lines + 1] = "  interceptions: none observed" end
  for _, surface in ipairs(surfaces) do
    for _, outcome in ipairs(sortedKeys(s.interceptions[surface])) do
      lines[#lines + 1] = ("  interception %s -> %s: x%d"):format(surface, outcome, s.interceptions[surface][outcome].n)
    end
  end
  local skips = sortedKeys(s.rankSkips)
  if #skips == 0 then lines[#lines + 1] = "  rank skipping: not observed" end
  for _, key in ipairs(skips) do
    local r = s.rankSkips[key]
    lines[#lines + 1] = ("  rank skipping possible: %s rank %d purchasable with rank %d unlearned"):format(r.name, r.rank, r.lowerUnlearned)
  end
  return lines
end

---------------------------------------------------------------------------
-- Report

local function money(c)
  return type(c) == "number" and tostring(c) .. "c" or "?"
end

-- Lists global functions/tables whose names contain any pattern, to discover APIs we did not guess.
function Probe.GlobalsMatching(env, patterns, limit)
  env = env or _G
  limit = limit or 60
  local lines = {}
  for _, pattern in ipairs(patterns) do
    local names = {}
    pcall(function()
      for k, v in pairs(env) do
        if type(k) == "string" and (type(v) == "function" or type(v) == "table")
            and k:lower():find(pattern:lower(), 1, true) then
          names[#names + 1] = k
        end
      end
    end)
    table.sort(names)
    local shown = {}
    for i = 1, math.min(#names, limit) do shown[i] = names[i] end
    lines[#lines + 1] = ("  *%s*: %d match(es)%s"):format(pattern, #names,
      #shown > 0 and (": " .. table.concat(shown, " ")) or "")
  end
  return lines
end

-- Skill lines as the client reports them (professions, weapon skills, languages), to confirm the shape
-- the profession rules rely on.
function Probe.SkillLines(env)
  env = env or _G
  local count = firstValue(env, "GetNumSkillLines")
  if type(count) ~= "number" then return { "  GetNumSkillLines unavailable" } end
  local lines = { ("  %d skill lines"):format(count) }
  for i = 1, math.min(count, 60) do
    local name, why, vals = firstValue(env, "GetSkillLineInfo", i)
    if name == nil then
      lines[#lines + 1] = ("  #%d %s"):format(i, tostring(why or "no result"))
    else
      lines[#lines + 1] = ("  #%d %s header=%s rank=%s max=%s"):format(i, tostring(name), tostring(vals[2]),
        tostring(vals[4]), tostring(vals[7]))
    end
  end
  return lines
end

-- Checks the bundled spell tables against the real client: does the spellbook answer for these IDs, and
-- does the game return an icon for them? A mismatch here is the first thing to look at if icons or the
-- tally look wrong.
local SAMPLE_SPELLS = { "Arcane Shot", "Serpent Sting", "Distracting Shot", "Great Stamina", "Aspect of the Beast" }

function Probe.SpellDataCheck(env)
  env = env or _G
  if not (ns.SpellData and ns.SpellTables and ns.Adapter) then return { "  spell data not loaded" } end
  local class = ns.Adapter.ReadPlayer(env).class
  local rows = ns.SpellData.Rows(class or "")
  local lines = { ("  bundled spell tables: build %s, %d spells for %s"):format(
    tostring(ns.SpellTables.build), #rows, tostring(class)) }
  local known, unknown, answered = 0, 0, false
  for _, row in ipairs(rows) do
    local any
    for _, id in ipairs(ns.SpellData.Ids(row)) do
      local k = ns.Adapter.IsSpellKnown(env, id)
      if k ~= nil then answered = true end
      if k then any = true end
    end
    if any then known = known + 1 else unknown = unknown + 1 end
  end
  lines[#lines + 1] = answered and ("  spellbook says %d known, %d not known"):format(known, unknown)
    or "  the client did not answer IsSpellKnown for any bundled ID"
  for _, name in ipairs(SAMPLE_SPELLS) do
    local row = ns.SpellData.Rank(class or "", name, 2) or ns.SpellData.Rank(class or "", name, 1)
      or ns.SpellData.Rank(class or "", name, nil)
    if row then
      local ids = ns.SpellData.Ids(row)
      local flags = {}
      for _, id in ipairs(ids) do flags[#flags + 1] = ("%d=%s"):format(id, tostring(ns.Adapter.IsSpellKnown(env, id))) end
      lines[#lines + 1] = ("  %s%s level %s: known [%s], icon %s"):format(name, row.rank and (" rank " .. row.rank) or "",
        tostring(row.level), table.concat(flags, " "), tostring((ns.SpellData.IconFor(name, env))))
    else
      lines[#lines + 1] = ("  %s: not in the bundled tables"):format(name)
    end
  end
  return lines
end

function Probe.ServiceLines(services)
  local lines = {}
  for _, s in ipairs(services) do
    if s.error then
      lines[#lines + 1] = ("  #%d error: %s"):format(s.index, s.error)
    else
      lines[#lines + 1] = ("  #%d %s rank=%s level=%s cost=%s status=%s"):format(
        s.index, tostring(s.name), tostring(s.rank), tostring(s.level), money(s.cost), tostring(s.status))
    end
  end
  return lines
end

function Probe.Run(env, saved)
  env = env or _G
  local out = {}
  local function section(title, lines)
    out[#out + 1] = title
    for _, l in ipairs(lines) do out[#out + 1] = l end
  end
  -- Each section is isolated so a bug in one cannot abort the report.
  local function guarded(title, fn)
    local ok, lines = pcall(fn)
    section(title, ok and lines or { "  FAILED: " .. tostring(lines) })
  end

  guarded("Build", function() return Probe.BuildInfo(env) end)
  guarded("API existence", function() return Probe.Existence(env) end)
  guarded("Call results", function() return Probe.CallResults(env) end)
  guarded("Globals matching", function()
    return Probe.GlobalsMatching(env, { "ClassTrainerSkill", "ClassTrainerFrame_", "TrainerService", "TrainerSkill",
      "PreviewTalent", "Wipe", "Unlearn", "Untrain", "TrainerFrameFilter", "FilterDropDown", "PlayerTalentFrame" }, 100)
  end)
  guarded("Trainer snapshot", function()
    local snap = Probe.TrainerSnapshot(env)
    if not snap.ok then return { "  unavailable: " .. snap.reason } end
    pcall(Probe.RecordRankSkips, snap, saved)
    local lines = { ("  %d services"):format(#snap.services) }
    for _, l in ipairs(Probe.ServiceLines(snap.services)) do lines[#lines + 1] = l end
    return lines
  end)
  guarded("Talent points", function()
    local tp = Probe.TalentPoints(env)
    if not tp.ok then return { "  unavailable: " .. tp.reason } end
    local lines = {}
    for _, t in ipairs(tp.trees) do
      lines[#lines + 1] = t.error and ("  tree %d error: %s"):format(t.index, t.error)
        or ("  tree %d %s: %s points"):format(t.index, tostring(t.name), tostring(t.points))
    end
    return lines
  end)
  guarded("Skill lines", function() return Probe.SkillLines(env) end)
  guarded("Spell data check", function() return Probe.SpellDataCheck(env) end)
  guarded("Observations", function() return Probe.ObservationLines(saved) end)
  if ns.Capture then
    guarded("Frames", function() return ns.Capture.FrameReport(env) end)
    guarded("Captured while debug was on", function() return ns.Capture.Lines(saved) end)
  end
  return table.concat(out, "\n")
end

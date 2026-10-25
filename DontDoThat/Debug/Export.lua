local addonName, ns = ...

-- Builds the copyable debug report and shows it in a movable window.
local Export = {}
ns.Export = Export

-- The wiring code sets this to a function returning the sources table for Build:
-- { settings = table, ledger = table, log = entries array, probe = string|function,
--   env = globals table (default _G) }
Export.sourceProvider = nil

local MAX_DEPTH = 5

local function sortedKeys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    local ta, tb = type(a), type(b)
    if ta ~= tb then return ta < tb end
    if ta == "number" or ta == "string" then return a < b end
    return tostring(a) < tostring(b)
  end)
  return keys
end

-- Deterministic, depth-limited, cycle-safe dump of a plain table.
local function dump(value, indent, depth, seen, lines)
  if type(value) ~= "table" then
    lines[#lines + 1] = indent .. tostring(value)
    return
  end
  if seen[value] or depth > MAX_DEPTH then
    lines[#lines + 1] = indent .. "<...>"
    return
  end
  seen[value] = true
  for _, k in ipairs(sortedKeys(value)) do
    local v = value[k]
    if type(v) == "table" then
      lines[#lines + 1] = ("%s%s:"):format(indent, tostring(k))
      dump(v, indent .. "  ", depth + 1, seen, lines)
    else
      lines[#lines + 1] = ("%s%s = %s"):format(indent, tostring(k), tostring(v))
    end
  end
  seen[value] = nil
end

local function dumpTable(t)
  if type(t) ~= "table" then return { "  (not available)" } end
  local lines = {}
  dump(t, "  ", 1, {}, lines)
  if #lines == 0 then lines[1] = "  (empty)" end
  return lines
end

local function formatTime(t)
  if type(t) ~= "number" then return "?" end
  if date then
    local ok, s = pcall(date, "%Y-%m-%d %H:%M:%S", t)
    if ok then return s end
  end
  return tostring(t)
end

-- LibStub keeps loaded libs in LibStub.libs and versions in LibStub.minors (LibStub internals).
local function libraryLines(env)
  local stub = env.LibStub
  if type(stub) ~= "table" and type(stub) ~= "function" then return { "  LibStub not present" } end
  local ok, lines = pcall(function()
    local out = {}
    local libs = type(stub) == "table" and stub.libs
    local minors = type(stub) == "table" and stub.minors
    if type(libs) ~= "table" then return { "  LibStub present, library list unavailable" } end
    for _, name in ipairs(sortedKeys(libs)) do
      out[#out + 1] = ("  %s (minor %s)"):format(tostring(name), tostring(type(minors) == "table" and minors[name] or "?"))
    end
    return out
  end)
  return ok and lines or { "  LibStub query failed: " .. tostring(lines) }
end

local function logLines(entries)
  if type(entries) ~= "table" or #entries == 0 then return { "  (empty)" } end
  local out = {}
  for _, e in ipairs(entries) do
    out[#out + 1] = ("  [%s] %s"):format(formatTime(e.t), tostring(e.msg))
  end
  return out
end

-- Returns the full report text. Each section is isolated so one failure cannot lose the rest.
function Export.Build(sources)
  sources = sources or {}
  local env = sources.env or _G
  local out = { ("== %s export =="):format(addonName), ("addon version: %s"):format(tostring(ns.version or "unknown")) }

  local function section(title, fn)
    out[#out + 1] = ""
    out[#out + 1] = "== " .. title .. " =="
    local ok, lines = pcall(fn)
    if not ok then lines = { "  FAILED: " .. tostring(lines) } end
    for _, l in ipairs(lines) do out[#out + 1] = l end
  end

  section("Settings", function() return dumpTable(sources.settings) end)
  section("Ledger", function() return dumpTable(sources.ledger) end)
  section("Items", function()
    local r = sources.items
    if type(r) == "function" then r = r() end
    return dumpTable(r)
  end)
  section("Log", function() return logLines(sources.log) end)
  section("Libraries", function() return libraryLines(env) end)
  section("Probe", function()
    local p = sources.probe
    if type(p) == "function" then p = p() end
    if type(p) ~= "string" then return { "  (no probe report)" } end
    local lines = {}
    for l in (p .. "\n"):gmatch("(.-)\n") do lines[#lines + 1] = l end
    return lines
  end)
  return table.concat(out, "\n")
end

---------------------------------------------------------------------------
-- WoW-only: the copy window. Template names are unverified on Forever, so each
-- creation is pcall-guarded with a plain fallback.

local frame

local function createFrame()
  if not CreateFrame or not UIParent then return nil end
  local f
  for _, template in ipairs({ "BasicFrameTemplateWithInset", "BackdropTemplate" }) do
    local ok, res = pcall(CreateFrame, "Frame", "DontDoThatExportFrame", UIParent, template)
    if ok and res then f = res break end
  end
  if not f then return nil end
  f:SetSize(640, 440)
  f:SetPoint("CENTER")
  f:SetFrameStrata("DIALOG")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)

  local scroll = CreateFrame("ScrollFrame", "DontDoThatExportScroll", f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 12, -32)
  scroll:SetPoint("BOTTOMRIGHT", -32, 42)

  local edit = CreateFrame("EditBox", nil, scroll)
  edit:SetMultiLine(true)
  edit:SetAutoFocus(false)
  edit:SetFontObject(ChatFontNormal or GameFontHighlight)
  edit:SetWidth(580)
  edit:SetScript("OnEscapePressed", function() f:Hide() end)
  scroll:SetScrollChild(edit)

  local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  close:SetSize(90, 24)
  close:SetPoint("BOTTOM", 0, 12)
  close:SetText("Close")
  close:SetScript("OnClick", function() f:Hide() end)

  f.edit = edit
  -- Escape closes the window.
  if type(UISpecialFrames) == "table" then
    table.insert(UISpecialFrames, "DontDoThatExportFrame")
  end
  return f
end

function Export.Show(sources)
  local ok, err = pcall(function()
    if not sources and Export.sourceProvider then sources = Export.sourceProvider() end
    local text = Export.Build(sources)
    frame = frame or createFrame()
    if not frame then error("could not create the export window") end
    frame.edit:SetText(text)
    frame:Show()
    frame.edit:SetFocus()
    frame.edit:HighlightText()
  end)
  if not ok and DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("Don't Do That: export failed: " .. tostring(err))
  end
  return ok
end

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
  section("Presentation", function()
    local p = sources.settings
    if type(p) ~= "table" then return { "  (not available)" } end
    local R = ns.Registry
    local function val(key, raw)
      local v = R and R.Get(key, p)
      return v ~= nil and v or tostring(raw)
    end
    local a, t, e = p.alert or {}, p.toast or {}, p.explanation or {}
    local lines = {
      "  active profile: " .. tostring(sources.profileName or "unknown"),
      "  saved data version: " .. tostring(sources.dataVersion and sources.dataVersion.current or "unknown")
        .. (sources.dataVersion and sources.dataVersion.previous and (" (earlier: " .. sources.dataVersion.previous .. ")") or ""),
      "  test settings: " .. (sources.testSettings and ("on (temporary profile in use; own profile " .. tostring(sources.testSettings) .. ")") or "off"),
      "  CheckThat: " .. tostring(sources.checkThat or "not detected"),
      "  scope: settings shared by the profile; savings, mount marks, profession answers and allowed items per character; debug account-wide",
      "  warning style: " .. val("appearance.warning-style", a.style or "toast"),
      "  message shown: " .. val("appearance.message", a.banner ~= false),
      "  chat record: " .. val("appearance.chat", a.chat ~= false),
      ("  toast: background %s, text %s, scale %s"):format(val("appearance.toast.background-opacity", t.bgAlpha),
        val("appearance.toast.text-opacity", t.textAlpha), val("appearance.toast.scale", t.scale)),
      ("  explanation: background %s, text %s, scale %s"):format(val("appearance.explanation.background-opacity", e.bgAlpha),
        val("appearance.explanation.text-opacity", e.textAlpha), val("appearance.explanation.scale", e.scale)),
      ("  sound: %s, channel %s, cooldown %s"):format(tostring(a.sound), val("alert.channel", a.channel), val("alert.cooldown", a.cooldown)),
      "  toast position: " .. (type(t.point) == "table"
        and ("%s %s %s %s"):format(tostring(t.point.point), tostring(t.point.relPoint), tostring(t.point.x), tostring(t.point.y))
        or "default"),
    }
    local extra = sources.presentation
    if type(extra) == "function" then extra = extra() end
    if type(extra) == "table" then
      for _, l in ipairs(extra) do lines[#lines + 1] = "  " .. tostring(l) end
    end
    return lines
  end)
  section("Rules", function()
    local p = sources.settings
    local defaults = ns.defaults and ns.defaults.profile
    if type(p) ~= "table" or type(defaults) ~= "table" then return { "  (not available)" } end
    -- A value as it acts: the saved one, else the default; tables are merged one key at a time.
    local function effective(saved, default)
      if type(default) ~= "table" then
        if saved == nil then return default end
        return saved
      end
      local out = {}
      if type(saved) ~= "table" then saved = {} end
      for k, v in pairs(default) do out[k] = effective(saved[k], v) end
      for k, v in pairs(saved) do if out[k] == nil then out[k] = v end end
      return out
    end
    local function compact(v)
      if type(v) ~= "table" then return tostring(v) end
      local parts = {}
      for _, k in ipairs(sortedKeys(v)) do parts[#parts + 1] = tostring(k) .. "=" .. compact(v[k]) end
      return "{" .. table.concat(parts, ", ") .. "}"
    end
    local S = ns.Settings
    local lines = {}
    for _, key in ipairs(sortedKeys(defaults)) do
      lines[#lines + 1] = ("  %s: %s"):format(key, compact(effective(p[key], defaults[key])))
    end
    if S then
      local tiers = S.PromptTiers(p)
      lines[#lines + 1] = ("  nudge level: %s"):format(tostring(S.Nudge(p)))
      lines[#lines + 1] = ("  prompt tiers: defer=%s, deferLow=%s, info=%s"):format(
        tostring(tiers.defer), tostring(tiers.deferLow), tostring(tiers.info))
      lines[#lines + 1] = ("  what to watch: spells=%s, professions=%s, shopping=%s"):format(
        tostring(S.Watching("spells", p)), tostring(S.Watching("professions", p)), tostring(S.Watching("shopping", p)))
      lines[#lines + 1] = ("  stop point: level %s mount"):format(tostring(S.StopAfter(p)))
      lines[#lines + 1] = ("  skip revision: %s"):format(S.SkipRevision(p) and tostring(S.SkipRevision(p)) or "newest")
    end
    return lines
  end)
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
-- The copy window (AceGUI Frame + MultiLineEditBox, as the sibling addons do), with a chat fallback.

local window

-- Prints the whole report to chat, one line at a time (long lines are split), when no window can be made.
local CHUNK = 240
function Export.PrintToChat(text, printer)
  printer = printer or function(m) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(m) end end
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if line == "" then line = " " end
    while #line > CHUNK do
      printer(line:sub(1, CHUNK))
      line = line:sub(CHUNK + 1)
    end
    printer(line)
  end
end

local FRAME_NAME = "DontDoThatLogFrame"

-- Escape closes the window, as for the old frame: register its global name with the game, and undo it on close.
local function setEscapeClose(env, frame, on)
  pcall(function()
    local special = env.UISpecialFrames
    if type(special) ~= "table" then return end
    if on then
      env[FRAME_NAME] = frame
      for _, v in ipairs(special) do if v == FRAME_NAME then return end end
      special[#special + 1] = FRAME_NAME
    else
      for i = #special, 1, -1 do if special[i] == FRAME_NAME then table.remove(special, i) end end
      if env[FRAME_NAME] == frame then env[FRAME_NAME] = nil end
    end
  end)
end

local function openWindow(text, env)
  local stub = env.LibStub
  if not stub then return false end
  local AceGUI = stub("AceGUI-3.0", true)
  if not AceGUI then return false end
  if window then
    local old = window
    pcall(function() setEscapeClose(env, old.frame, false); old:Release() end)
    window = nil
  end
  local w = AceGUI:Create("Frame")
  if not w then return false end
  window = w
  setEscapeClose(env, w.frame, true)
  w:SetTitle("Don't Do That: log")
  w:SetStatusText("Ctrl+A selects everything, then Ctrl+C copies it.")
  w:SetLayout("Fill")
  w:SetCallback("OnClose", function(f)
    setEscapeClose(env, f.frame, false)
    AceGUI:Release(f)
    if window == f then window = nil end
  end)
  local box = AceGUI:Create("MultiLineEditBox")
  box:SetLabel("")
  box:DisableButton(true)
  box:SetText(text)
  -- Read-only: any edit puts the report text back.
  box:SetCallback("OnTextChanged", function(b) b:SetText(text) end)
  w:AddChild(box)
  box:SetFocus()
  box:HighlightText()
  return true
end

Export.env = nil -- tests may supply a fake globals table

function Export.Show(sources)
  local env = Export.env or _G
  local text
  local ok, err = pcall(function()
    if not sources and Export.sourceProvider then sources = Export.sourceProvider() end
    text = Export.Build(sources)
  end)
  if not ok then
    Export.PrintToChat("Don't Do That: the report failed: " .. tostring(err))
    return false
  end
  local shown = pcall(function()
    if not openWindow(text, env) then error("no window") end
  end)
  if shown and window then return true end
  window = nil
  Export.PrintToChat(text)
  return true
end

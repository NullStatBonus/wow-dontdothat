-- CheckThat, the in-game test runner (spec checkthat-integration; design decisions 8 to 10). Every CheckThat call
-- lives here, through ns.Adapter.checkThat(), existence-checked and in pcall, so the addon works the same with
-- CheckThat missing, old or failing. CheckThat is a test harness only: it has no setting.
--
--   CT.Start(ctx) runs once at login and registers the entries and the run hook. ctx gives functions:
--     version() (the TOC version text), testSettings() (true while test settings are on), setting(key) (the value
--     /ddt get prints, or nil), char(key) ("marks" or "allowed": this character's state, or nil), log(msg) (the debug
--     log), and the run handlers runStarted(runId), runEnded(reason) and runGone().
--   An entry call reads state only. It writes nothing, not even a log line.
--   A raised error from CheckThat turns the integration off for the session and keeps the reason.
local _, ns = ...

local CT = { ADDON = "DontDoThat", ORDER = {}, entries = {}, TEXT = 100 }
ns.CheckThat = CT

local ctx = {}
local version -- the TOC version text, read once at Start
local failed -- the reason, once a CheckThat call raised

local function api()
  local t = ns.Adapter and ns.Adapter.checkThat and ns.Adapter.checkThat()
  return type(t) == "table" and t or nil
end

local function cut(s) return (tostring(s):sub(1, CT.TEXT)) end

local function log(msg)
  if type(ctx.log) == "function" then pcall(ctx.log, msg) end
end

-- "working", "not detected", "too old" (loaded, but no Entry to register with) or "failed: <why>".
function CT.Status()
  if failed then return "failed: " .. failed end
  local t = api()
  if not t then return "not detected" end
  return type(t.Entry) == "function" and "working" or "too old"
end

-- Turns the integration off for the session. Later calls stop at the check in each caller.
function CT.Fail(why)
  if failed then return end
  failed = cut(why)
  log("checkthat: FAILED: " .. failed)
end

-- "1.0.0" is 10000: major*10000 + minor*100 + patch. nil when the version is unknown or does not parse.
function CT.VersionNumber(v)
  if type(v) ~= "string" then return nil end
  local major, minor, patch = v:match("^v?(%d+)%.(%d+)%.(%d+)")
  if not major then return nil end
  return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
end

local function add(name, fn)
  CT.ORDER[#CT.ORDER + 1] = name
  CT.entries[name] = fn
end

-- Nothing when the version is unknown: the offline client has no TOC metadata.
add("version", function()
  local n = CT.VersionNumber(version)
  if n then return n end
end)

-- "on" or "off".
add("testsettings", function()
  if type(ctx.testSettings) ~= "function" then return end
  return ctx.testSettings() and "on" or "off"
end)

-- The value /ddt get prints for a setting key; "marks" (the mount marks of this character) or "allowed" (the count
-- of its allowed items). Nothing for an unknown key.
add("setting", function(key)
  if type(key) ~= "string" then return end
  key = key:lower()
  if key == "marks" or key == "allowed" then
    local v = type(ctx.char) == "function" and ctx.char(key)
    if v ~= nil then return type(v) == "string" and cut(v) or v end
    return
  end
  local v = type(ctx.setting) == "function" and ctx.setting(key)
  if v ~= nil then return cut(v) end
end)

local function pack(...) return { n = select("#", ...), ... } end

-- fn in pcall; the number of results is kept (zero stays zero: CheckThat shows "(none)"). An error is returned as a
-- value, not logged, so an entry call writes nothing. After a failure no entry answers.
function CT.Wrap(fn)
  return function(...)
    if failed then return end
    local r = pack(pcall(fn, ...))
    if r[1] then return unpack(r, 2, r.n) end
    return cut("error: " .. tostring(r[2]))
  end
end

-- Registers every entry once. Returns the number CheckThat stored.
function CT.RegisterEntries()
  if CT.registered then return CT.registered end
  if failed then return 0 end
  local t = api()
  if not t or type(t.Entry) ~= "function" then return 0 end
  CT.registered = 0
  for _, name in ipairs(CT.ORDER) do
    local ok, stored = pcall(t.Entry, CT.ADDON, name, CT.Wrap(CT.entries[name]))
    if not ok then
      CT.Fail("Entry: " .. tostring(stored))
      return CT.registered
    end
    if stored then CT.registered = CT.registered + 1 end
  end
  log(("checkthat: entries registered: %d"):format(CT.registered))
  return CT.registered
end

-- Calls one of the addon's run handlers in pcall. A raised error is logged and leaves the integration on. After a
-- failure only the handlers that restore the player's settings still run.
local function runHandler(name, ...)
  if (failed and name == "runStarted") or type(ctx[name]) ~= "function" then return end
  local ok, err = pcall(ctx[name], ...)
  if not ok then log("checkthat: FAILED: " .. name .. ": " .. cut(err)) end
end

-- True when a CheckThat run of this addon is open for the character. False when CheckThat is missing, too old to say,
-- or reports none, so test settings are restored.
function CT.RunOpen()
  if failed then return false end
  local t = api()
  if not t or type(t.ActiveRun) ~= "function" then return false end
  local ok, plan = pcall(t.ActiveRun, CT.ADDON)
  if not ok then CT.Fail("ActiveRun: " .. tostring(plan)) return false end
  return plan ~= nil
end

-- Registers the run callback once: a run start turns test settings on, a run end turns them off, and a login with no
-- open run restores what a run left on (asked before registering, so the catch-up start CheckThat sends for an open
-- run comes after it). A CheckThat without the callback changes nothing.
function CT.RegisterRunHook()
  if CT.runHook ~= nil or failed then return CT.runHook end
  local t = api()
  if not t or type(t.OnRun) ~= "function" then
    if t then CT.runHook = false; log("checkthat: run hook not available") end
    return false
  end
  if type(t.ActiveRun) == "function" then
    local ok, plan = pcall(t.ActiveRun, CT.ADDON)
    if not ok then CT.Fail("ActiveRun: " .. tostring(plan)) return false end
    if plan == nil then runHandler("runGone") end
  end
  local ok, stored = pcall(t.OnRun, CT.ADDON, function(event, info)
    info = type(info) == "table" and info or {}
    if event == "start" then runHandler("runStarted", info.runId)
    elseif event == "end" then runHandler("runEnded", info.reason) end
  end)
  if not ok then CT.Fail("OnRun: " .. tostring(stored)) return false end
  CT.runHook = stored == true
  log(CT.runHook and "checkthat: run hook registered" or "checkthat: run hook refused")
  return CT.runHook
end

function CT.Start(c)
  ctx = type(c) == "table" and c or {}
  if type(ctx.version) == "function" then
    local ok, v = pcall(ctx.version)
    version = ok and v or nil
  end
  CT.RegisterRunHook()
  return CT.RegisterEntries()
end

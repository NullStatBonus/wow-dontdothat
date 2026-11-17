local addonName, ns = ...
local L = ns.L

-- The public settings: stable keys for /ddt get and /ddt set, independent of where a value is stored.
-- Each entry declares its type (bool | enum | int), bounds or values, and a getter and setter on the profile.
-- Parsing is strict: a value that does not fit is refused and nothing is written.
local Registry = {}
ns.Registry = Registry

local CHANNELS = { "Master", "SFX", "Music", "Ambience", "Dialog" }

-- Getters read a group without creating it; only setters make the table.
local function sub(name)
  return function(p, create)
    local t = p[name]
    if t == nil and create then t = {}; p[name] = t end
    return t or {}
  end
end
local alert, toast, explanation = sub("alert"), sub("toast"), sub("explanation")

-- Named refreshes: what the matching settings control does after a change. Each entry lists the ones it needs.
local refreshers = {
  trainer = function() if ns.Options and ns.Options.Apply then pcall(ns.Options.Apply) end end,
  views = function() if ns.Options and ns.Options.Refresh then pcall(ns.Options.Refresh) end end,
  toast = function() if ns.Toast and ns.Toast.Refresh then pcall(ns.Toast.Refresh) end end,
  explanation = function() if ns.InfoBubble and ns.InfoBubble.RefreshAppearance then pcall(ns.InfoBubble.RefreshAppearance) end end,
}
Registry.Refreshers = refreshers

local list = {}
local byKey = {}
local V = { "views" }

local function add(e)
  e.scope = e.scope or "profile"
  e.refresh = e.refresh or V
  list[#list + 1] = e
  byKey[e.key] = e
end

local function boolField(key, group, field, default, refresh)
  add({
    key = key, type = "bool", group = group, refresh = refresh,
    get = function(p) local v = (group and group(p) or p)[field]; if v == nil then return default end; return v ~= false end,
    set = function(p, v) (group and group(p, true) or p)[field] = v end,
  })
end

local function intField(key, group, field, min, max, default, refresh)
  add({
    key = key, type = "int", min = min, max = max, refresh = refresh,
    get = function(p) local v = group(p)[field]; return type(v) == "number" and v or default end,
    set = function(p, v) group(p, true)[field] = v end,
  })
end

boolField("enabled", nil, "enabled", true, { "trainer", "views" })
add({
  key = "nudge", type = "enum", scope = "derived profile", refresh = { "trainer", "views" }, values = { "mark", "ask", "everything" },
  get = function(p) return ns.Settings.Nudge(p) end,
  set = function(p, v) ns.Settings.SetNudge(v, p) end,
})
for _, area in ipairs({ "spells", "professions", "shopping" }) do
  add({
    key = "watch." .. area, type = "bool", refresh = { "trainer", "views" },
    get = function(p) return ns.Settings.Watching(area, p) end,
    set = function(p, v) ns.Settings.SetWatching(area, v, p) end,
  })
end
boolField("alerts", nil, "alerts", true)
boolField("appearance.message", alert, "banner", true)
add({
  key = "appearance.warning-style", type = "enum", values = { "toast", "warning" },
  get = function(p) return ns.Settings.WarningStyle(p) end,
  set = function(p, v) alert(p, true).style = v end,
})
boolField("appearance.chat", alert, "chat", true)
intField("appearance.toast.background-opacity", toast, "bgAlpha", 0, 100, 100, { "views", "toast" })
intField("appearance.toast.text-opacity", toast, "textAlpha", 0, 100, 100, { "views", "toast" })
intField("appearance.toast.scale", toast, "scale", 50, 200, 100, { "views", "toast" })
intField("appearance.explanation.background-opacity", explanation, "bgAlpha", 0, 100, 100, { "views", "explanation" })
intField("appearance.explanation.text-opacity", explanation, "textAlpha", 0, 100, 100, { "views", "explanation" })
intField("appearance.explanation.scale", explanation, "scale", 50, 200, 100, { "views", "explanation" })
intField("alert.cooldown", alert, "cooldown", 1, 30, 3)
add({
  key = "alert.channel", type = "enum", values = CHANNELS,
  get = function(p) local c = alert(p).channel; for _, v in ipairs(CHANNELS) do if v == c then return c end end return "Master" end,
  set = function(p, v) alert(p, true).channel = v end,
})

-- Runs the refreshes an entry declares.
function Registry.Refresh(e)
  for _, name in ipairs(e.refresh) do refreshers[name]() end
end

function Registry.Keys()
  local out = {}
  for _, e in ipairs(list) do out[#out + 1] = e.key end
  return out
end

function Registry.Entry(key) return byKey[(key or ""):lower()] end

-- The allowed values, in words, for a message.
function Registry.Allowed(e)
  if e.type == "bool" then return "on, off" end
  if e.type == "int" then return ("a whole number from %d to %d"):format(e.min, e.max) end
  return table.concat(e.values, ", ")
end

local function show(e, v)
  if e.type == "bool" then return v and "on" or "off" end
  return tostring(v)
end

-- Parses raw text for entry e. Returns the value, or nil and a message naming the allowed values.
function Registry.Parse(e, raw)
  raw = tostring(raw or "")
  local low = raw:lower()
  if e.type == "bool" then
    if low == "on" then return true elseif low == "off" then return false end
  elseif e.type == "int" then
    local n = raw:match("^%d+$") and tonumber(raw)
    if n and n >= e.min and n <= e.max then return n end
  else
    for _, v in ipairs(e.values) do if v:lower() == low then return v end end
  end
  return nil, L["%s: '%s' is not valid. Allowed: %s."]:format(e.key, raw, Registry.Allowed(e))
end

-- Reads a key. Returns the text of the value, or nil and a message.
function Registry.Get(key, p)
  local e = Registry.Entry(key)
  if not e then return nil, L["Unknown setting '%s'. Use /ddt get for the list."]:format(tostring(key)) end
  if not p then return nil, L["settings not available yet"] end
  return show(e, e.get(p)), e
end

-- Writes a key from raw text. Returns the shown value, or nil and a message. Nothing is written on failure.
function Registry.Set(key, raw, p)
  local e = Registry.Entry(key)
  if not e then return nil, L["Unknown setting '%s'. Use /ddt get for the list."]:format(tostring(key)) end
  if not p then return nil, L["settings not available yet"] end
  local v, err = Registry.Parse(e, raw)
  if v == nil then return nil, err end
  e.set(p, v)
  return show(e, e.get(p)), e
end

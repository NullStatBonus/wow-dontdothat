local addonName, ns = ...

-- Bounded debug log. State lives in a table the caller hands in (the SavedVariables
-- sub-table): { enabled = bool, max = number, entries = { {t=, msg=}, ... } }.
local Log = {}
ns.Log = Log

local DEFAULT_MAX = 500

local store
local printer  -- optional function(text); only ever called while debug is on
local clock = function() return time and time() or 0 end

local function fresh()
  return { enabled = false, max = DEFAULT_MAX, entries = {} }
end

-- Binds the log to persisted state, filling defaults. Returns the store.
function Log.Init(saved, opts)
  store = saved or fresh()
  if store.enabled == nil then store.enabled = false end
  if type(store.max) ~= "number" or store.max < 1 then store.max = DEFAULT_MAX end
  if type(store.entries) ~= "table" then store.entries = {} end
  printer = opts and opts.printer or nil
  if opts and opts.clock then clock = opts.clock end
  Log.Trim()
  return store
end

function Log.Trim()
  local entries = store.entries
  local extra = #entries - store.max
  if extra <= 0 then return end
  local kept = {}
  for i = extra + 1, #entries do kept[#kept + 1] = entries[i] end
  for i = #entries, 1, -1 do entries[i] = nil end
  for i = 1, #kept do entries[i] = kept[i] end
end

function Log.IsEnabled()
  return store ~= nil and store.enabled == true
end

function Log.Enable() if store then store.enabled = true end end
function Log.Disable() if store then store.enabled = false end end

-- Slash handlers call these.
function Log.SetEnabled(on)
  if not store then Log.Init() end
  store.enabled = on and true or false
  return store.enabled
end

function Log.SetMax(n)
  if not store then Log.Init() end
  if type(n) == "number" and n >= 1 then store.max = math.floor(n) end
  Log.Trim()
end

-- Records a message when debug is on. Extra args are string.format arguments.
-- Never raises: bad format arguments fall back to the raw message.
function Log.Add(msg, ...)
  if not Log.IsEnabled() then return false end
  local text = tostring(msg)
  if select("#", ...) > 0 then
    local ok, formatted = pcall(string.format, text, ...)
    if ok then text = formatted end
  end
  store.entries[#store.entries + 1] = { t = clock(), msg = text }
  Log.Trim()
  if printer then pcall(printer, text) end
  return true
end

function Log.Clear()
  if store then
    for i = #store.entries, 1, -1 do store.entries[i] = nil end
  end
end

function Log.ClearAll()
  Log.Clear()
end

-- Returns the live entries array (oldest first).
function Log.Entries()
  return store and store.entries or {}
end

function Log.Count()
  return #Log.Entries()
end

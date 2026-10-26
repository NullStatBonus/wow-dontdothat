local addonName, ns = ...

-- The alert sound picker's list, built when needed:
--   1. the common sounds in Data/Sounds.lua (game sound names, so the game supplies the ID),
--   2. sounds registered with LibSharedMedia-3.0, the shared list that sound packs, DBM, BigWigs and
--      WeakAuras all read and add to (used only if some addon provides the library).
-- Keys: a plain key for (1), "lsm:<name>" for (2).
local SoundList = {}
ns.SoundList = SoundList

local function soundkit(env)
  return type(env.SOUNDKIT) == "table" and env.SOUNDKIT or nil
end

local function sharedMedia()
  if type(_G.LibStub) ~= "table" and type(_G.LibStub) ~= "function" then return nil end
  local ok, lib = pcall(_G.LibStub, "LibSharedMedia-3.0", true)
  return ok and lib or nil
end

local function sortedNames(set)
  local names = {}
  for name in pairs(set) do names[#names + 1] = name end
  table.sort(names, function(a, b) return a:lower() < b:lower() end)
  return names
end

-- Ordered { key, label } entries.
function SoundList.Entries(env)
  env = env or _G
  local out = {}
  local kit = soundkit(env)
  for _, entry in ipairs((ns.Sounds and ns.Sounds.list) or {}) do
    -- Where the game exposes its sound names, leave out any this client does not have.
    if not kit or entry.constName == nil or kit[entry.constName] ~= nil then
      out[#out + 1] = { key = entry.key, label = entry.label }
    end
  end

  local lib = sharedMedia()
  if lib then
    local pool = {}
    local ok, hash = pcall(lib.HashTable, lib, "sound")
    if ok and type(hash) == "table" then
      for name in pairs(hash) do
        if name ~= "None" then pool[name] = true end
      end
    end
    for _, name in ipairs(sortedNames(pool)) do
      out[#out + 1] = { key = "lsm:" .. name, label = name .. " (sound pack)" }
    end
  end

  return out
end

-- Returns kind ("soundkit" or "file") and id, or nil when the key cannot be played here.
function SoundList.Resolve(key, env)
  env = env or _G
  if type(key) ~= "string" then return nil end
  local kit = soundkit(env)

  for _, entry in ipairs((ns.Sounds and ns.Sounds.list) or {}) do
    if entry.key == key then
      local id = entry.id
      if id == nil and entry.constName and kit then id = kit[entry.constName] end
      if id == nil then return nil end
      return entry.kind or "soundkit", id
    end
  end

  if key:sub(1, 4) == "lsm:" then
    local lib = sharedMedia()
    if not lib then return nil end
    local ok, path = pcall(lib.Fetch, lib, "sound", key:sub(5), true)
    if ok and path then return "file", path end
  end
  return nil
end

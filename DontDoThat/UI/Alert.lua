local addonName, ns = ...

local Alert = {}
ns.Alert = Alert

Alert.state = { last = {} }

-- Pure cooldown check. Records the firing time in state when it returns true.
function Alert.ShouldFire(actionKey, now, cooldown, state)
  if actionKey == nil or type(now) ~= "number" then return false end
  local last = state.last[actionKey]
  if last and now - last < (cooldown or 0) then return false end
  state.last[actionKey] = now
  return true
end

-- Returns kind, id for a sound key, or nil when it cannot be played here.
function Alert.Resolve(key)
  if ns.SoundList then return ns.SoundList.Resolve(key) end
  -- Without the full list (only the common sounds are known), look the key up directly.
  local sounds = ns.Sounds
  if not sounds then return nil end
  for _, e in ipairs(sounds.list) do
    if e.key == key then
      local id = e.id
      if id == nil and e.constName and type(_G.SOUNDKIT) == "table" then id = _G.SOUNDKIT[e.constName] end
      if id == nil then return nil end
      return e.kind, id
    end
  end
end

local CHANNELS = { Master = true, SFX = true, Music = true, Ambience = true, Dialog = true }
Alert.Channels = CHANNELS

local function playResolved(kind, id, channel)
  local fn = kind == "file" and _G.PlaySoundFile or _G.PlaySound
  if type(fn) ~= "function" then return false end
  local ok, willPlay = pcall(fn, id, CHANNELS[channel] and channel or "Master")
  return ok and willPlay ~= false
end

function Alert.PlaySound(key, settings)
  local default = ns.Sounds and ns.Sounds.default
  local channel = settings and settings.alertChannel
  local kind, id = Alert.Resolve(key)
  if kind and playResolved(kind, id, channel) then return true end
  if key ~= default then
    kind, id = Alert.Resolve(default)
    if kind and playResolved(kind, id, channel) then return true end
  end
  return false
end

local function now()
  if type(_G.GetTime) == "function" then
    local ok, t = pcall(_G.GetTime)
    if ok and type(t) == "number" then return t end
  end
  return os.time()
end

-- Entry point for attempts (click to buy, prompt opening). Hover paths must never call this.
-- Returns true when an alert fired.
function Alert.Trigger(verdict, actionKey, settings, atTime)
  settings = settings or {}
  if type(verdict) ~= "table" then return false end
  -- alertTiers is given for rule verdicts (the player's chosen tiers); other callers alert on defer only.
  local tiers = settings.alertTiers
  if tiers then
    if not tiers[verdict.tier] then return false end
  elseif verdict.tier ~= "defer" then
    return false
  end
  if settings.alertsEnabled == false then return false end
  if not Alert.ShouldFire(actionKey, atTime or now(), settings.alertCooldown or 3, Alert.state) then
    return false
  end
  pcall(Alert.PlaySound, settings.alertSound or (ns.Sounds and ns.Sounds.default), settings)
  if settings.alertBanner ~= false and ns.AlertBanner and ns.AlertBanner.Show then
    pcall(ns.AlertBanner.Show, verdict, verdict.name or actionKey)
  end
  return true
end

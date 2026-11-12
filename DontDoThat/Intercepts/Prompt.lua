local addonName, ns = ...

-- The small pieces every guarded purchase shares (trainer, vendor, auction house, resets): the alert settings from
-- the saved profile, the sound-only copy used when a question is on screen, the banner fallback when no question
-- can be shown, and the one-line chat notice when a guard switches itself off. One copy, so the guards cannot drift.
local Prompt = {}
ns.Prompt = Prompt

-- The alert module's settings, mapped from the saved profile.
function Prompt.AlertSettings()
  local p = (ns.db and ns.db.profile) or {}
  local a = p.alert or {}
  return { alertsEnabled = p.alerts ~= false, alertBanner = a.banner ~= false,
    alertSound = a.sound, alertCooldown = a.cooldown, alertChannel = a.channel }
end

-- A question says everything the banner would, so it gets the sound alone.
function Prompt.SoundOnly(settings)
  local copy = {}
  for k, v in pairs(settings) do copy[k] = v end
  copy.alertBanner = false
  return copy
end

-- When the question cannot be shown, the banner still says what the sound did.
function Prompt.BannerInstead(settings, verdict, name)
  if settings.alertBanner and settings.alertsEnabled and ns.AlertBanner then
    pcall(ns.AlertBanner.Show, verdict, name)
  end
end

function Prompt.Say(text)
  if _G.DEFAULT_CHAT_FRAME and _G.DEFAULT_CHAT_FRAME.AddMessage then
    pcall(_G.DEFAULT_CHAT_FRAME.AddMessage, _G.DEFAULT_CHAT_FRAME, text)
  end
end

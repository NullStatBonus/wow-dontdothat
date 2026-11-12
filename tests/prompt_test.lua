local H = require("harness")

local function fresh(profile)
  local ns = { db = { profile = profile or {} } }
  H.load("DontDoThat/Intercepts/Prompt.lua", ns)
  return ns
end

test("prompt: alert settings come from the profile, channel included, alerts on by default", function()
  local s = fresh({ alert = { sound = "x", cooldown = 3, channel = "Dialog", banner = false }, alerts = false }).Prompt.AlertSettings()
  eq(s, { alertsEnabled = false, alertBanner = false, alertSound = "x", alertCooldown = 3, alertChannel = "Dialog" })
  local d = fresh().Prompt.AlertSettings()
  eq(d.alertsEnabled, true); eq(d.alertBanner, true)
end)

test("prompt: the sound-only copy drops the banner and leaves the original alone", function()
  local P = fresh().Prompt
  local s = { alertBanner = true, alertsEnabled = true }
  local copy = P.SoundOnly(s)
  eq(copy.alertBanner, false); eq(s.alertBanner, true); eq(copy.alertsEnabled, true)
end)

test("prompt: the banner stands in only when the banner and alerts are on", function()
  local ns = fresh(); local shown = 0
  ns.AlertBanner = { Show = function() shown = shown + 1 end }
  ns.Prompt.BannerInstead({ alertBanner = true, alertsEnabled = true }, {}, "n")
  ns.Prompt.BannerInstead({ alertBanner = false, alertsEnabled = true }, {}, "n")
  ns.Prompt.BannerInstead({ alertBanner = true, alertsEnabled = false }, {}, "n")
  eq(shown, 1)
end)

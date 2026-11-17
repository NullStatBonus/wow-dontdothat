local H = require("harness")

local function fresh(profile)
  local ns = { db = { profile = profile or {} } }
  H.load("DontDoThat/UI/Alert.lua", ns)
  H.load("DontDoThat/Intercepts/Prompt.lua", ns)
  return ns
end

test("prompt: alert settings come from the profile, channel included, alerts on by default", function()
  local s = fresh({ alert = { sound = "x", cooldown = 3, channel = "Dialog", banner = false, style = "warning", chat = false }, alerts = false }).Prompt.AlertSettings()
  eq(s, { alertsEnabled = false, alertBanner = false, alertSound = "x", alertCooldown = 3, alertChannel = "Dialog",
    alertStyle = "warning", alertChat = false })
  local d = fresh().Prompt.AlertSettings()
  eq(d.alertsEnabled, true); eq(d.alertBanner, true); eq(d.alertChat, true)
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
  ns.Prompt.BannerInstead({ alertBanner = true, alertsEnabled = true, alertStyle = "warning" }, {}, "n")
  ns.Prompt.BannerInstead({ alertBanner = false, alertsEnabled = true, alertStyle = "warning" }, {}, "n")
  ns.Prompt.BannerInstead({ alertBanner = true, alertsEnabled = false, alertStyle = "warning" }, {}, "n")
  eq(shown, 1)
  local toasts = 0
  ns.Toast = { Show = function() toasts = toasts + 1 end }
  ns.Prompt.BannerInstead({ alertBanner = true, alertsEnabled = true }, {}, "n")
  eq(toasts, 1); eq(shown, 1)
end)

test("prompt: Say sends the text to the default chat frame", function()
  local P = fresh().Prompt
  local got = {}
  _G.DEFAULT_CHAT_FRAME = { AddMessage = function(self, text) got[#got + 1] = { self = self, text = text } end }
  P.Say("hello")
  eq(#got, 1); eq(got[1].text, "hello")
  truthy(got[1].self == _G.DEFAULT_CHAT_FRAME, "called as a method on the frame")
  _G.DEFAULT_CHAT_FRAME = nil
end)

test("prompt: Say is quiet with no chat frame, no AddMessage, or an AddMessage that throws", function()
  local P = fresh().Prompt
  _G.DEFAULT_CHAT_FRAME = nil
  P.Say("no frame")
  _G.DEFAULT_CHAT_FRAME = {}
  P.Say("no AddMessage")
  _G.DEFAULT_CHAT_FRAME = { AddMessage = function() error("chat broke") end }
  P.Say("throws")
  _G.DEFAULT_CHAT_FRAME = nil
end)

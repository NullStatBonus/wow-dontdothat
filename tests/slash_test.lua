package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local function fresh(profile)
  local ns = { version = "9.9.9", build = "1" }
  local said = {}
  ns.addon = { Print = function(_, m) said[#said + 1] = m end, RegisterChatCommand = function() end, db = { profile = profile or {}, global = {}, char = {} } }
  H.load("DontDoThat/Model/Settings.lua", ns)
  H.load("DontDoThat/Core/Registry.lua", ns)
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  H.load("DontDoThat/Core/Slash.lua", ns)
  return ns, said, function(s) ns.addon:HandleSlash(s) end
end

local function joined(said) return table.concat(said, "\n") end

test("slash: bare and settings open pages, unknown page lists choices", function()
  local ns, said, run = fresh()
  local opened = {}
  ns.Options = { Open = function(k) opened[#opened + 1] = k end }
  run(""); run("settings"); run("settings Sound"); run("settings nowhere"); run("settings sound extra")
  eq(opened, { "home", "home", "sound" })
  truthy(joined(said):find("Pages: home, watch", 1, true))
  truthy(joined(said):find("usage: /ddt settings", 1, true))
end)

test("slash: set acknowledges once, refreshes, and keeps names' case out of it", function()
  local ns, said, run = fresh()
  local refreshed = 0
  ns.Options = { Refresh = function() refreshed = refreshed + 1 end }
  ns.Toast = { Refresh = function() refreshed = refreshed + 1 end }
  run("SET Appearance.Toast.Scale 150")
  eq(#said, 1); eq(ns.addon.db.profile.toast.scale, 150); eq(refreshed, 2)
  run("set nudge mark"); eq(ns.Settings.Nudge(ns.addon.db.profile), "mark")
end)

test("slash: invalid set and surplus words change nothing", function()
  local ns, said, run = fresh()
  run("set appearance.toast.scale 500"); run("set nudge custom"); run("set nudge ask extra"); run("set nudge")
  run("get a b"); run("settings"); run("demo now"); run("debug on extra")
  eq(next(ns.addon.db.profile), nil)
  truthy(#said >= 7)
end)

test("slash: get reads, lists keys", function()
  local ns, said, run = fresh({ alert = { cooldown = 7 } })
  run("get alert.cooldown"); eq(said[1], "alert.cooldown = 7")
  run("get"); truthy(said[2]:find("nudge", 1, true))
  run("get bogus"); truthy(said[3]:find("Unknown setting", 1, true))
end)

test("slash: status summary and topics, help topics, errors", function()
  local ns, said, run = fresh({})
  run("status"); eq(#said, 4)
  said = {}
  local _, s2, run2 = fresh({ warnings = false })
  run2("status nudge"); truthy(joined(s2):find("custom", 1, true)); eq(#s2, 2)
  run2("status sound"); truthy(s2[3]:find("channel Master", 1, true))
  run2("status bogus"); truthy(s2[4]:find("Topics: nudge, warnings, explanations, sound", 1, true))
  run2("help rules"); run2("help appearance"); run2("help diagnostics")
  run2("help bogus"); truthy(s2[#s2]:find("Topics: appearance, rules, diagnostics", 1, true))
  run2("help"); truthy(s2[#s2]:find("/ddt log", 1, true))
end)

test("slash: demo and preview route; no kind lists them", function()
  local ns, said, run = fresh()
  local got = {}
  ns.Demo = { Run = function() got[#got + 1] = "run" end, Preview = function(k) got[#got + 1] = k end }
  run("demo"); run("preview Toast"); run("preview"); run("preview zzz")
  eq(got, { "run", "toast" })
  truthy(joined(said):find("toast, warning, mark, tooltip, explanation, prompt", 1, true))
end)

test("slash: log and export are the same; clear is immediate, log clear asks first", function()
  local ns, said, run = fresh()
  local shown, cleared, answer = 0, 0
  ns.Export = { Show = function() shown = shown + 1 end }
  ns.Log = { ClearAll = function() cleared = cleared + 1 end }
  local saved = { _G.StaticPopup_Show, _G.StaticPopupDialogs }
  _G.StaticPopupDialogs = {}
  _G.StaticPopup_Show = function(key, _, _, data) answer = { yes = data.yes, no = data.no }; return {} end
  run("log"); run("export"); eq(shown, 2)
  run("clear"); eq(cleared, 1)
  run("log clear"); eq(cleared, 1, "asks first")
  answer.no(); eq(cleared, 1, "cancel clears nothing")
  run("log clear"); answer.yes(); eq(cleared, 2)
  _G.StaticPopup_Show, _G.StaticPopupDialogs = nil, nil
  run("log clear"); eq(cleared, 2)
  truthy(joined(said):find("Use /ddt clear", 1, true))
  _G.StaticPopup_Show, _G.StaticPopupDialogs = saved[1], saved[2]
  run("log purge"); run("export now"); eq(shown, 2)
end)

test("slash: log clear leaves an open purchase question alone", function()
  local ns, said, run = fresh()
  local declined = 0
  ns.Log = { ClearAll = function() end }
  ns.ConfirmPopup = { Show = function() declined = declined + 1; return true end }
  local savedShow, savedDialogs = _G.StaticPopup_Show, _G.StaticPopupDialogs
  local shownKey
  _G.StaticPopupDialogs = {}
  _G.StaticPopup_Show = function(key) shownKey = key; return {} end
  run("log clear")
  _G.StaticPopup_Show, _G.StaticPopupDialogs = savedShow, savedDialogs
  eq(shownKey, "DONTDOTHAT_LOG_CLEAR"); eq(declined, 0, "shared popup untouched")
end)

test("slash: set runs the same refresh as the settings control", function()
  local ns, said, run = fresh()
  local calls = {}
  ns.Options = { Apply = function() calls[#calls + 1] = "apply" end, Refresh = function() calls[#calls + 1] = "options" end }
  ns.InfoBubble = { RefreshAppearance = function() calls[#calls + 1] = "bubble" end }
  run("set watch.spells off")
  truthy(table.concat(calls, ","):find("apply", 1, true))
  calls = {}
  run("set appearance.explanation.scale 150")
  truthy(table.concat(calls, ","):find("bubble", 1, true)); eq(ns.addon.db.profile.explanation.scale, 150)
end)

test("slash: get and status are read-only", function()
  local ns, said, run = fresh({})
  for _, k in ipairs(ns.Registry.Keys()) do run("get " .. k) end
  run("status")
  eq(next(ns.addon.db.profile), nil, "no tables created by reading")
end)

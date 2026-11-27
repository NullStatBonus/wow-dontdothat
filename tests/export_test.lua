local H = require("harness")

local function load()
  local ns = { version = "0.1.0", L = setmetatable({}, { __index = function(_, k) return k end }) }
  H.load("DontDoThat/Model/Settings.lua", ns)
  H.load("DontDoThat/Core/Registry.lua", ns)
  H.load("DontDoThat/Debug/Export.lua", ns)
  return ns.Export
end

test("build includes every section", function()
  local E = load()
  local text = E.Build({
    settings = { alerts = { sound = true }, debug = false },
    ledger = { verified = 100, projected = 250 },
    log = { { t = 0, msg = "blocked Arcane Shot r2" } },
    probe = "== Probe ==\nline",
    env = { LibStub = { libs = { ["AceAddon-3.0"] = {} }, minors = { ["AceAddon-3.0"] = 13 } } },
  })
  truthy(text:find("addon version: 0.1.0", 1, true))
  truthy(text:find("== Settings ==", 1, true))
  truthy(text:find("  alerts:\n    sound = true", 1, true))
  truthy(text:find("projected = 250", 1, true))
  truthy(text:find("blocked Arcane Shot r2", 1, true))
  truthy(text:find("AceAddon-3.0 (minor 13)", 1, true))
  truthy(text:find("== Probe ==\n== Probe ==\nline", 1, true))
end)

test("build tolerates missing sources and LibStub", function()
  local E = load()
  local text = E.Build({ env = {} })
  truthy(text:find("LibStub not present", 1, true))
  truthy(text:find("(not available)", 1, true))
  truthy(text:find("(no probe report)", 1, true))
  truthy(E.Build() ~= nil)
end)

test("build isolates a failing probe function and survives cycles", function()
  local E = load()
  local cyc = {}
  cyc.self = cyc
  local text = E.Build({ settings = cyc, probe = function() error("bad probe") end, env = {} })
  truthy(text:find("<...>", 1, true))
  truthy(text:find("FAILED", 1, true))
  truthy(text:find("== Libraries ==", 1, true))
end)

test("build output is deterministic", function()
  local E = load()
  local s = { settings = { b = 1, a = 2, c = { z = 1, y = 2 } }, env = {} }
  eq(E.Build(s), E.Build(s))
end)

test("show without WoW globals does not raise", function()
  local E = load()
  truthy(E.Show({ env = {} }), "no window: the report goes to chat, nothing raises")
end)

test("report lists the presentation settings", function()
  local E = load()
  local text = E.Build({ settings = { alert = { style = "warning", chat = false }, toast = { scale = 80 }, explanation = { bgAlpha = 30 } },
    presentation = { "sample: toast active" }, profileName = "Default", env = {} })
  truthy(text:find("== Presentation ==", 1, true))
  truthy(text:find("warning style: warning", 1, true))
  truthy(text:find("chat record: off", 1, true))
  truthy(text:find("toast: background nil, text nil, scale 80", 1, true) == nil)
  truthy(text:find("toast: background 100, text 100, scale 80", 1, true))
  truthy(text:find("active profile: Default", 1, true))
  truthy(text:find("scope: settings shared", 1, true))
  truthy(text:find("toast position: default", 1, true))
  truthy(text:find("explanation: background 30", 1, true))
  truthy(text:find("sample: toast active", 1, true))
end)

test("Show falls back to chat with the whole report when no window can be made", function()
  local E = load()
  local printed = {}
  E.env = { LibStub = function() return nil end, DEFAULT_CHAT_FRAME = nil }
  local real = _G.DEFAULT_CHAT_FRAME
  _G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) printed[#printed + 1] = m end }
  local long = string.rep("Q", 600)
  local ok = E.Show({ settings = { note = long }, env = {} })
  _G.DEFAULT_CHAT_FRAME = real
  E.env = nil
  truthy(ok)
  local all = table.concat(printed, "\n")
  truthy(all:find("== Presentation ==", 1, true))
  truthy(all:find("== Libraries ==", 1, true))
  local xs = 0
  for _, m in ipairs(printed) do truthy(#m <= 240); xs = xs + select(2, m:gsub("Q", "")) end
  eq(xs, 600)
end)

test("Show opens one window and reopening replaces it", function()
  local E = load()
  local created, released = 0, 0
  local gui = { Create = function(_, kind)
    created = created + 1
    local o = { kind = kind }
    for _, m in ipairs({ "SetTitle", "SetStatusText", "SetLayout", "SetCallback", "SetLabel", "DisableButton", "SetText", "AddChild", "SetFocus", "HighlightText" }) do o[m] = function() end end
    o.Release = function() released = released + 1 end
    return o
  end, Release = function() end }
  E.env = { LibStub = function() return gui end }
  truthy(E.Show({ env = {} })); truthy(E.Show({ env = {} }))
  eq(created, 4); eq(released, 1, "the old window is released, not duplicated")
  E.env = nil
end)

test("the log window closes on Escape and leaves UISpecialFrames when closed or replaced", function()
  local E = load()
  local onClose
  local gui = { Create = function(_, kind)
    local o = { kind = kind, frame = {} }
    for _, m in ipairs({ "SetTitle", "SetStatusText", "SetLayout", "SetLabel", "DisableButton", "SetText", "AddChild", "SetFocus", "HighlightText" }) do o[m] = function() end end
    o.SetCallback = function(_, name, fn) if name == "OnClose" then onClose = fn; o.close = fn end end
    o.Release = function() end
    return o
  end, Release = function() end }
  local env = { LibStub = function() return gui end, UISpecialFrames = {} }
  E.env = env
  truthy(E.Show({ env = {} }))
  eq(env.UISpecialFrames, { "DontDoThatLogFrame" }); truthy(env.DontDoThatLogFrame)
  truthy(E.Show({ env = {} })); eq(#env.UISpecialFrames, 1, "reopening does not duplicate")
  local f = env.DontDoThatLogFrame
  onClose({ frame = f })
  eq(#env.UISpecialFrames, 0); eq(env.DontDoThatLogFrame, nil)
  E.env = nil
end)

-- The Rules block: every profile default shows with its effective value, saved or not.
local function loadWithDefaults()
  local ns = { version = "0.1.0", L = setmetatable({}, { __index = function(_, k) return k end }) }
  _G.LibStub = function() return setmetatable({}, { __index = function() return function() return {} end end }) end
  local stubbed = { CreateFrame = function() return {} end }
  for k, v in pairs(stubbed) do _G[k] = v end
  H.load("DontDoThat/Core/Addon.lua", ns)
  _G.LibStub = nil; _G.CreateFrame = nil
  H.load("DontDoThat/Model/Settings.lua", ns)
  H.load("DontDoThat/Core/Registry.lua", ns)
  H.load("DontDoThat/Debug/Export.lua", ns)
  return ns
end

test("build: the Rules block lists every profile default with defaults applied", function()
  local ns = loadWithDefaults()
  local text = ns.Export.Build({ settings = { tuning = { skipRevision = 2 }, minPrice = 5000 }, env = {} })
  local rules = text:match("== Rules ==\n(.-)\n\n== ")
  truthy(rules, text)
  local n = 0
  for key in pairs(ns.defaults.profile) do
    n = n + 1
    truthy(rules:find("\n  " .. key .. ": ", 1, true) or rules:find("^  " .. key .. ": "), "missing profile default: " .. key)
  end
  truthy(n > 10)
  truthy(rules:find("minPrice: 5000", 1, true)); truthy(rules:find("blockingConfirmations: true", 1, true))
  truthy(rules:find("skip revision: 2", 1, true)); truthy(rules:find("stop point: level 60", 1, true))
  truthy(rules:find("nudge level: ask", 1, true)); truthy(rules:find("prompt tiers: defer=true, deferLow=false, info=false", 1, true))
  truthy(rules:find("what to watch: spells=true, professions=true, shopping=true", 1, true))
  truthy(rules:find("itemModes: {ammo=ah", 1, true))
end)

test("report lists this character's allowed items by ID and name, or none", function()
  local ns = { version = "0.1.0", L = setmetatable({}, { __index = function(_, k) return k end }) }
  for _, f in ipairs({ "UI/Helpers.lua", "Model/Settings.lua", "Core/Registry.lua", "Debug/Export.lua", "Intercepts/ItemGuard.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  ns.db = { profile = {}, char = { allowedItems = {} }, global = {} }
  truthy(ns.Export.Build({ items = ns.ItemGuard.Report({}), env = {} }):find("allowedItems = none", 1, true))
  ns.ItemGuard.Allow(10050, "Mageweave Bag")
  local text = ns.Export.Build({ items = ns.ItemGuard.Report({}), settings = {}, env = {} })
  truthy(text:find("10050 Mageweave Bag", 1, true), text)
  truthy(text:find("allowed items per character", 1, true))
end)

test("report shows the test-settings state, the profile in use and the CheckThat status", function()
  local ns = { version = "0.1.0", L = setmetatable({}, { __index = function(_, k) return k end }) }
  for _, f in ipairs({ "UI/Helpers.lua", "Model/Settings.lua", "Core/Registry.lua", "Debug/Export.lua" }) do H.load("DontDoThat/" .. f, ns) end
  ns.db = { profile = {}, char = {}, global = {} }
  local off = ns.Export.Build({ settings = {}, env = {}, profileName = "Raid", checkThat = "not detected" })
  truthy(off:find("active profile: Raid", 1, true), off)
  truthy(off:find("test settings: off", 1, true))
  truthy(off:find("CheckThat: not detected", 1, true))
  local on = ns.Export.Build({ settings = {}, env = {}, profileName = "DDT test", testSettings = "Raid", checkThat = "working" })
  truthy(on:find("active profile: DDT test", 1, true), on)
  truthy(on:find("test settings: on (temporary profile in use; own profile Raid)", 1, true), on)
  truthy(on:find("CheckThat: working", 1, true))
end)

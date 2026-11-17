package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = {}
H.load("DontDoThat/Model/Settings.lua", ns)
H.load("DontDoThat/Core/Registry.lua", ns)
local R = ns.Registry

test("registry: every public key has a getter and defaults read as the spec table", function()
  local p = {}
  eq(#R.Keys(), 17)
  eq(R.Get("enabled", p), "on")
  eq(R.Get("nudge", {}), "ask")
  eq(R.Get("appearance.warning-style", p), "toast")
  eq(R.Get("appearance.toast.scale", p), "100")
  eq(R.Get("alert.cooldown", p), "3")
  eq(R.Get("alert.channel", p), "Master")
end)

test("registry: set writes the model and get reads it back", function()
  local p = {}
  eq(R.Set("nudge", "mark", p), "mark")
  eq(ns.Settings.Nudge(p), "mark")
  eq(R.Set("appearance.explanation.text-opacity", "40", p), "40")
  eq(p.explanation.textAlpha, 40)
  eq(R.Set("alert.channel", "sfx", p), "SFX")
  eq(p.alert.channel, "SFX")
  eq(R.Set("watch.shopping", "off", p), "off")
  eq(p.watch.shopping, false)
  eq(R.Set("appearance.message", "off", p), "off")
  eq(p.alert.banner, false)
end)

test("registry: nudge get may return custom but custom cannot be set", function()
  local p = { warnings = false }
  eq(R.Get("nudge", p), "custom")
  local v, err = R.Set("nudge", "custom", p)
  eq(v, nil); truthy(err:find("mark, ask, everything", 1, true))
  eq(p.warnings, false)
end)

test("registry: invalid input never writes", function()
  local p = {}
  for _, c in ipairs({
    { "appearance.toast.scale", "49" }, { "appearance.toast.scale", "201" }, { "appearance.toast.scale", "100.5" },
    { "appearance.toast.background-opacity", "-1" }, { "alert.cooldown", "0" }, { "alert.cooldown", "abc" },
    { "enabled", "maybe" }, { "alert.channel", "Loud" }, { "appearance.warning-style", "big" },
  }) do
    local v, err = R.Set(c[1], c[2], p)
    eq(v, nil, c[1] .. " " .. c[2]); truthy(err)
  end
  eq(next(p), nil, "profile untouched")
  local v, err = R.Set("nope", "1", p)
  eq(v, nil); truthy(err:find("Unknown setting", 1, true))
end)

test("getters read without creating groups", function()
  local ns = { version = "1", L = setmetatable({}, { __index = function(_, k) return k end }) }
  local H = require("harness")
  H.load("DontDoThat/Model/Settings.lua", ns)
  H.load("DontDoThat/Core/Registry.lua", ns)
  local p = {}
  for _, k in ipairs(ns.Registry.Keys()) do ns.Registry.Get(k, p) end
  eq(next(p), nil)
  ns.Registry.Set("alert.cooldown", "5", p)
  eq(p.alert.cooldown, 5)
end)

test("registry: every entry declares type, scope, get, set and refresh", function()
  for _, k in ipairs(R.Keys()) do
    local e = R.Entry(k)
    truthy(e.type and e.scope and e.get and e.set and e.refresh and #e.refresh > 0, k)
    for _, name in ipairs(e.refresh) do truthy(R.Refreshers[name], k .. " " .. name) end
  end
  eq(R.Entry("nudge").scope, "derived profile")
  eq(R.Entry("enabled").scope, "profile")
end)

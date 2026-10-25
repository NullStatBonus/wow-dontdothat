local H = require("harness")

local function load()
  local ns = { version = "0.1.0" }
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
  eq(E.Show({ env = {} }), false)
end)

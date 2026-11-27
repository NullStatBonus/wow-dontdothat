local H = require("harness")

-- A fresh CheckThat module over a fake adapter, started with ctx (a log collector is added). `t` is the fake
-- CheckThat table (nil = not loaded). Returns the module, the log lines and Start's result.
local function boot(t, ctx)
  local ns = { Adapter = { checkThat = function() return t end } }
  H.load("DontDoThat/CheckThat.lua", ns)
  local logs = {}
  ctx = ctx or {}
  ctx.log = function(m) logs[#logs + 1] = m end
  local n = ns.CheckThat.Start(ctx)
  return ns.CheckThat, logs, n
end

local function current()
  local t = { entries = {}, hooks = {} }
  function t.Entry(addon, name, fn) t.entries[name] = fn; return true end
  function t.OnRun(addon, fn) t.hooks[addon] = fn; return true end
  function t.ActiveRun() return nil end
  return t
end

test("checkthat adapter: the global when it is a table, else nil", function()
  local ns = {}
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  eq(ns.Adapter.checkThat({}), nil)
  eq(ns.Adapter.checkThat({ CheckThat = "x" }), nil)
  local t = {}
  eq(ns.Adapter.checkThat({ CheckThat = t }), t)
end)

test("adapter readVersion: C_AddOns first, the global second, nil when neither or raising", function()
  local ns = {}
  H.load("DontDoThat/Intercepts/Adapter.lua", ns)
  local A = ns.Adapter
  eq(A.readVersion({ C_AddOns = { GetAddOnMetadata = function(n, f) return n == "DontDoThat" and f == "Version" and "1.0.0" end } }), "1.0.0")
  eq(A.readVersion({ GetAddOnMetadata = function() return "0.15.0" end }), "0.15.0")
  eq(A.readVersion({}), nil)
  eq(A.readVersion({ GetAddOnMetadata = function() error("boom") end }), nil)
  eq(A.readVersion({ GetAddOnMetadata = function() return 5 end }), nil)
end)

test("checkthat: not installed registers nothing and says so", function()
  local CT, logs, n = boot(nil, { version = function() return "0.15.0" end })
  eq(n, 0)
  eq(CT.Status(), "not detected")
  eq(#logs, 0)
end)

test("checkthat: too old (no Entry, no OnRun) changes nothing", function()
  local CT, logs, n = boot({})
  eq(n, 0)
  eq(CT.Status(), "too old")
  eq(logs, { "checkthat: run hook not available" })
end)

test("checkthat: a CheckThat with Entry but no OnRun logs the missing hook", function()
  local t = current(); t.OnRun = nil
  local _, logs, n = boot(t)
  eq(n, 3)
  eq(logs, { "checkthat: run hook not available", "checkthat: entries registered: 3" })
end)

test("checkthat: current registers three entries and the run hook", function()
  local t = current()
  local CT, logs, n = boot(t, { version = function() return "0.15.0" end })
  eq(n, 3)
  truthy(t.entries.version and t.entries.testsettings and t.entries.setting)
  truthy(t.hooks.DontDoThat)
  eq(CT.Status(), "working")
  eq(logs, { "checkthat: run hook registered", "checkthat: entries registered: 3" })
end)

test("checkthat: version entry encodes major*10000 + minor*100 + patch", function()
  local function entry(v)
    local t = current()
    boot(t, { version = function() return v end })
    return t.entries.version
  end
  eq(entry("0.15.0")(), 1500)
  eq(entry("1.0.0")(), 10000)
  eq(select("#", entry(nil)()), 0)
  eq(select("#", entry("dev")()), 0)
end)

test("checkthat: testsettings and setting entries read the context and write no log line", function()
  local t = current()
  local on = false
  local CT, logs = boot(t, {
    testSettings = function() return on end,
    setting = function(k) if k == "style" then return "warning" end end,
    char = function(k) if k == "marks" then return "40" elseif k == "allowed" then return 3 end end,
  })
  local n = #logs
  eq(t.entries.testsettings(), "off"); on = true
  eq(t.entries.testsettings(), "on")
  eq(t.entries.setting("STYLE"), "warning")
  eq(select("#", t.entries.setting("nope")), 0)
  eq(t.entries.setting("marks"), "40")
  eq(t.entries.setting("allowed"), 3)
  eq(#logs, n, "entry calls wrote a log line")
end)

test("checkthat: Entry raising turns the integration off and logs the reason", function()
  local t = current()
  function t.Entry() error("old api") end
  local CT, logs = boot(t)
  truthy(CT.Status():find("failed: Entry:", 1, true))
  truthy(logs[#logs]:find("checkthat: FAILED: Entry:", 1, true))
end)

test("checkthat: OnRun raising turns the integration off; later entries answer nothing", function()
  local t = current()
  function t.OnRun() error("nope") end
  local CT, logs = boot(t)
  truthy(CT.Status():find("failed: OnRun:", 1, true))
  eq(next(t.entries), nil)
end)

test("checkthat: an error inside an entry is returned as a value, not logged, and the integration stays on", function()
  local t = current()
  local CT, logs = boot(t, { testSettings = function() error("bad") end })
  local n = #logs
  truthy(t.entries.testsettings():find("error: ", 1, true))
  eq(#logs, n)
  eq(CT.Status(), "working")
end)

test("checkthat: run start and end reach the addon's handlers; a hook error is logged and not raised", function()
  local t = current()
  local seen = {}
  local CT, logs = boot(t, {
    runStarted = function(id) seen[#seen + 1] = "start " .. tostring(id) end,
    runEnded = function(reason) seen[#seen + 1] = "end " .. tostring(reason); error("handler") end,
  })
  t.hooks.DontDoThat("start", { runId = "r1" })
  t.hooks.DontDoThat("end", { reason = "ended" })
  eq(seen, { "start r1", "end ended" })
  truthy(logs[#logs]:find("checkthat: FAILED: runEnded:", 1, true))
  eq(CT.Status(), "working")
end)

test("checkthat: no open run at login calls runGone before the hook is registered", function()
  local t = current()
  local order = {}
  local onRun = t.OnRun
  function t.OnRun(a, f) order[#order + 1] = "hook"; return onRun(a, f) end
  boot(t, { runGone = function() order[#order + 1] = "gone" end })
  eq(order, { "gone", "hook" })
  -- an open run: no runGone
  t = current(); function t.ActiveRun() return "plan" end
  order = {}
  boot(t, { runGone = function() order[#order + 1] = "gone" end })
  eq(order, {})
end)

test("checkthat: ActiveRun raising turns the integration off", function()
  local t = current()
  function t.ActiveRun() error("x") end
  local CT = boot(t)
  truthy(CT.Status():find("failed: ActiveRun:", 1, true))
end)

test("checkthat: after a failure runStarted stays off and runEnded still restores", function()
  local t = current()
  local seen = {}
  local CT = boot(t, {
    runStarted = function() seen[#seen + 1] = "start" end,
    runEnded = function() seen[#seen + 1] = "end" end,
  })
  CT.Fail("boom")
  t.hooks.DontDoThat("start", { runId = "r" })
  t.hooks.DontDoThat("end", {})
  eq(seen, { "end" })
  eq(select("#", t.entries.version()), 0)
end)

test("checkthat: RunOpen is true only with an open run; missing, old or raising CheckThat means no run", function()
  local t = current(); function t.ActiveRun() return "plan" end
  eq(boot(t).RunOpen(), true)
  t = current()
  eq(boot(t).RunOpen(), false)
  t = current(); t.ActiveRun = nil
  eq(boot(t).RunOpen(), false)
  eq(boot(nil).RunOpen(), false)
  t = current(); function t.ActiveRun() error("x") end
  local CT = boot(t)
  eq(CT.RunOpen(), false)
  truthy(CT.Status():find("failed: ActiveRun:", 1, true))
end)

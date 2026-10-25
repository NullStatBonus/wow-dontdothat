local H = require("harness")

local function newLog(saved, opts)
  local ns = {}
  H.load("DontDoThat/Debug/Log.lua", ns)
  ns.Log.Init(saved, opts)
  return ns.Log
end

test("log is off by default and records nothing", function()
  local printed = {}
  local log = newLog({}, { printer = function(s) printed[#printed + 1] = s end })
  falsy(log.IsEnabled())
  falsy(log.Add("hello"))
  eq(log.Count(), 0)
  eq(#printed, 0)
end)

test("log records and prints only when enabled", function()
  local printed = {}
  local log = newLog({}, { printer = function(s) printed[#printed + 1] = s end, clock = function() return 7 end })
  log.SetEnabled(true)
  truthy(log.Add("rank %d blocked", 3))
  eq(log.Entries()[1], { t = 7, msg = "rank 3 blocked" })
  eq(printed, { "rank 3 blocked" })
  log.SetEnabled(false)
  log.Add("quiet")
  eq(log.Count(), 1)
  eq(#printed, 1)
end)

test("oldest entries drop past the limit", function()
  local log = newLog({ enabled = true, max = 3 })
  for i = 1, 5 do log.Add("m" .. i) end
  eq(log.Count(), 3)
  eq(log.Entries()[1].msg, "m3")
  eq(log.Entries()[3].msg, "m5")
end)

test("default limit is 500", function()
  local saved = { enabled = true }
  local log = newLog(saved)
  for i = 1, 520 do log.Add("x") end
  eq(log.Count(), 500)
  eq(saved.max, 500)
end)

test("persisted oversize entries are trimmed on init", function()
  local saved = { enabled = true, max = 2, entries = { { msg = "a" }, { msg = "b" }, { msg = "c" } } }
  local log = newLog(saved)
  eq(log.Count(), 2)
  eq(saved.entries[1].msg, "b")
end)

test("clear empties the persisted table in place", function()
  local saved = { enabled = true }
  local log = newLog(saved)
  log.Add("a")
  log.ClearAll()
  eq(#saved.entries, 0)
end)

test("bad format args do not raise", function()
  local log = newLog({ enabled = true })
  log.Add("%d items", "notanumber")
  eq(log.Entries()[1].msg, "%d items")
end)

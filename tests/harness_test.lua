local H = require("harness")

test("deepEqual compares nested tables", function()
  truthy(H.deepEqual({ a = { 1, 2 } }, { a = { 1, 2 } }))
  falsy(H.deepEqual({ a = 1 }, { a = 2 }))
  falsy(H.deepEqual({ a = 1 }, { a = 1, b = 2 }))
end)

test("addon files load with (addonName, ns) varargs and no WoW globals", function()
  local ns = {}
  H.load("DontDoThat/Core/Init.lua", ns)
  eq(ns.name, "DontDoThat")
  eq(ns.version, "unknown")
end)

test("raises matches error text", function()
  raises(function() error("boom detail") end, "boom")
end)

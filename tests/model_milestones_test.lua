package.path = "./tests/?.lua;" .. package.path
local H = require("harness")
local ns = {}
H.load("DontDoThat/Model/Milestones.lua", ns)
local M = ns.Milestones

test("defaults", function()
  eq(M.Defaults[40].riding, 1000000)
  eq(M.Defaults[60].riding, 10000000)
  eq(M.Defaults[60].mount, 2000000)
end)
test("before the 40 mount: active, saving for 40", function()
  eq(M.State(false, false), { current = 40, state = "active" })
end)
test("after the 40 mount: still active, now saving for 60 (no pause)", function()
  eq(M.State(true, false), { current = 60, state = "active" })
end)
test("after the 60 mount: finished", function()
  eq(M.State(true, true), { current = nil, state = "finished" })
end)
test("60 riding implies 40 complete", function() eq(M.State(false, true).state, "finished") end)
test("manual override 40 moves to the 60 milestone and stays active", function()
  eq(M.State(false, false, { [40] = true }), { current = 60, state = "active" })
end)
test("manual override 60 finishes", function()
  eq(M.State(false, false, { [60] = true }).state, "finished")
end)
test("there is no dormant state", function()
  for _, learned40 in ipairs({ false, true }) do
    for _, learned60 in ipairs({ false, true }) do
      truthy(M.State(learned40, learned60).state ~= "dormant")
    end
  end
end)

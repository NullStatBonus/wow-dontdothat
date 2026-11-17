package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

test("Saving follows the milestone, stops for no profile, and keeps warning on a fault", function()
  local ns = {}
  H.load("DontDoThat/Intercepts/Context.lua", ns)
  local result
  ns.Context.Profile = function() if result == "error" then error("boom") end return result end
  result = { milestone = { state = "active" } }; truthy(ns.Context.Saving({}))
  result = { milestone = { state = "finished" } }; falsy(ns.Context.Saving({}))
  result = nil; falsy(ns.Context.Saving({}))
  result = "error"; truthy(ns.Context.Saving({}))
end)

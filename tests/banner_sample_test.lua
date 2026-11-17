local H = require("harness")
local F = require("fakeframes")

test("warning banner: recommendation in words; HideSample never hides a real warning", function()
  local restore = F.install()
  local ns = {}
  H.load("DontDoThat/UI/Helpers.lua", ns)
  H.load("DontDoThat/UI/AlertBanner.lua", ns)
  local v = { tier = "deferLow", cost = 100, reason = "Why." }
  truthy(ns.AlertBanner.ShowSample(v, "Sample"))
  local f = F.frames[1]
  truthy(f:IsShown())
  eq(f.recommendation.text, "Not worth buying yet")
  truthy(ns.AlertBanner.HideSample()); falsy(f:IsShown())
  ns.AlertBanner.ShowSample(v, "Sample")
  ns.AlertBanner.Show(v, "Real")
  falsy(ns.AlertBanner.HideSample()); truthy(f:IsShown())
  eq(f.title.text, "Real costs 1s.")
  restore()
end)

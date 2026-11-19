package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local GOLD = 10000

local function fresh(milestone)
  local ns = { version = "0.1.0" }
  for _, f in ipairs({ "UI/Helpers.lua", "Data/Sounds.lua", "Data/SpellData.lua", "Data/RuleSpells.lua", "Data/SkipRevisions.lua",
    "Data/TalentData.lua", "Model/SpellData.lua", "Rules/Schema.lua", "Rules/Engine.lua", "Rules/Data/Hunter.lua",
    "Model/Milestones.lua", "Intercepts/Adapter.lua", "UI/ConfirmPopup.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  ns.Context = { Profile = function() return { class = "HUNTER", milestone = milestone } end }
  return ns
end

local active40 = { current = 40, state = "active" }
local function gold(n) return { GetMoney = function() return n * GOLD end } end

test("fund line: still short after buying", function()
  local P = fresh(active40).ConfirmPopup
  eq(P.FundLine(12 * GOLD, gold(73)), "After this you'll have 61g of the 100g for your level 40 mount.")
end)

test("fund line: the purchase takes the player below the target", function()
  local P = fresh(active40).ConfirmPopup
  eq(P.FundLine(12 * GOLD, gold(105)), "After this you'll have 93g of the 100g for your level 40 mount.")
end)

test("fund line: none when the player still has enough", function()
  local P = fresh(active40).ConfirmPopup
  eq(P.FundLine(12 * GOLD, gold(150)), nil)
  eq(P.FundLine(12 * GOLD, gold(112)), nil, "exactly the target after paying")
end)

test("fund line: none when the price or gold is unknown", function()
  local P = fresh(active40).ConfirmPopup
  eq(P.FundLine(nil, gold(73)), nil)
  eq(P.FundLine(0, gold(73)), nil)
  eq(P.FundLine(12 * GOLD, {}), nil, "no GetMoney")
  eq(P.FundLine(12 * GOLD, { GetMoney = function() error("x") end }), nil)
end)

test("fund line: none with no active milestone, or when the profile fails", function()
  eq(fresh({ current = nil, state = "finished" }).ConfirmPopup.FundLine(12 * GOLD, gold(73)), nil, "finished")
  eq(fresh(nil).ConfirmPopup.FundLine(12 * GOLD, gold(73)), nil, "no milestone")
  local ns = fresh(active40)
  ns.Context.Profile = function() error("boom") end
  eq(ns.ConfirmPopup.FundLine(12 * GOLD, gold(73)), nil)
end)

test("the question shows the fund line after the earn-back line and before Buy anyway?", function()
  local ns = fresh(active40)
  local shown
  ns.ConfirmPopup.Show = function(text) shown = text; return true end
  ns.EarnBack = { Line = function() return "EARN" end }
  local saved = _G.GetMoney
  _G.GetMoney = function() return 73 * GOLD end
  ns.ConfirmPopup.Ask({ cost = 12 * GOLD, reason = "why" })
  _G.GetMoney = saved
  local earn, fund, buy = shown:find("EARN", 1, true), shown:find("After this you'll have 61g", 1, true), shown:find("Buy anyway?", 1, true)
  truthy(earn and fund and buy and earn < fund and fund < buy, shown)
end)

test("the question still shows when the fund line fails", function()
  local ns = fresh(active40)
  local shown
  ns.ConfirmPopup.Show = function(text) shown = text; return true end
  ns.Milestones.Target = function() error("boom") end
  ns.ConfirmPopup.Ask({ cost = 12 * GOLD, reason = "why" })
  truthy(shown and shown:find("Buy anyway?", 1, true) and not shown:find("After this", 1, true), shown)
end)

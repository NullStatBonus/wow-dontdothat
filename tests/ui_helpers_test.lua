local H = require("harness")

local function fresh()
  local ns = {}
  H.load("DontDoThat/UI/Helpers.lua", ns)
  H.load("DontDoThat/UI/TooltipAugment.lua", ns)
  H.load("DontDoThat/UI/ConfirmPopup.lua", ns)
  return ns
end

test("FormatMoney", function()
  local f = fresh().UIHelpers.FormatMoney
  eq(f(0), "0c")
  eq(f(5), "5c")
  eq(f(100), "1s")
  eq(f(10000), "1g")
  eq(f(123456), "12g 34s 56c")
  eq(f(10005), "1g 5c")
  eq(f(nil), nil)
  eq(f(-1), nil)
end)

test("TierStyle", function()
  local t = fresh().UIHelpers.TierStyle
  eq(t("defer").label, "Save your gold")
  eq(#t("deferLow").color, 3)
  eq(t("bogus"), nil)
end)

test("TooltipText", function()
  local T = fresh().UIHelpers.TooltipText
  eq(T({ tier = "defer", reason = "Wait for rank 2", cost = 20000 }), "Save your gold\nWait for rank 2\nCosts 2g")
  eq(T({ tier = "deferLow", reason = "r", cost = 150, costIsEstimate = true }), "Not worth buying yet\nr\nCosts about 1s 50c")
  eq(T({ tier = "info", reason = "r" }), "Optional\nr")
  eq(T({ tier = "defer", reason = "r" }), "Save your gold\nr")
  eq(T({ tier = "keep", reason = "r" }), nil)
  eq(T(nil), nil)
end)

test("BannerText", function()
  local a, b = fresh().UIHelpers.BannerText({ cost = 10000, reason = "why" }, "Serpent Sting")
  eq(a, "Serpent Sting costs 1g."); eq(b, "why")
  a = fresh().UIHelpers.BannerText({ cost = 150, costIsEstimate = true, reason = "why" }, "X")
  eq(a, "X costs about 1s 50c.")
end)

test("TooltipAugment adds a line, tolerates bad tooltips", function()
  local ns = fresh()
  local lines = {}
  local tip = { AddLine = function(_, t) lines[#lines + 1] = t end, Show = function() end }
  truthy(ns.TooltipAugment.Augment(tip, { tier = "defer", reason = "r", cost = 100 }))
  eq(lines[1], "Save your gold\nr\nCosts 1s")
  falsy(ns.TooltipAugment.Augment(tip, { tier = "keep" }))
  falsy(ns.TooltipAugment.Augment(nil, { tier = "defer", reason = "r" }))
  falsy(ns.TooltipAugment.Augment({ AddLine = function() error("x") end }, { tier = "defer", reason = "r" }))
end)

test("ConfirmPopup: confirm proceeds, cancel calls onCancel, unavailable returns false", function()
  local ns = fresh()
  falsy(ns.ConfirmPopup.Ask({ reason = "r" }, function() end, function() end))
  _G.StaticPopupDialogs = {}
  _G.StaticPopup_Show = function() return true end
  local log = {}
  local v = { cost = 100, reason = "r" }
  truthy(ns.ConfirmPopup.Ask(v, function() log[#log + 1] = "yes" end, function() log[#log + 1] = "no" end))
  _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnAccept()
  _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnCancel() -- stray second call is ignored
  eq(log, { "yes" })
  log = {}
  ns.ConfirmPopup.Ask(v, function() log[#log + 1] = "yes" end, function() log[#log + 1] = "no" end)
  _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnCancel()
  eq(log, { "no" })
  -- a new Ask cancels an unanswered one
  log = {}
  ns.ConfirmPopup.Ask(v, nil, function() log[#log + 1] = "old" end)
  ns.ConfirmPopup.Ask(v, nil, nil)
  eq(log, { "old" })
  _G.StaticPopupDialogs, _G.StaticPopup_Show = nil, nil
end)

local H = require("harness")
local F = require("fakeframes")

local function fresh(profile)
  local restore = F.install()
  local savedTip = _G.GameTooltip
  _G.GameTooltip = setmetatable({}, { __index = function() return function() end end })
  local ns = {}
  H.load("DontDoThat/UI/Helpers.lua", ns)
  H.load("DontDoThat/UI/Style.lua", ns)
  H.load("DontDoThat/UI/InfoBubble.lua", ns)
  if profile then ns.db = { profile = profile } end
  return ns, function() restore(); _G.GameTooltip = savedTip end
end

local VERDICT = { tier = "deferLow", cost = 500, reason = ("A long revision-specific reason. "):rep(12) }

local function inEscape(name)
  for _, n in ipairs(_G.UISpecialFrames) do if n == name then return true end end
  return false
end

test("explanation: click pins a black surface sized to its text; the same indicator toggles it off", function()
  local ns, restore = fresh()
  local b = ns.InfoBubble.Create(_G.UIParent, VERDICT)
  b.scripts.OnClick(b)
  local pin = F.DontDoThatExplanation
  truthy(pin:IsShown())
  eq(pin.bg.color, { 0, 0, 0, 1 })
  truthy(pin.text.text:find("Not worth buying yet", 1, true))
  truthy(pin.height >= pin.text:GetStringHeight() + 24, "grows for long text")
  truthy(pin.clamped)
  truthy(inEscape("DontDoThatExplanation"), "Escape closes it")
  b.scripts.OnClick(b)
  falsy(pin:IsShown())
  restore()
end)

test("tooltip: the minimum width set on hover is reset on leave and when hidden", function()
  local ns, restore = fresh()
  local widths, owner = {}, nil
  _G.GameTooltip = { SetOwner = function(_, o) owner = o end, SetText = function() end, AddLine = function() end, Show = function() end,
    Hide = function() end, GetOwner = function() return owner end, SetMinimumWidth = function(_, w) widths[#widths + 1] = w end }
  local b = ns.InfoBubble.Create(_G.UIParent, VERDICT)
  b.scripts.OnEnter(b)
  eq(widths, { 230 })
  b.scripts.OnLeave(b)
  eq(widths, { 230, 0 }, "reset on leave")
  b.scripts.OnEnter(b)
  b.scripts.OnHide(b)
  eq(widths, { 230, 0, 230, 0 }, "reset when hidden while hovered")
  restore()
end)

test("explanation: own background and text alpha and scale; alpha 0 draws no background", function()
  local profile = { explanation = { bgAlpha = 0, textAlpha = 60, scale = 150 } }
  local ns, restore = fresh(profile)
  local b = ns.InfoBubble.Create(_G.UIParent, VERDICT)
  b.scripts.OnClick(b)
  local pin = F.DontDoThatExplanation
  falsy(pin.bg:IsShown()); eq(pin.text.alpha, 0.6); eq(pin.scale, 1.5)
  eq(pin.close.alpha, 1, "native close stays usable")
  profile.explanation.bgAlpha = 100
  ns.InfoBubble.RefreshAppearance()
  truthy(pin.bg:IsShown()); eq(pin.bg.alpha, 1)
  restore()
end)

test("explanation: samples pin the same way; DismissSample never dismisses a real one", function()
  local ns, restore = fresh()
  truthy(ns.InfoBubble.ShowSample(VERDICT))
  local pin = F.DontDoThatExplanation
  truthy(pin:IsShown()); truthy(ns.InfoBubble.IsSampleShown())
  truthy(ns.InfoBubble.DismissSample()); falsy(pin:IsShown())
  ns.InfoBubble.ShowSample(VERDICT)
  local b = ns.InfoBubble.Create(_G.UIParent, VERDICT)
  b.scripts.OnClick(b) -- a real pin replaces the sample
  falsy(ns.InfoBubble.DismissSample()); truthy(pin:IsShown())
  restore()
end)

test("explanation: a sample never replaces a real pinned explanation", function()
  local ns, restore = fresh()
  local b = ns.InfoBubble.Create(_G.UIParent, VERDICT)
  b.scripts.OnClick(b)
  local pin = F.DontDoThatExplanation
  local text = pin.text.text
  falsy(ns.InfoBubble.ShowSample(VERDICT, _G.UIParent, "Sample: Frostbolt"))
  eq(pin.text.text, text); truthy(pin:IsShown())
  falsy(ns.InfoBubble.DismissSample()); truthy(pin:IsShown())
  restore()
end)

test("explanation: close button dismisses", function()
  local ns, restore = fresh()
  ns.InfoBubble.ShowSample(VERDICT, _G.UIParent)
  F.DontDoThatExplanation.close.scripts.OnClick()
  falsy(F.DontDoThatExplanation:IsShown())
  falsy(ns.InfoBubble.IsSampleShown())
  restore()
end)

test("explanation: a sample is labelled and leaves Escape to the settings window; a real pin takes Escape back", function()
  local ns, restore = fresh()
  truthy(ns.InfoBubble.ShowSample(VERDICT, _G.UIParent, "Sample: Frostbolt"))
  local pin = F.DontDoThatExplanation
  truthy(pin.text.text:find("^Sample: Frostbolt\n\n"))
  truthy(pin.text.text:find("Not worth buying yet", 1, true))
  falsy(inEscape("DontDoThatExplanation"))
  local b = ns.InfoBubble.Create(_G.UIParent, VERDICT)
  b.scripts.OnClick(b)
  falsy(pin.text.text:find("Sample", 1, true))
  truthy(inEscape("DontDoThatExplanation"))
  restore()
end)

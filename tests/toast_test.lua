local H = require("harness")
local F = require("fakeframes")

local function fresh(profile)
  local restore = F.install()
  local ns = {}
  H.load("DontDoThat/UI/Helpers.lua", ns)
  H.load("DontDoThat/UI/Style.lua", ns)
  H.load("DontDoThat/UI/Toast.lua", ns)
  if profile then ns.db = { profile = profile } end
  return ns, restore
end

local VERDICT = { tier = "defer", cost = 12345, costIsEstimate = true, reason = "Rank 3 is barely better than rank 2." }

local function inEscape(name)
  for _, n in ipairs(_G.UISpecialFrames) do if n == name then return true end end
  return false
end

test("toast: shows the recommendation in words, a neutral title with the estimate marker and the reason", function()
  local ns, restore = fresh()
  truthy(ns.Toast.Show(VERDICT, "Frostbolt"))
  local f = F.DontDoThatToast
  truthy(f:IsShown())
  eq(f.recommendation.text, "Save your gold")
  eq(f.title.text, "Frostbolt costs about 1g 23s 45c.")
  eq(f.detail.text, VERDICT.reason)
  eq(f.title.textColor, ns.UIHelpers.INK.primary)
  falsy(f.mouse, "mouse-transparent outside Move")
  truthy(f.clamped)
  restore()
end)

test("toast: no cost and no tier invent nothing; height grows with long text", function()
  local ns, restore = fresh()
  ns.Toast.Show({ reason = "short" }, "Thing")
  local f = F.DontDoThatToast
  eq(f.title.text, "Thing")
  falsy(f.recommendation:IsShown())
  local short = f.height
  ns.Toast.Show({ tier = "defer", reason = ("long reason "):rep(40) }, "Thing")
  truthy(f.height > short, "height follows the text")
  restore()
end)

test("toast: background alpha 0 hides fill and accent; text alpha is separate; scale applies", function()
  local profile = { toast = { bgAlpha = 0, textAlpha = 40, scale = 150 } }
  local ns, restore = fresh(profile)
  ns.Toast.Show(VERDICT, "X")
  local f = F.DontDoThatToast
  falsy(f.bg:IsShown()); falsy(f.edge:IsShown())
  eq(f.title.alpha, 0.4); eq(f.detail.alpha, 0.4); eq(f.recommendation.alpha, 0.4)
  eq(f.scale, 1.5)
  eq(f.alpha, 1, "frame alpha belongs to the fade")
  profile.toast.bgAlpha = 80
  ns.Toast.Refresh()
  truthy(f.bg:IsShown()); eq(f.bg.alpha, 0.8); eq(f.title.alpha, 0.4)
  restore()
end)

test("toast: missing or invalid settings fall back to 100 percent", function()
  local ns, restore = fresh({ toast = { bgAlpha = "x", scale = 999 } })
  ns.Toast.Show(VERDICT, "X")
  local f = F.DontDoThatToast
  eq(f.scale, 1); eq(f.bg.alpha, 1); eq(f.title.alpha, 1)
  restore()
end)

test("toast: Move raises the placeholder above settings, Done saves only the point", function()
  local profile = { toast = { bgAlpha = 0, textAlpha = 0, scale = 120 } }
  local ns, restore = fresh(profile)
  truthy(ns.Toast.StartMove())
  local f = F.DontDoThatToast
  truthy(ns.Toast.IsMoving())
  eq(f.strata, "TOOLTIP"); truthy(f.mouse); truthy(f:IsShown()); truthy(f.controls:IsShown())
  truthy(f.bg:IsShown(), "placeholder visible even at zero alpha"); eq(f.title.alpha, 1)
  falsy(inEscape("DontDoThatToast"), "no UISpecialFrames entry: that Escape would close settings too")
  truthy(f.keyboard); eq(f.propagate, true)
  f:ClearAllPoints(); f:SetPoint("CENTER", _G.UIParent, "CENTER", 40, -20) -- the drag, in the frame's 1.2 scale
  F.button("Done").scripts.OnClick()
  falsy(ns.Toast.IsMoving())
  eq(profile.toast.point, { point = "CENTER", relPoint = "CENTER", x = 48, y = -24 }, "saved in UIParent units")
  eq(f.strata, "HIGH"); falsy(f.mouse); falsy(f:IsShown()); falsy(f.controls:IsShown())
  falsy(f.keyboard, "keyboard released"); eq(f.scripts.OnKeyDown, nil)
  truthy(inEscape("GameMenuFrame"))
  eq(f.userPlaced, false)
  eq(profile.toast.bgAlpha, 0); eq(profile.toast.textAlpha, 0); eq(profile.toast.scale, 120)
  restore()
end)

test("toast: Cancel and Escape roll back without saving", function()
  local profile = { toast = { point = { point = "TOP", relPoint = "TOP", x = 5, y = -50 } } }
  local ns, restore = fresh(profile)
  local f
  for _, finishWith in ipairs({ "cancel", "escape" }) do
    ns.Toast.StartMove()
    f = F.DontDoThatToast
    f:ClearAllPoints(); f:SetPoint("CENTER", _G.UIParent, "CENTER", 99, 99)
    if finishWith == "cancel" then F.button("Cancel").scripts.OnClick() else f.scripts.OnKeyDown(f, "ESCAPE") end
    falsy(ns.Toast.IsMoving(), finishWith)
    eq(profile.toast.point, { point = "TOP", relPoint = "TOP", x = 5, y = -50 }, finishWith)
    eq(f.points[1][1], "TOP"); eq(f.points[1][4], 5)
    eq(f.strata, "HIGH")
    if finishWith == "escape" then eq(f.propagate, false, "Escape stops at the placeholder") end
    falsy(f.keyboard)
  end
  restore()
end)

test("toast: during Move other keys pass on to the game; hiding the placeholder still cancels", function()
  local ns, restore = fresh({ toast = {} })
  ns.Toast.StartMove()
  local f = F.DontDoThatToast
  f.scripts.OnKeyDown(f, "W")
  truthy(ns.Toast.IsMoving()); eq(f.propagate, true)
  f:Hide()
  falsy(ns.Toast.IsMoving()); falsy(f.keyboard)
  restore()
end)

test("toast: Move does not start in combat", function()
  local saved = _G.InCombatLockdown
  _G.InCombatLockdown = function() return true end
  local ns, restore = fresh({ toast = {} })
  falsy(ns.Toast.StartMove())
  falsy(ns.Toast.IsMoving())
  _G.InCombatLockdown = saved
  restore()
end)

test("toast: entering combat during Move puts the toast back", function()
  local profile = { toast = {} }
  local ns, restore = fresh(profile)
  truthy(ns.Toast.StartMove())
  local f = F.DontDoThatToast
  f:ClearAllPoints(); f:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 10, -10)
  f.scripts.OnEvent(f, "PLAYER_REGEN_DISABLED")
  falsy(ns.Toast.IsMoving()); eq(profile.toast.point, nil); falsy(f.keyboard)
  restore()
end)

test("toast: a position saved at one scale stays put at another", function()
  local profile = { toast = { scale = 100 } }
  local ns, restore = fresh(profile)
  ns.Toast.StartMove()
  local f = F.DontDoThatToast
  f:ClearAllPoints(); f:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 300, -90)
  ns.Toast.FinishMove()
  eq(profile.toast.point, { point = "TOPLEFT", relPoint = "TOPLEFT", x = 300, y = -90 })
  profile.toast.scale = 150
  ns.Toast.Refresh()
  eq(f.scale, 1.5)
  eq(f.points[1], { "TOPLEFT", _G.UIParent, "TOPLEFT", 300 / 1.5, -90 / 1.5 })
  -- The default anchor does not drift with scale either.
  ns.Toast.ResetPosition()
  eq(f.points[1], { "TOP", _G.UIParent, "TOP", 0, -160 / 1.5 })
  restore()
end)

test("toast: a profile change during Move cancels without writing to either profile", function()
  local a, b = { toast = {} }, { toast = {} }
  local ns, restore = fresh(a)
  local handlers = {}
  ns.db.RegisterCallback = function(target, event, fn) handlers[event] = fn end
  ns.db.UnregisterCallback = function(target, event) handlers[event] = nil end
  ns.Toast.StartMove()
  truthy(handlers.OnProfileChanged and handlers.OnProfileReset and handlers.OnProfileCopied)
  local f = F.DontDoThatToast
  f:ClearAllPoints(); f:SetPoint("CENTER", _G.UIParent, "CENTER", 1, 2)
  ns.db.profile = b
  handlers.OnProfileChanged()
  falsy(ns.Toast.IsMoving())
  eq(a.toast.point, nil); eq(b.toast.point, nil)
  eq(next(handlers), nil, "callbacks only during Move")
  -- Without the callback, Done still refuses to write into a different profile.
  ns.db.RegisterCallback, ns.db.UnregisterCallback = nil, nil
  ns.db.profile = a
  ns.Toast.StartMove()
  ns.db.profile = b
  ns.Toast.FinishMove()
  eq(a.toast.point, nil); eq(b.toast.point, nil)
  restore()
end)

test("toast: Reset position clears only the point", function()
  local profile = { toast = { bgAlpha = 30, textAlpha = 70, scale = 80, point = { point = "LEFT", x = 1, y = 2 } },
    alert = { style = "toast" } }
  local ns, restore = fresh(profile)
  ns.Toast.Show(VERDICT, "X")
  ns.Toast.ResetPosition()
  eq(profile.toast, { bgAlpha = 30, textAlpha = 70, scale = 80 })
  eq(profile.alert, { style = "toast" })
  eq(F.DontDoThatToast.points[1], { "TOP", _G.UIParent, "TOP", 0, -160 / 0.8 })
  restore()
end)

test("toast: samples draw the same way; HideSample never hides a real warning", function()
  local ns, restore = fresh()
  truthy(ns.Toast.ShowSample(VERDICT, "Sample"))
  local f = F.DontDoThatToast
  eq(f.recommendation.text, "Save your gold")
  eq(f.strata, "TOOLTIP", "a sample draws above the settings window")
  truthy(ns.Toast.HideSample()); falsy(f:IsShown())
  ns.Toast.ShowSample(VERDICT, "Sample")
  ns.Toast.Show(VERDICT, "Real") -- a real warning replaces the sample
  falsy(ns.Toast.HideSample()); truthy(f:IsShown())
  eq(f.strata, "HIGH", "a real warning keeps the normal strata")
  eq(f.title.text, "Real costs about 1g 23s 45c.")
  restore()
end)

test("toast: a warning during Move ends Move and shows; the fade then hides it", function()
  local ns, restore = fresh({ toast = {} })
  ns.Toast.StartMove()
  ns.Toast.Show(VERDICT, "Real")
  local f = F.DontDoThatToast
  falsy(ns.Toast.IsMoving()); truthy(f:IsShown()); eq(f.strata, "HIGH")
  f.group:Finish()
  falsy(f:IsShown())
  restore()
end)

test("toast: works with no profile loaded", function()
  local ns, restore = fresh()
  truthy(ns.Toast.StartMove())
  ns.Toast.FinishMove() -- nothing to save into; ends cleanly
  falsy(ns.Toast.IsMoving())
  ns.Toast.ResetPosition()
  ns.Toast.Refresh()
  restore()
end)

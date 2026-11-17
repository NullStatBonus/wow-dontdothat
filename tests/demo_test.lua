local H = require("harness")

local saved = {}
local function stub(k, v) if saved[k] == nil then saved[k] = { _G[k] } end _G[k] = v end
local function restore() for k, v in pairs(saved) do _G[k] = v[1] end saved = {} end

-- A fake game: popups, a manual timer queue, chat, frames.
local function fresh(profile)
  local env = { popups = {}, hidden = {}, chat = {}, timers = {}, sounds = {} }
  stub("StaticPopupDialogs", {})
  stub("StaticPopup_Show", function(which, text, _, data) env.popups[#env.popups + 1] = { which = which, text = text, data = data } return {} end)
  stub("StaticPopup_Hide", function(which) env.hidden[#env.hidden + 1] = which end)
  stub("C_Timer", { After = function(d, fn) env.timers[#env.timers + 1] = { d = d, fn = fn } end })
  stub("DEFAULT_CHAT_FRAME", { AddMessage = function(_, m) env.chat[#env.chat + 1] = m end })
  stub("UnitLevel", function() return 30 end)
  local ns = { db = { profile = profile or { alerts = true, alert = { style = "toast", sound = "x", cooldown = 3, channel = "SFX" } } } }
  for _, f in ipairs({ "Data/Sounds", "Data/GoldRates", "UI/Helpers", "Model/EarnBack", "UI/Alert", "UI/ConfirmPopup", "Intercepts/Prompt", "UI/Demo" }) do
    H.load("DontDoThat/" .. f .. ".lua", ns)
  end
  env.toast, env.banner = {}, {}
  ns.Toast = { Show = function(v, n) env.toast[#env.toast + 1] = { v = v, n = n } end }
  ns.AlertBanner = { Show = function(v, n) env.banner[#env.banner + 1] = { v = v, n = n } end }
  ns.Alert.PlaySound = function(key, s) env.sounds[#env.sounds + 1] = { key = key, s = s } end
  env.ns = ns
  function env.run(maxDelay)
    local t = env.timers; env.timers = {}
    for _, x in ipairs(t) do if not maxDelay or x.d <= maxDelay then x.fn() end end
  end
  return ns, env
end

local function finish() restore() end

test("demo: one fixed set, labelled, with accurate reasons and an estimated price", function()
  local ns, env = fresh()
  truthy(ns.Demo.Run())
  env.run()
  eq(#env.toast, 4)
  local tiers = {}
  for _, t in ipairs(env.toast) do tiers[#tiers + 1] = t.v.tier; truthy(t.n:find("^Sample: ")) end
  eq(tiers, { "info", "deferLow", "defer", "defer" })
  eq(#env.popups, 1)
  eq(env.popups[1].which, "DONTDOTHAT_SAMPLE")
  truthy(env.popups[1].text:find("about", 1, true), "estimated price")
  truthy(env.popups[1].text:find("grinding", 1, true), "earn-back line")
  local a, b = ns.Demo.Samples(), ns.Demo.Samples()
  eq(a, b)
  finish()
end)

test("demo: plays the configured sound once and changes no setting", function()
  local ns, env = fresh()
  local before = { alerts = ns.db.profile.alerts, style = ns.db.profile.alert.style, channel = ns.db.profile.alert.channel }
  ns.Demo.Run(); env.run()
  eq(#env.sounds, 1); eq(env.sounds[1].key, "x"); eq(env.sounds[1].s.alertChannel, "SFX")
  eq(ns.db.profile.alerts, before.alerts); eq(ns.db.profile.alert.style, before.style); eq(ns.db.profile.alert.channel, before.channel)
  finish()
end)

test("demo: shows even when real alerts and messages are disabled", function()
  local ns, env = fresh({ alerts = false, alert = { banner = false, chat = false, style = "warning" } })
  ns.Demo.Run(); env.run()
  eq(#env.banner, 4); eq(#env.popups, 1)
  eq(ns.db.profile.alerts, false)
  finish()
end)

test("demo: touches no cooldown, ledger, once-only flag, and prints no chat record", function()
  local ns, env = fresh()
  ns.db.profile.professionAsked = { x = true }
  ns.Ledger = setmetatable({}, { __newindex = function() error("ledger written") end })
  ns.Demo.Run(); env.run(); ns.Demo.Preview("prompt"); ns.Demo.End()
  eq(ns.Alert.state, { last = {} })
  eq(ns.db.profile.professionAsked, { x = true })
  eq(#env.chat, 0)
  finish()
end)

test("demo: the sample question is its own dialog and does nothing when answered", function()
  local ns, env = fresh()
  ns.Demo.Run()
  local d = _G.StaticPopupDialogs.DONTDOTHAT_SAMPLE
  truthy(d); falsy(_G.StaticPopupDialogs.DONTDOTHAT_CONFIRM)
  eq(d.OnAccept(nil, env.popups[1].data), nil); eq(d.OnCancel(nil, env.popups[1].data), nil)
  finish()
end)

test("demo: a real question ends the samples and old timers can not touch it", function()
  local ns, env = fresh()
  ns.Demo.Run()
  local before = ns.Demo.Generation()
  local confirmed, cancelled = 0, 0
  truthy(ns.ConfirmPopup.Show("real?", function() confirmed = confirmed + 1 end, function() cancelled = cancelled + 1 end))
  truthy(ns.Demo.Generation() > before); falsy(ns.Demo.Active())
  eq(env.hidden, { "DONTDOTHAT_SAMPLE" })
  local hiddenBefore = #env.hidden
  local toastsBefore = #env.toast
  env.run() -- every old timer, including the ten-second end
  eq(#env.hidden, hiddenBefore, "old timeout hid nothing")
  eq(#env.toast, toastsBefore, "old steps drew nothing")
  eq(env.popups[#env.popups].which, "DONTDOTHAT_CONFIRM")
  local data = env.popups[#env.popups].data
  _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnAccept(nil, data)
  eq(confirmed, 1); eq(cancelled, 0)
  finish()
end)

test("demo: a real alert replaces the samples and still fires its own sound", function()
  local ns, env = fresh()
  ns.Demo.Run(); env.run(0)
  eq(#env.toast, 1)
  local real = { tier = "defer", name = "Real", cost = 100, reason = "r" }
  ns.Alert.PlaySound = function(key) env.sounds[#env.sounds + 1] = { key = "real" } end
  truthy(ns.Alert.Trigger(real, "spell:9", { alertsEnabled = true, alertChat = false }, 100))
  falsy(ns.Demo.Active())
  eq(ns.Alert.state.last["spell:9"], 100)
  local n = #env.toast
  env.run()
  eq(#env.toast, n, "the sample steps are inert")
  eq(env.toast[#env.toast].v.name, "Real")
  finish()
end)

test("demo: a new run makes the old timers inert", function()
  local ns, env = fresh()
  ns.Demo.Run()
  local old = env.timers; env.timers = {}
  ns.Demo.Run()
  local toasts, popups = #env.toast, #env.popups
  for _, x in ipairs(old) do x.fn() end
  eq(#env.toast, toasts); eq(#env.popups, popups)
  eq(popups, 2)
  finish()
end)

test("preview: lists kinds for nil or unknown without side effects", function()
  local ns, env = fresh()
  falsy(ns.Demo.Preview()); falsy(ns.Demo.Preview("bogus"))
  eq(#env.chat, 2); truthy(env.chat[1]:find("toast, warning, mark, tooltip, explanation, prompt", 1, true))
  eq(#env.sounds, 0); eq(#env.toast, 0); eq(#env.popups, 0); eq(ns.Demo.Generation(), 0)
  finish()
end)

test("preview: warning shows the banner while Toast stays saved, with one sound and no saves", function()
  local ns, env = fresh()
  truthy(ns.Demo.Preview("warning"))
  eq(#env.banner, 1); eq(#env.toast, 0); eq(#env.sounds, 1)
  eq(ns.db.profile.alert.style, "toast")
  eq(ns.Alert.state, { last = {} })
  truthy(ns.Demo.Preview("toast"))
  eq(#env.toast, 1); eq(ns.db.profile.alert.style, "toast")
  finish()
end)

test("preview: prompt is inert and expires with its generation", function()
  local ns, env = fresh()
  truthy(ns.Demo.Preview("prompt"))
  eq(env.popups[1].which, "DONTDOTHAT_SAMPLE")
  env.run()
  eq(env.hidden, { "DONTDOTHAT_SAMPLE" })
  falsy(ns.Demo.Active())
  finish()
end)

test("preview: prefers the sample hooks of the toast when present", function()
  local ns, env = fresh()
  local got
  ns.Toast.ShowSample = function(v, n) got = n end
  ns.Demo.Preview("toast")
  truthy(got and got:find("^Sample: "))
  eq(#env.toast, 0)
  finish()
end)

test("demo: a trainer click that warns about nothing leaves the samples running", function()
  local ns, env = fresh()
  ns.Demo.Run()
  local s = { alertsEnabled = true, alertChat = false }
  falsy(ns.Alert.Trigger({ tier = "keep", name = "Fine" }, "spell:1", s, 100))
  truthy(ns.Demo.Active(), "keep tier fires nothing")
  falsy(ns.Alert.Trigger({ tier = "deferLow", name = "Low" }, "spell:2", { alertTiers = { defer = true } }, 100))
  truthy(ns.Demo.Active(), "a tier the player did not choose fires nothing")
  ns.Alert.state.last["spell:3"] = 99
  falsy(ns.Alert.Trigger({ tier = "defer", name = "Again" }, "spell:3", s, 100))
  truthy(ns.Demo.Active(), "cooldown-suppressed")
  truthy(ns.Alert.Trigger({ tier = "defer", name = "Real" }, "spell:4", s, 100))
  falsy(ns.Demo.Active(), "a firing alert ends the samples")
  finish()
end)

test("demo: a firing alert with only its chat line still ends the samples", function()
  local ns, env = fresh()
  ns.Demo.Run()
  falsy(ns.Alert.Trigger({ tier = "defer", name = "Real" }, "spell:5", { alertsEnabled = false }, 100))
  falsy(ns.Demo.Active())
  eq(#env.chat, 1)
  finish()
end)

test("preview: the explanation sample is labelled", function()
  local ns, env = fresh()
  local F = require("fakeframes")
  local undo = F.install()
  local got
  ns.InfoBubble = { ShowSample = function(v, anchor, label) got = label end }
  truthy(ns.Demo.Preview("explanation"))
  eq(got, "Sample: Frost Nova (Rank 2)")
  undo()
  finish()
end)

test("preview: the marks carry one Sample caption, hidden when the samples end", function()
  local ns, env = fresh()
  local F = require("fakeframes")
  local undo = F.install()
  H.load("DontDoThat/UI/Style.lua", ns)
  local attached = 0
  ns.Badge = { Attach = function() attached = attached + 1 end }
  truthy(ns.Demo.Preview("mark"))
  eq(attached, 3)
  local captions = {}
  for _, s in ipairs(F.created) do if s.kind == "FontString" and s.text == "Sample" then captions[#captions + 1] = s end end
  eq(#captions, 1)
  truthy(captions[1]:IsShown())
  ns.Demo.Preview("mark") -- again: still one caption
  local n = 0
  for _, s in ipairs(F.created) do if s.kind == "FontString" and s.text == "Sample" then n = n + 1 end end
  eq(n, 1)
  ns.Demo.End()
  falsy(captions[1]:IsShown())
  undo()
  finish()
end)

test("demo: the tour also shows the marks and their hover tooltip", function()
  local ns, env = fresh()
  local F = require("fakeframes")
  local undo = F.install()
  H.load("DontDoThat/UI/Style.lua", ns)
  local attached, augmented = 0, 0
  ns.Badge = { Attach = function() attached = attached + 1 end }
  ns.TooltipAugment = { Augment = function() augmented = augmented + 1 end }
  stub("GameTooltip", { SetOwner = function() end, SetText = function() end, Show = function() end,
    Hide = function() end, GetOwner = function() end })
  truthy(ns.Demo.Run())
  eq(attached, 3); eq(augmented, 1)
  ns.Demo.End()
  undo()
  finish()
end)

-- The samples are true to the addon's own data: prices from TrainerPrices, the skipped ranks in SkipRevisions, and
-- the tier and reason the rule engine gives for that spell.
test("demo: every sample matches the price list, the skip list and the rule engine", function()
  local ns = { L = setmetatable({}, { __index = function(_, k) return k end }) }
  H.loadSpellTables(ns)
  H.load("DontDoThat/Data/TrainerPrices.lua", ns)
  H.load("DontDoThat/Rules/Schema.lua", ns)
  H.load("DontDoThat/Rules/Engine.lua", ns)
  H.load("DontDoThat/Rules/Data/Mage.lua", ns)
  H.load("DontDoThat/UI/Demo.lua", ns)
  local set = ns.Demo.Samples()
  local specs = { deferLow = { "ARCANE" } }
  for key, v in pairs(set) do
    eq(v.cost, ns.TrainerPrices.MAGE[v.spellId], key .. " cost")
    local fam = ns.SpellData.FamilyOfId("MAGE", v.spellId)
    truthy(fam, key .. " is a real Mage spell")
    local row
    for _, r in ipairs(ns.SpellData.Rows("MAGE")) do if r.id == v.spellId then row = r end end
    local rank = row.rank
    eq(v.name, rank and (row.name .. " (Rank " .. rank .. ")") or row.name, key .. " name")
    local profile = { class = "MAGE", level = 30, plausibleSpecs = specs[key] or {}, milestone = { current = 40, state = "active" },
      rules = { skipRevision = ns.Rules.NewestRevision() } }
    local got = ns.Rules.Evaluate(profile, { kind = "spell", name = row.name, familyId = fam, rank = rank, cost = v.cost })
    eq(got.tier, v.tier, key .. " tier"); eq(got.source, v.source, key .. " source"); eq(got.reason, v.reason, key .. " reason")
  end
  for _, key in ipairs({ "skip", "estimate" }) do
    local v = set[key]
    local row = (function() for _, r in ipairs(ns.SpellData.Rows("MAGE")) do if r.id == v.spellId then return r end end end)()
    local entries = ns.Rules.SkipEntries(ns.Rules.GetClass("MAGE"), ns.Rules.NewestRevision(), ns.SpellData.FamilyOfId("MAGE", v.spellId), row.rank)
    truthy(#entries > 0, key .. " is in SkipRevisions")
  end
  truthy(set.estimate.costIsEstimate)
end)

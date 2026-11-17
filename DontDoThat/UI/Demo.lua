local addonName, ns = ...
local L = ns.L

-- /ddt demo and /ddt preview: synthetic samples drawn through the production helpers. Nothing here buys, trains,
-- resets, mails or auctions, writes a setting, or touches the cooldowns, the ledger or the once-only flags.
--
-- Every run or preview takes a new generation. A timer that was scheduled under an older generation does nothing,
-- and a real alert or question (see Interrupt) ends the samples and bumps the generation too, so an old timeout can
-- never hide a real prompt or reach its callbacks. The sample question is its own dialog, never the real one.
local Demo = {}
ns.Demo = Demo

local SAMPLE_DIALOG = "DONTDOTHAT_SAMPLE"
local STEP, LIFETIME = 2, 10 -- seconds between tour samples; every sample is gone by LIFETIME
local KINDS = { "toast", "warning", "mark", "tooltip", "explanation", "prompt" }
Demo.Kinds = KINDS

local generation = 0
local active = false
local host -- one invisible anchor frame for the marks, tooltip and pinned explanation samples
local wrapped = {}

-- The fixed tour set: the same five samples every run. Each is a real Mage spell whose tier, reason and price match
-- what the rule engine and Data/TrainerPrices.lua say (tests/demo_test.lua checks them), shown as it would read for
-- a level 20 to 40 Mage. Names are spell names, so they stay as the game spells them. The deferLow sample reads as
-- seen by an Arcane Mage; the others hold for every spec. Prices from the trainer list are estimates until seen.
local function samples()
  return {
    info = { tier = "info", name = "Slow Fall", spellId = 130, cost = 600, source = "rotation",
      reason = L["Handy now and then, but you can get by without it."] },
    deferLow = { tier = "deferLow", name = "Frostbolt (Rank 4)", spellId = 7322, cost = 2000, source = "rotation",
      reason = (L["Mostly used by %s players, and your talents lean another way."]):format("Frost") },
    defer = { tier = "defer", name = "Portal: Stormwind", spellId = 10059, cost = 15000, source = "tag",
      reason = L["Takes a group somewhere and needs a Rune of Portals."] },
    skip = { tier = "defer", name = "Frost Nova (Rank 2)", spellId = 865, cost = 5000, source = "skipRank",
      reason = L["The leveling guide says to buy only the first rank of this spell."] },
    estimate = { tier = "defer", name = "Frost Nova (Rank 3)", spellId = 6131, cost = 15000, costIsEstimate = true,
      source = "skipRank", reason = L["The leveling guide says to buy only the first rank of this spell."] },
  }
end
Demo.Samples = samples

local function labelled(verdict) return L["Sample: %s"]:format(verdict.name) end

local function after(delay, gen, fn)
  if delay <= 0 or not (_G.C_Timer and _G.C_Timer.After) then
    if gen == generation then fn() end
    return
  end
  _G.C_Timer.After(delay, function()
    if gen == generation then pcall(fn) end -- an older generation's timer is inert
  end)
end

local function getHost()
  if host then return host end
  local ok, f = pcall(function()
    local h = CreateFrame("Frame", nil, UIParent)
    h:SetSize(10, 10)
    h:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    h:Hide()
    return h
  end)
  host = ok and f or nil
  return host
end

-- Ends whatever samples are on screen. Only sample surfaces are touched: the sample dialog, the sample anchor, and
-- the sample hooks of the notice and the pinned reason when those modules have them.
local function cleanup()
  if type(_G.StaticPopup_Hide) == "function" then pcall(_G.StaticPopup_Hide, SAMPLE_DIALOG) end
  if host then
    if host.badges then for _, b in ipairs(host.badges) do pcall(b.Hide, b) end end
    if host.marksLabel then pcall(host.marksLabel.Hide, host.marksLabel) end
    pcall(host.Hide, host)
    local tip = _G.GameTooltip
    if tip and tip.GetOwner and tip.Hide and tip:GetOwner() == host then pcall(tip.Hide, tip) end
  end
  if ns.InfoBubble and ns.InfoBubble.DismissSample then pcall(ns.InfoBubble.DismissSample) end
  if ns.Toast and ns.Toast.HideSample then pcall(ns.Toast.HideSample) end
  if ns.AlertBanner and ns.AlertBanner.HideSample then pcall(ns.AlertBanner.HideSample) end
end

-- Stops the samples and invalidates every pending timer.
function Demo.End()
  generation = generation + 1
  if active then cleanup() end
  active = false
end

-- A real alert or question is starting: the samples give way to it. Does nothing when no sample is showing.
function Demo.Interrupt()
  if active then Demo.End() end
end

function Demo.Generation() return generation end
function Demo.Active() return active end

local function wrap(tbl, key)
  local orig = type(tbl) == "table" and tbl[key]
  if type(orig) ~= "function" or wrapped[orig] then return end
  local function wrapper(...)
    Demo.Interrupt()
    return orig(...)
  end
  wrapped[wrapper] = true
  tbl[key] = wrapper
end

-- The real entry points that draw an alert or ask a question end the samples first. Installed once, on first use.
-- Alert.Trigger is not wrapped: it calls Interrupt itself once its tier and cooldown gates pass, so a click that
-- warns about nothing leaves the samples running.
local function install()
  wrap(ns.Alert, "ShowVisual")
  wrap(ns.ConfirmPopup, "Show")
end

local function begin()
  generation = generation + 1
  if active then cleanup() end
  active = true
  install()
  return generation
end

local function settings()
  return ns.Prompt and ns.Prompt.AlertSettings and ns.Prompt.AlertSettings() or {}
end

-- The chosen alert sound, once. Never changes the volume or the channel setting, never the cooldown.
local function playSound()
  if not (ns.Alert and ns.Alert.PlaySound) then return end
  local s = settings()
  pcall(ns.Alert.PlaySound, s.alertSound or (ns.Sounds and ns.Sounds.default), s)
end

-- The notice in the chosen (or, for a preview, a given) style, whatever the real alert toggles say.
local function showNotice(verdict, style)
  local name = labelled(verdict)
  local useWarning = style == "warning" or (style == nil and settings().alertStyle == "warning")
  local mod = useWarning and ns.AlertBanner or ns.Toast or ns.AlertBanner
  if not mod then return false end
  local fn = mod.ShowSample or mod.Show
  return pcall(fn, verdict, name) and true or false
end

local function registerDialog()
  if type(_G.StaticPopupDialogs) ~= "table" then return false end
  if _G.StaticPopupDialogs[SAMPLE_DIALOG] then return true end
  _G.StaticPopupDialogs[SAMPLE_DIALOG] = {
    text = "%s",
    button1 = _G.ACCEPT or L["Accept"],
    button2 = _G.CANCEL or L["Cancel"],
    -- Both answers only close the sample; there is no purchase behind either one.
    OnAccept = function() end,
    OnCancel = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }
  return true
end

-- The question as a real purchase would word it, labelled as a sample, with nothing behind its buttons.
local function showPrompt(verdict)
  if type(_G.StaticPopup_Show) ~= "function" or not registerDialog() then return false end
  local head = ns.UIHelpers.BannerText(verdict, labelled(verdict))
  local level = type(_G.UnitLevel) == "function" and _G.UnitLevel("player") or nil
  local earn = ns.EarnBack and ns.EarnBack.Line(verdict.cost, (level and level > 0) and level or 30)
  local text = head .. "\n\n" .. tostring(verdict.reason) .. (earn and ("\n\n" .. earn) or "")
    .. "\n\n" .. L["This is a sample. Nothing will be bought."]
  local ok, dialog = pcall(_G.StaticPopup_Show, SAMPLE_DIALOG, text, nil, { sample = true })
  return ok and dialog and true or false
end

local function showMarks()
  local h = getHost()
  if not h or not ns.Badge then return false end
  h.badges = h.badges or {}
  local list = { samples().info, samples().deferLow, samples().defer }
  for i, verdict in ipairs(list) do
    local b = h.badges[i]
    if not b then
      local ok, f = pcall(function()
        local x = CreateFrame("Frame", nil, h)
        x:SetSize(24, 24)
        x:SetPoint("CENTER", h, "CENTER", (i - 2) * 40, 0)
        return x
      end)
      b = ok and f or nil
      h.badges[i] = b
    end
    if b then
      pcall(b.Show, b)
      ns.Badge.Attach(b, verdict)
    end
  end
  -- One "Sample" caption above the row, so the bare marks read as samples.
  if not h.marksLabel and ns.Style and ns.Style.Font then
    local ok, s = pcall(ns.Style.Font, h, "supporting")
    if ok and s then
      pcall(s.SetPoint, s, "BOTTOM", h, "CENTER", 0, 18)
      h.marksLabel = s
    end
  end
  if h.marksLabel then
    pcall(h.marksLabel.SetText, h.marksLabel, L["Sample"])
    pcall(h.marksLabel.Show, h.marksLabel)
  end
  pcall(h.Show, h)
  return true
end

local function showTooltip(verdict)
  local h = getHost()
  local tip = _G.GameTooltip
  if not (h and tip and ns.TooltipAugment) then return false end
  return pcall(function()
    pcall(h.Show, h)
    tip:SetOwner(h, "ANCHOR_RIGHT")
    tip:SetText(labelled(verdict))
    ns.TooltipAugment.Augment(tip, verdict)
    tip:Show()
  end) and true or false
end

local function showExplanation(verdict)
  local B = ns.InfoBubble
  local h = getHost()
  if not (B and h) then return false end
  pcall(h.Show, h)
  if B.ShowSample then return pcall(B.ShowSample, verdict, h, labelled(verdict)) and true or false end
  -- No sample hook yet: build the production indicator on the anchor and click it, the way a player would.
  local ok = pcall(function()
    local btn = B.Create(h, verdict)
    local click = btn and btn.GetScript and btn:GetScript("OnClick")
    if click then click(btn) end
  end)
  return ok
end

local function scheduleEnd(gen)
  after(LIFETIME, gen, function() Demo.End() end)
end

-- The tour: the same five samples in the same order every run, with the marks and their hover tooltip.
function Demo.Run()
  local gen = begin()
  local set = samples()
  playSound()
  showMarks()
  showTooltip(set.deferLow)
  showPrompt(set.estimate)
  local steps = { set.info, set.deferLow, set.defer, set.skip }
  for i, verdict in ipairs(steps) do
    after((i - 1) * STEP, gen, function()
      showNotice(verdict)
      if verdict == set.skip then showExplanation(verdict) end
    end)
  end
  scheduleEnd(gen)
  return true
end

-- One surface on its own. Nil or an unknown kind lists the valid ones and changes nothing.
function Demo.Preview(kind)
  kind = type(kind) == "string" and kind:lower() or nil
  local valid
  for _, k in ipairs(KINDS) do if k == kind then valid = true end end
  if not valid then
    if ns.Prompt and ns.Prompt.Say then
      ns.Prompt.Say(L["Previews: %s. Use /ddt preview <name>."]:format(table.concat(KINDS, ", ")))
    end
    return false
  end
  local gen = begin()
  local set = samples()
  if kind == "toast" then
    playSound(); showNotice(set.defer, "toast")
  elseif kind == "warning" then
    playSound(); showNotice(set.defer, "warning")
  elseif kind == "mark" then
    showMarks()
  elseif kind == "tooltip" then
    showTooltip(set.skip)
  elseif kind == "explanation" then
    showExplanation(set.skip)
  else
    showPrompt(set.estimate)
  end
  scheduleEnd(gen)
  return true
end

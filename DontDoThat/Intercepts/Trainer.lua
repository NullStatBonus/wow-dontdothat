local addonName, ns = ...

-- Marks flagged spells in the class, profession and pet trainer windows. Read-only: it adds a
-- tier-colored (i) bubble to each flagged row and changes nothing else. Row buttons are named
-- ClassTrainerSkill1..N and their ID is the service index (observed on Classic Era 1.15.9).
local Trainer = {}
ns.TrainerOverlay = Trainer

local MAX_BUTTONS = 20

-- Evaluates every purchasable row. Returns { byIndex, verdicts } or nil when there is nothing
-- to evaluate (unsupported class, trainer unreadable).
function Trainer.Compute(env)
  local profile = ns.Context.Profile(env)
  if not profile then return nil end
  local trainer = ns.Adapter.ReadTrainer(env)
  if not trainer.ok then return nil end
  local verdicts = {}
  for _, row in ipairs(trainer.rows) do
    if not row.header and ns.Icons then ns.Icons.Remember(row.name, row.icon) end
    if not row.header and not row.learned then
      local learning = ns.Rules.MatchProfessionLearn(row.name)
      local action = learning and { kind = "professionLearn", name = row.name, profession = learning, cost = row.cost }
        or { kind = "spell", name = row.name, family = row.family, rank = row.rank,
             unlockLevel = row.level, cost = row.cost }
      -- A row belongs to the Professions area when it is a first-time profession row, else to Spells.
      local area = learning and "professions" or "spells"
      local ok, verdict = false, nil
      if not ns.Settings or ns.Settings.Watching(area) then ok, verdict = pcall(ns.Rules.Evaluate, profile, action) end
      if ok and verdict then
        verdict.name = verdict.name or row.name
        verdicts[row.index] = verdict
      end
    end
  end
  return { byIndex = trainer.byIndex, verdicts = verdicts, rows = trainer.rows, trainer = trainer }
end

local function enabled()
  local profile = ns.db and ns.db.profile
  if not profile then return true end
  return profile.enabled ~= false and profile.warnings ~= false
end

-- Default widget: an outlined "(i)" button, colored by tier, whose hover shows the reason.
Trainer.widgets = {
  set = function(button, verdict)
    local info = button.dontdothatInfo
    if not info then
      info = ns.InfoBubble.Create(button)
      if not info then return end
      info:SetPoint("RIGHT", button, "RIGHT", -8, 0)
      button.dontdothatInfo = info
    end
    ns.InfoBubble.Refresh(info, verdict)
    if verdict and verdict.tier ~= "keep" then info:Show() else info:Hide() end
  end,
}

-- Applies the computed verdicts to the visible row buttons. widgets.set(button, verdict-or-nil).
function Trainer.Refresh(env, widgets)
  env = env or _G
  widgets = widgets or Trainer.widgets
  local computed = enabled() and Trainer.Compute(env) or nil
  if computed and ns.Tally then pcall(ns.Tally.ObserveLive, env, computed.trainer) end
  for i = 1, MAX_BUTTONS do
    local button = env["ClassTrainerSkill" .. i]
    if type(button) ~= "table" then break end
    local ok, id = pcall(function() return button:GetID() end)
    widgets.set(button, computed and ok and computed.verdicts[id] or nil)
  end
end

-- Never lets an error from our code reach the default interface.
function Trainer.SafeRefresh(env, widgets)
  -- The filter re-draws the rows first, so the marks below are placed by each row's final service index.
  if ns.TrainerFilter then
    local okFilter, filterErr = pcall(ns.TrainerFilter.Apply, env)
    if not okFilter and ns.Log then ns.Log.Add("filter failed: %s", tostring(filterErr)) end
  end
  local ok, err = pcall(Trainer.Refresh, env, widgets)
  if not ok and ns.Log then ns.Log.Add("trainer overlay failed: %s", tostring(err)) end
  return ok
end

local hooked = false

function Trainer.Reset() hooked = false end

-- eventTarget must be a dedicated AceEvent object: a second registration for the same event on
-- the same object would replace the debug capture's handler.
function Trainer.Enable(eventTarget, env)
  env = env or _G
  local function installHook()
    if hooked or type(env.hooksecurefunc) ~= "function" or type(env.ClassTrainerFrame_Update) ~= "function" then return end
    hooked = pcall(env.hooksecurefunc, "ClassTrainerFrame_Update", function()
      if ns.TrainerFilter then ns.TrainerFilter.inUpdate = true end
      Trainer.SafeRefresh(env)
      if ns.TrainerFilter then ns.TrainerFilter.inUpdate = false end
    end)
    if ns.Log then ns.Log.Add("overlay: ClassTrainerFrame_Update %s", hooked and "hooked" or "FAILED to hook") end
  end
  for _, event in ipairs({ "TRAINER_SHOW", "TRAINER_UPDATE" }) do
    pcall(eventTarget.RegisterEvent, eventTarget, event, function()
      installHook()
      -- The Train button only exists after the trainer window first loads.
      if ns.TrainerConfirm then pcall(ns.TrainerConfirm.Install, env) end
      Trainer.SafeRefresh(env)
    end)
  end
  if ns.TrainerConfirm then ns.TrainerConfirm.Watch(eventTarget) end
end

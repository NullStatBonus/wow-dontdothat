local addonName, ns = ...

-- The "Recommended" entry in the trainer window's filter menu. Hiding rows means re-drawing the list:
-- Blizzard shows service (row number + scroll offset) in each of its 11 row buttons, so after Blizzard
-- has drawn, this draws the visible services instead, with the same steps Blizzard uses (copied from
-- its Blizzard_TrainerUI.lua, Classic Era branch). Rows keep their real service index as the button ID,
-- so clicking, selecting and buying all still act on the service the row shows.
--
-- If anything is missing or fails, the filter turns itself off for the session and the window is put
-- back to Blizzard's own display. It never leaves the trainer half-drawn.
local Filter = {}
ns.TrainerFilter = Filter

local MENU_TAG = "MENU_TRAINER_FILTER"
local degraded

function Filter.Reset() degraded = nil end
function Filter.DegradedReason() return degraded end

-- True while Blizzard's own update is running (our hook is being called from inside it), so the rows on
-- screen were just redrawn by Blizzard and nothing of ours is left to undo.
Filter.inUpdate = false

local function settings()
  return (ns.db and ns.db.profile) or {}
end

-- Two separate settings:
--   recommendedFilter  the feature is offered at all (the What to watch switch; adds the menu entry)
--   recommendedActive  the entry's checkbox in the trainer's Filter menu is ticked (rows are hidden)
-- Keeping them apart lets you untick the checkbox in the menu and tick it again later, while the What to watch
-- switch (or turning the addon off) removes the entry altogether.
local function offered()
  local p = settings()
  return p.enabled ~= false and p.recommendedFilter ~= false
end

local function filterOn()
  return not degraded and offered() and settings().recommendedActive ~= false
end

---------------------------------------------------------------------------
-- Drawing

-- Blizzard's per-row steps (ClassTrainerFrame_Update), applied to one button.
local function drawRow(env, i, row, selectedIndex)
  local button = env["ClassTrainerSkill" .. i]
  local text = env["ClassTrainerSkill" .. i .. "Text"]
  local subText = env["ClassTrainerSkill" .. i .. "SubText"]
  local highlightTexture = env["ClassTrainerSkill" .. i .. "Highlight"]
  local name, sub, kind, expanded = env.GetTrainerServiceInfo(row.index)
  name = name or env.UNKNOWN or "?"

  button:SetWidth(env.ClassTrainerListScrollFrame:IsVisible() and 293 or 323)
  if kind == "header" then
    text:SetText(name)
    text:SetWidth(0)
    button:SetNormalFontObject("GameFontNormal")
    subText:Hide()
    button:SetNormalTexture(expanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
    highlightTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
  else
    button:ClearNormalTexture()
    highlightTexture:SetTexture("")
    text:SetText("  " .. name)
    if sub and sub ~= "" then
      subText:SetText((env.PARENS_TEMPLATE or "(%s)"):format(sub))
      subText:SetPoint("LEFT", "ClassTrainerSkill" .. i .. "Text", "RIGHT", 10, 0)
      subText:Show()
      text:SetWidth(0)
    else
      subText:Hide()
      text:SetWidth(env.SKILL_TEXT_WIDTH or 270)
    end
    local font, r, g, b
    if kind == "available" then font, r, g, b = "GameFontNormalLeftGreen", 0, 0.6, 0
    elseif kind == "used" then font, r, g, b = "GameFontDisable", 0.5, 0.5, 0.5
    else font, r, g, b = "GameFontNormalLeftRed", 0.6, 0, 0 end
    button:SetNormalFontObject(font)
    if env.ClassTrainer_SetSubTextColor then env.ClassTrainer_SetSubTextColor(button, r, g, b) end
  end

  button:SetID(row.index)
  button:Show()

  local highlight = env.ClassTrainerSkillHighlightFrame
  if env.ClassTrainerFrame.selectedService and selectedIndex == row.index and highlight then
    highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    highlight:Show()
    button:LockHighlight()
    local c = env.HIGHLIGHT_FONT_COLOR or { r = 1, g = 1, b = 1 }
    if env.ClassTrainer_SetSubTextColor then env.ClassTrainer_SetSubTextColor(button, c.r, c.g, c.b) end
  else
    button:UnlockHighlight()
  end
end

-- Asks the open trainer window to redraw itself, so a changed setting shows at once. Our hook then runs
-- after Blizzard's drawing and applies whatever the settings now say.
function Filter.Refresh(env)
  env = env or _G
  local frame = env.ClassTrainerFrame
  if type(frame) == "table" and type(frame.IsVisible) == "function" and frame:IsVisible()
      and type(env.ClassTrainerFrame_Update) == "function" then
    pcall(env.ClassTrainerFrame_Update)
  end
end

-- Rebuilds the trainer's Filter menu, so the entry appears or goes away to match the settings.
function Filter.RebuildMenu(env)
  env = env or _G
  local frame = env.ClassTrainerFrame
  local dropdown = type(frame) == "table" and frame.FilterDropdown
  if type(dropdown) == "table" and type(dropdown.GenerateMenu) == "function" then pcall(dropdown.GenerateMenu, dropdown) end
end

-- Draws visibility.visible into the row buttons. Raises on anything unexpected; the caller degrades.
function Filter.Render(env, visibility)
  local scroll = env.ClassTrainerListScrollFrame
  local count = env.CLASS_TRAINER_SKILLS_DISPLAYED
  local height = env.CLASS_TRAINER_SKILL_HEIGHT
  assert(type(scroll) == "table", "no scroll frame")
  assert(type(count) == "number" and type(height) == "number", "no row size constants")
  assert(type(env.FauxScrollFrame_Update) == "function" and type(env.FauxScrollFrame_GetOffset) == "function", "no scroll functions")
  assert(type(env.GetTrainerServiceInfo) == "function", "no service info")
  for i = 1, count do assert(type(env["ClassTrainerSkill" .. i]) == "table", "missing row button " .. i) end

  local visible = visibility.visible
  env.ClassTrainerFrame.DontDoThatFiltered = true
  env.FauxScrollFrame_Update(scroll, #visible, count, height, nil, nil, nil, env.ClassTrainerSkillHighlightFrame, 293, 316)
  local offset = env.FauxScrollFrame_GetOffset(scroll)
  if env.ClassTrainerSkillHighlightFrame then env.ClassTrainerSkillHighlightFrame:Hide() end

  local selectedIndex
  if type(env.GetTrainerSelectionIndex) == "function" then selectedIndex = env.GetTrainerSelectionIndex() end

  for i = 1, count do
    local row = visible[i + offset]
    if row then drawRow(env, i, row, selectedIndex) else env["ClassTrainerSkill" .. i]:Hide() end
  end
end

local function degrade(env, reason)
  degraded = tostring(reason)
  if ns.Log then ns.Log.Add("filter: turned off (%s)", degraded) end
  -- Put Blizzard's own drawing back.
  if type(env.ClassTrainerFrame_Update) == "function" then pcall(env.ClassTrainerFrame_Update) end
end

-- Runs after Blizzard has drawn the list. Does nothing unless something is actually hidden.
function Filter.Apply(env)
  env = env or _G
  local frame = env.ClassTrainerFrame
  if type(frame) ~= "table" or type(frame.IsVisible) ~= "function" or not frame:IsVisible() then return false end

  -- If our filtered rows are still on screen and the filter should no longer be applied (it was just
  -- switched off, or there is nothing left to hide), have Blizzard draw the list again. Inside Blizzard's
  -- own update the rows were just redrawn, so there is nothing to undo.
  local wasFiltered = frame.DontDoThatFiltered
  frame.DontDoThatFiltered = nil
  local function putBack()
    if wasFiltered and not Filter.inUpdate then Filter.Refresh(env) end
    return false
  end

  if not filterOn() then return putBack() end
  local computed = ns.TrainerOverlay.Compute(env)
  if not computed then return putBack() end
  local visibility = ns.TrainerVisibility.Compute(computed.rows, function(row)
    return computed.verdicts[row.index]
  end, { enabled = true })
  if visibility.hiddenCount == 0 then return putBack() end

  local ok, err = pcall(Filter.Render, env, visibility)
  if not ok then
    degrade(env, err)
    return false
  end
  return true
end

---------------------------------------------------------------------------
-- The menu entry

local function isSelected()
  return settings().recommendedActive ~= false
end

local function setSelected(env)
  local p = settings()
  p.recommendedActive = not isSelected()
  if ns.Log then ns.Log.Add("filter: Recommended turned %s", p.recommendedActive and "on" or "off") end
  Filter.Refresh(env)
  -- The menu is still closing at this moment; draw once more just after it has.
  if type(env.C_Timer) == "table" and type(env.C_Timer.After) == "function" then
    pcall(env.C_Timer.After, 0.1, function() Filter.Refresh(env) end)
  end
end

local registered = false

function Filter.Enable(env)
  env = env or _G
  if registered then return true end
  local menu = env.Menu
  if type(menu) ~= "table" or type(menu.ModifyMenu) ~= "function" then
    if ns.Log then ns.Log.Add("filter: no Menu.ModifyMenu on this client, so no Recommended entry") end
    return false
  end
  registered = pcall(menu.ModifyMenu, MENU_TAG, function(_, rootDescription)
    -- A menu modifier cannot be removed once added, so it checks the settings each time the menu is
    -- built: with the addon off, or the What to watch switch off, the entry is simply not offered.
    if not offered() then return end
    pcall(function()
      rootDescription:CreateCheckbox("Recommended |cff9d9d9d(Don't Do That)|r", isSelected, function() setSelected(env) end)
    end)
  end)
  if ns.Log then ns.Log.Add("filter: menu entry %s", registered and "registered" or "FAILED to register") end
  return registered
end

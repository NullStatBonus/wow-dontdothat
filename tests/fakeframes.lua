-- Recording stand-ins for the WoW frame API, enough for the owned UI surfaces (toast, pinned explanation).
local F = {}

local function object(kind, name)
  local o = { kind = kind, name = name, shown = kind ~= "Frame" and kind ~= "Button", alpha = 1, scripts = {},
    points = {}, strata = nil, mouse = nil }
  function o:GetName() return self.name end
  function o:Show()
    self.shown = true
  end
  function o:Hide()
    local was = self.shown
    self.shown = false
    if was and self.scripts.OnHide then self.scripts.OnHide(self) end
  end
  function o:IsShown() return self.shown end
  function o:SetAlpha(a) self.alpha = a end
  function o:GetAlpha() return self.alpha end
  function o:SetScale(s) self.scale = s end
  function o:GetScale() return self.scale or 1 end
  function o:EnableKeyboard(on) self.keyboard = on end
  function o:SetPropagateKeyboardInput(on) self.propagate = on end
  function o:SetSize(w, h) self.width, self.height = w, h end
  function o:SetWidth(w) self.width = w end
  function o:SetHeight(h) self.height = h end
  function o:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function o:ClearAllPoints() self.points = {} end
  function o:GetPoint()
    local p = self.points[1]
    if not p then return nil end
    return p[1], p[2], p[3], p[4], p[5]
  end
  function o:SetAllPoints() end
  function o:SetFrameStrata(s) self.strata = s end
  function o:EnableMouse(on) self.mouse = on end
  function o:SetScript(event, fn) self.scripts[event] = fn end
  function o:SetClampedToScreen(on) self.clamped = on end
  function o:SetClampRectInsets(...) self.insets = { ... } end
  function o:SetMovable() end
  function o:RegisterForDrag() end
  function o:StartMoving() self.moving = true end
  function o:StopMovingOrSizing() self.moving = false end
  function o:SetUserPlaced(on) self.userPlaced = on end
  function o:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
  function o:SetTexture(t) self.texture = t end
  function o:SetText(t) self.text = t end
  function o:GetText() return self.text end
  function o:SetTextColor(r, g, b) self.textColor = { r, g, b } end
  function o:SetFont() end
  function o:SetJustifyH() end
  function o:SetJustifyV() end
  function o:SetWordWrap() end
  function o:GetStringHeight()
    local t = self.text or ""
    return t == "" and 0 or 12 * (1 + select(2, t:gsub("\n", "")) + math.floor(#t / 60))
  end
  function o:CreateTexture() local t = object("Texture"); F.created[#F.created + 1] = t; return t end
  function o:CreateFontString() local t = object("FontString"); F.created[#F.created + 1] = t; return t end
  function o:CreateAnimationGroup()
    local g = { playing = false, scripts = {} }
    function g:CreateAnimation()
      local a = {}
      for _, m in ipairs({ "SetFromAlpha", "SetToAlpha", "SetStartDelay", "SetDuration" }) do a[m] = function() end end
      return a
    end
    function g:SetScript(e, fn) self.scripts[e] = fn end
    function g:Play() self.playing = true end
    function g:Stop() self.playing = false end
    function g:Finish() self.playing = false; if self.scripts.OnFinished then self.scripts.OnFinished() end end
    o.groupRef = g
    return g
  end
  return o
end

-- Installs CreateFrame/UIParent/UISpecialFrames globals; returns a restore function.
function F.install()
  F.created = {}
  F.frames = {}
  local saved = { CreateFrame = _G.CreateFrame, UIParent = _G.UIParent, UISpecialFrames = _G.UISpecialFrames }
  _G.UIParent = object("Frame", "UIParent")
  _G.UISpecialFrames = { "GameMenuFrame" }
  _G.CreateFrame = function(kind, name, parent, template)
    local f = object(kind, name)
    f.parent, f.template = parent, template
    if kind == "Button" then
      f.shown = true
      if template then f.text = nil end
    end
    F.frames[#F.frames + 1] = f
    if name then F[name] = f end
    return f
  end
  return function()
    for k, v in pairs(saved) do _G[k] = v end
  end
end

function F.button(label)
  for _, f in ipairs(F.frames) do
    if f.kind == "Button" and f.text == label then return f end
  end
end

return F

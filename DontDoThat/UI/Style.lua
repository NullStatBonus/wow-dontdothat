local addonName, ns = ...

-- Frame helpers for the addon's own surfaces. Every game call is guarded: a missing font object, template or
-- API falls back to something plainer and never stops a warning or a purchase safeguard.
local S = {}
ns.Style = S

local FALLBACK = { supporting = 12, body = 14, heading = 14 }

-- A font string in the given role (supporting | body | heading) using the native font objects, with fallbacks.
function S.Font(frame, role, layer)
  local H = ns.UIHelpers
  local s = frame:CreateFontString(nil, layer or "OVERLAY")
  local done = false
  for _, obj in ipairs({ H.FONTS[role] or H.FONTS.body, H.FONTS.body, H.FONTS.heading }) do
    local font = _G[obj]
    if font ~= nil and s.SetFontObject and pcall(s.SetFontObject, s, font) then done = true break end
  end
  if not done and s.SetFont then pcall(s.SetFont, s, "Fonts\\FRIZQT__.TTF", FALLBACK[role] or 14, "") end
  if s.SetJustifyH then s:SetJustifyH("LEFT") end
  if s.SetJustifyV then s:SetJustifyV("TOP") end
  if s.SetWordWrap then pcall(s.SetWordWrap, s, true) end
  return s
end

-- A native button (UIPanelButtonTemplate), or a plain text button on a client without that template.
function S.Button(parent, label, onClick, width)
  local ok, b = pcall(CreateFrame, "Button", nil, parent, "UIPanelButtonTemplate")
  if ok and b then
    if b.SetText then b:SetText(label) end
  else
    b = CreateFrame("Button", nil, parent)
    b.text = S.Font(b, "body")
    b.text:SetPoint("CENTER", b, "CENTER", 0, 0)
    b.text:SetText(label)
  end
  b:SetSize(width or 96, 24)
  b:SetScript("OnClick", onClick)
  return b
end

local function call(obj, method, ...)
  if obj and obj[method] then return pcall(obj[method], obj, ...) end
end
S.call = call

-- Applies a surface's look: the background pieces (fill, border, accent) show only above zero alpha;
-- content (text and icons) takes its own alpha. Neither touches the frame alpha, which the fade owns.
function S.ApplySurface(background, content, look)
  for _, piece in ipairs(background) do
    if look.bg <= 0 then call(piece, "Hide")
    else
      call(piece, "SetAlpha", look.bg)
      call(piece, "Show")
    end
  end
  for _, piece in ipairs(content) do call(piece, "SetAlpha", look.text) end
end

-- Adds or removes a named frame from the game's Escape list. Returns false when the client has none.
function S.SetEscape(frame, on)
  local list = _G.UISpecialFrames
  local ok, name = call(frame, "GetName")
  if not ok or type(name) ~= "string" or type(list) ~= "table" then return false end
  for i = #list, 1, -1 do
    if list[i] == name then table.remove(list, i) end
  end
  if on then list[#list + 1] = name end
  return true
end

-- The profile table a surface reads its look from, or nil outside a loaded profile (tests, early load).
function S.Profile()
  return ns.db and ns.db.profile
end

local addonName, ns = ...

-- Spell icons for the settings pages, by spell family ID. An icon a trainer window showed is remembered; anything
-- else comes from the game's own spell data. A spell the game cannot name gets a question mark.
local Icons = {}
ns.Icons = Icons

Icons.Fallback = "Interface\\Icons\\INV_Misc_QuestionMark"

local function saved()
  return ns.db and ns.db.global and ns.db.global.icons
end

function Icons.Remember(id, icon)
  local store = saved()
  if store and type(id) == "number" and icon and store[id] ~= icon then store[id] = icon end
end

local function fromClient(env, id)
  if type(env.C_Spell) == "table" and type(env.C_Spell.GetSpellInfo) == "function" then
    local ok, info = pcall(env.C_Spell.GetSpellInfo, id)
    if ok and type(info) == "table" and info.iconID then return info.iconID end
  end
  if type(env.GetSpellInfo) == "function" then
    local ok, _, _, icon = pcall(env.GetSpellInfo, id)
    if ok and icon then return icon end
  end
end

function Icons.Lookup(id, env)
  local store = saved()
  if store and store[id] then return store[id] end
  env = env or _G
  -- The game supplies the icon for any spell ID, learned or not.
  local byId = ns.SpellData and ns.SpellData.IconFor(id, env)
  return byId or fromClient(env, id) or Icons.Fallback
end

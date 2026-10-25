local addonName, ns = ...

-- Spell icons for the settings pages. The rule data has no spell IDs, so icons are remembered by name
-- whenever a trainer window shows them, and looked up from the spellbook for spells already known.
-- Anything not seen yet gets a question mark until the player next visits a trainer.
local Icons = {}
ns.Icons = Icons

Icons.Fallback = "Interface\\Icons\\INV_Misc_QuestionMark"

local function saved()
  return ns.db and ns.db.global and ns.db.global.icons
end

function Icons.Remember(name, icon)
  local store = saved()
  if store and type(name) == "string" and icon and store[name] ~= icon then store[name] = icon end
end

local function fromClient(env, name)
  if type(env.C_Spell) == "table" and type(env.C_Spell.GetSpellInfo) == "function" then
    local ok, info = pcall(env.C_Spell.GetSpellInfo, name)
    if ok and type(info) == "table" and info.iconID then return info.iconID end
  end
  if type(env.GetSpellInfo) == "function" then
    local ok, _, _, icon = pcall(env.GetSpellInfo, name)
    if ok and icon then return icon end
  end
end

function Icons.Lookup(name, env)
  local store = saved()
  if store and store[name] then return store[name] end
  env = env or _G
  -- The bundled spell IDs let the game supply the icon for any spell, learned or not.
  local byId = ns.SpellData and ns.SpellData.IconFor(name, env)
  return byId or fromClient(env, name) or Icons.Fallback
end

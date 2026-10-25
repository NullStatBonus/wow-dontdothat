local addonName, ns = ...

-- Sorts an item into one of the warning categories from the game's own item class numbers.
-- Class IDs (Classic): 0 consumable, 1 container, 2 weapon, 3 gem, 4 armor, 5 reagent, 6 projectile,
-- 7 trade goods, 9 recipe, 11 quiver, 12 quest, 13 key, 15 miscellaneous.
local Category = {}
ns.ItemCategory = Category

-- Display order. The default mode of each lives in ns.defaults.profile.itemModes.
Category.List = {
  { key = "armor",    label = "Armor",                      reason = "Gear can wait. That gold is for your mount." },
  { key = "weapons",  label = "Weapons",                    reason = "A new weapon can wait. That gold is for your mount." },
  { key = "vanity",   label = "Vanity (pets, tabards, shirts)", reason = "Looks don't level you. That gold is for your mount." },
  { key = "bags",     label = "Bags",                       reason = "Bags are a gold sink. Make do for now." },
  { key = "recipes",  label = "Recipes",                    reason = "You can level a profession without buying recipes." },
  { key = "potions",  label = "Potions, elixirs, flasks",   reason = "Consumables burn gold fast." },
  { key = "gems",     label = "Gems and enchants",          reason = "Not worth the gold while leveling." },
  { key = "food",     label = "Food and drink",             reason = "Vendors sell it cheaper than the auction house." },
  { key = "trade",    label = "Trade goods",                reason = "Gather it yourself and keep the gold." },
  { key = "ammo",     label = "Ammo, quivers, pouches",     reason = "Check the vendor before paying auction prices." },
  { key = "reagents", label = "Class reagents",             reason = "Vendors sell reagents cheaper than the auction house." },
  { key = "mounts",   label = "Mounts",                     reason = "Your mount is what you're saving for." },
  { key = "misc",     label = "Keys, quest items, other",   reason = "This isn't worth your gold right now." },
}

local BY_KEY = {}
for _, c in ipairs(Category.List) do BY_KEY[c.key] = c end
function Category.Info(key) return BY_KEY[key] end

local VANITY_SLOTS = { INVTYPE_TABARD = true, INVTYPE_BODY = true }
local FOOD, POTIONS = 5, { [0] = true, [1] = true, [2] = true, [3] = true, [7] = true, [8] = true }

-- item = { classID, subClassID, equipLoc }. Always returns a category key; unknown things are "misc".
function Category.Classify(item)
  local class, sub = item and item.classID, item and item.subClassID
  if class == 4 then return VANITY_SLOTS[item.equipLoc] and "vanity" or "armor" end
  if class == 2 then return "weapons" end
  if class == 1 then return "bags" end
  if class == 9 then return "recipes" end
  if class == 3 then return "gems" end
  if class == 7 then return "trade" end
  if class == 6 or class == 11 then return "ammo" end
  if class == 5 then return "reagents" end
  if class == 0 then
    if sub == FOOD then return "food" end
    if POTIONS[sub] then return "potions" end
  end
  if class == 15 then
    if sub == 2 then return "vanity" end
    if sub == 5 then return "mounts" end
    if sub == 1 then return "reagents" end
  end
  return "misc"
end

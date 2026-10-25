local addonName, ns = ...

-- Professions the player is asked about the first time they train them. Gathering professions are
-- exempt; everything else is asked about once. Reasons are plain-language and per profession, with a
-- generic sentence for any profession not listed. The row naming ("Apprentice <Profession>") is
-- UNVERIFIED on the real trainer.
ns.Rules.SetProfessionLearn({
  gathering = { Skinning = true, Herbalism = true, Mining = true },
  reasons = {
    Alchemy = "Potions need herbs and vials, and the gold you spend learning it won't come back before level 40.",
    Blacksmithing = "Smithing eats ore and bars you could sell, and its gear rarely beats quest rewards while leveling.",
    Cooking = "Food saves little gold while leveling, and recipes cost more than the dishes are worth.",
    Enchanting = "Enchanting costs gold for recipes and rods and pays back late. It also needs you to disenchant gear you could sell.",
    Engineering = "Engineering parts and gadgets are expensive early, and the gold you spend learning it won't come back before level 40.",
    ["First Aid"] = "Bandages cost cloth you could sell, and your pet and your bow already cover most fights.",
    Fishing = "Fishing earns little gold per hour compared to skinning and killing beasts.",
    Leatherworking = "Leatherworking uses the leather you could sell, and recipes and trainer fees cost gold you won't earn back before level 40.",
    Tailoring = "Tailoring eats cloth you could sell, and a Hunter can't use most of what it makes.",
  },
  generic = "%s costs gold to learn and to level, and it won't pay for itself before level 40.",
})

local addonName, ns = ...

-- Tier skill caps are the Classic values (75/150/225/300).
-- Costs are UNVERIFIED placeholder estimates in copper; edit freely. Apprentice cost is unknown (nil).
-- A tier is flagged only while skill is more than nearCapMargin below the current cap.

ns.Rules.Load({
  profession = "Herbalism",
  tier = "defer",
  nearCapMargin = 25,
  tiers = {
    { name = "Apprentice", cap = 75, cost = nil },
    { name = "Journeyman", cap = 150, cost = 500 },    -- UNVERIFIED estimate
    { name = "Expert", cap = 225, cost = 10000 },      -- UNVERIFIED estimate
    { name = "Artisan", cap = 300, cost = 50000 },     -- UNVERIFIED estimate
  },
})

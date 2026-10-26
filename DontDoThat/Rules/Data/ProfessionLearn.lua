local addonName, ns = ...

-- Professions the player is asked about the first time they train them. Gathering professions are
-- exempt; everything else is asked about once. The row naming ("Apprentice <Profession>") is
-- UNVERIFIED on the real trainer.
ns.Rules.SetProfessionLearn({
  gathering = { Skinning = true, Herbalism = true, Mining = true, Fishing = true },
  reason = "Leveling %s costs gold at every step: materials, recipes and training fees. Wait until your mount is paid for.",
})

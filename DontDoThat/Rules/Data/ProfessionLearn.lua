local addonName, ns = ...
local L = ns.L

-- Professions the player is asked about the first time they train them. Gathering professions are
-- exempt; everything else is asked about once. A profession is named by the key below and recognised by the
-- client's own name for its apprentice spell, so the trainer row can be in any language.
ns.Rules.SetProfessionLearn({
  gathering = { Skinning = true, Herbalism = true, Mining = true, Fishing = true },
  apprentice = {
    Alchemy = 2259, Blacksmithing = 2018, Cooking = 2550, Enchanting = 7411, Engineering = 4036,
    ["First Aid"] = 3273, Fishing = 7620, Herbalism = 2366, Leatherworking = 2108, Mining = 2575,
    Skinning = 8613, Tailoring = 3908,
  },
  reason = L["Leveling %s costs gold at every step: materials, recipes and training fees. Wait until your mount is paid for."],
})

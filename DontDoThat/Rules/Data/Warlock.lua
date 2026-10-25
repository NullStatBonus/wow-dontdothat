local addonName, ns = ...

-- Source status: every rotation is a judgement call from common leveling builds, not a verified guide, so each
-- carries needsReview = true. Spell names, levels, talents and tab order come from the game's own tables
-- (WoW Forever 1.60.1.70532 and Classic Era 1.15.9.70003); what the trainer sells and what it charges are
-- UNVERIFIED until a trainer is captured with /ddt export. Gold costs are left nil.
-- Written by tools/scaffold_class_rules.py from tools/class_plans/warlock.py.
-- Every spell family must appear below (a rotation, a tag, an override or `reviewed`);
-- tests/rules_classes_test.lua fails on any that does not.

-- What every spec of this class keeps buying.
local SHARED_CORE = {
  "Shadow Bolt", "Corruption", "Immolate", "Curse of Agony", "Bane of Agony", "Life Tap", "Drain Soul",
  "Drain Life", "Health Funnel", "Fear", "Create Healthstone", "Create Soulstone",
  "Create Healthstone (Minor)", "Create Healthstone (Lesser)", "Create Healthstone (Greater)",
  "Create Healthstone (Major)", "Create Soulstone (Minor)", "Create Soulstone (Lesser)",
  "Create Soulstone (Greater)", "Create Soulstone (Major)", "Demon Armor", "Demon Skin",
  "Summon Voidwalker", "Summon Succubus", "Summon Incubus", "Unending Breath", "Ritual of Summoning",
  "Howl of Terror", "Death Coil", "Inferno", "Summon Felhunter", "Siphon Life",
}
-- Handy now and then for any spec. The talent ones count only while the talent is active.
local SHARED_SITUATIONAL = {
  "Hellfire", "Dark Pact",
}

local function with(base, extra)
  local out = {}
  for _, name in ipairs(base) do out[#out + 1] = name end
  for _, name in ipairs(extra) do out[#out + 1] = name end
  return out
end

ns.Rules.Load({
  class = "WARLOCK",

  specs = {
    AFFL = {
      name = "Affliction", tree = 1, -- TalentTab order verified from the game tables
      rotation = { needsReview = true, core = with(SHARED_CORE, {}), situational = SHARED_SITUATIONAL },
    },
    DEMO = {
      name = "Demonology", tree = 2, -- TalentTab order verified from the game tables
      rotation = { needsReview = true, core = with(SHARED_CORE, {}), situational = SHARED_SITUATIONAL },
    },
    DEST = {
      name = "Destruction", tree = 3, -- TalentTab order verified from the game tables
      rotation = { needsReview = true, core = with(SHARED_CORE, { "Shadowburn", "Conflagrate", "Rain of Fire" }), situational = SHARED_SITUATIONAL },
    },
  },

  tagTiers = { PvP = "deferLow", RaidGroup = "defer", LowValue = "deferLow", Endgame = "defer" },

  tagReasons = {
    PvP = "Mostly useful against other players.",
    RaidGroup = "Only needed in groups and raids.",
    LowValue = "Rarely helps while leveling.",
    Endgame = "You won't need this until level 60.",
  },
  why = {
    ["Bane of Doom"] = "A level 60 curse.",
    ["Banish"] = "Rarely helps while leveling.",
    ["Curse of Doom"] = "A level 60 curse.",
    ["Curse of Idiocy"] = "A minor curse you can do without.",
    ["Curse of Recklessness"] = "A minor curse you can do without.",
    ["Curse of Shadow"] = "A debuff for groups and raids.",
    ["Curse of Tongues"] = "Mostly useful against other players.",
    ["Curse of Weakness"] = "A minor curse you can do without.",
    ["Curse of the Elements"] = "A debuff for groups and raids.",
    ["Detect Greater Invisibility"] = "Only shows hidden enemies.",
    ["Detect Invisibility"] = "Only shows hidden enemies.",
    ["Detect Lesser Invisibility"] = "Only shows hidden enemies.",
    ["Drain Mana"] = "Mostly useful against other casters in PvP.",
    ["Explorer Imp"] = "A scouting toy you can live without.",
    ["Eye of Kilrogg"] = "A scouting tool you can live without.",
    ["Fel Armor"] = "A later armor you can do without while leveling.",
    ["Incinerate"] = "A level 40 nuke you can do without while leveling.",
    ["Portal of Summoning"] = "Costs a Soul Shard reagent and is for groups.",
    ["Ritual of Doom"] = "A group ritual for level 60.",
    ["Searing Pain"] = "Shadow Bolt and your damage-over-time spells cover it.",
    ["Sense Demons"] = "Only shows where demons are.",
    ["Shadow Ward"] = "A short shield you rarely need while leveling.",
    ["Soul Fire"] = "A slow nuke you can do without while leveling.",
    ["Subjugate Demon"] = "Rarely worth the soul shard and the setup.",
    ["Wrack"] = "Rarely helps while leveling.",
    ["~Create Firestone"] = "A buff stone you can do without.",
    ["~Create Spellstone"] = "A buff stone you can do without.",
  },

  tags = {
    ["Curse of Weakness"] = { "LowValue" },
    ["Curse of Recklessness"] = { "LowValue" },
    ["Curse of Idiocy"] = { "LowValue" },
    ["Subjugate Demon"] = { "LowValue" },
    ["Eye of Kilrogg"] = { "LowValue" },
    ["Detect Invisibility"] = { "LowValue" },
    ["Detect Lesser Invisibility"] = { "LowValue" },
    ["Detect Greater Invisibility"] = { "LowValue" },
    ["Sense Demons"] = { "LowValue" },
    ["Explorer Imp"] = { "LowValue" },
    ["Searing Pain"] = { "LowValue" },
    ["Incinerate"] = { "LowValue" },
    ["Soul Fire"] = { "LowValue" },
    ["Create Firestone"] = { "LowValue" },
    ["Create Firestone (Greater)"] = { "LowValue" },
    ["Create Firestone (Lesser)"] = { "LowValue" },
    ["Create Firestone (Major)"] = { "LowValue" },
    ["Create Spellstone"] = { "LowValue" },
    ["Create Spellstone (Greater)"] = { "LowValue" },
    ["Create Spellstone (Major)"] = { "LowValue" },
    ["Banish"] = { "LowValue" },
    ["Shadow Ward"] = { "LowValue" },
    ["Wrack"] = { "LowValue" },
    ["Fel Armor"] = { "LowValue" },
    ["Curse of Tongues"] = { "PvP" },
    ["Drain Mana"] = { "PvP" },
    ["Curse of the Elements"] = { "RaidGroup" },
    ["Curse of Shadow"] = { "RaidGroup" },
    ["Portal of Summoning"] = { "Endgame" },
    ["Ritual of Doom"] = { "Endgame" },
    ["Bane of Doom"] = { "Endgame" },
    ["Curse of Doom"] = { "Endgame" },
  },

  -- Active spells that come from a talent of the same name. Verified from the game's talent tables.
  talentSpells = {
    "Conflagrate", "Dark Pact", "Master Demonologist", "Shadowburn", "Siphon Life",
  },

  -- Demon-trainer grimoires teach a demon its abilities. All of them are flagged at vendors except the ones the Icy Veins and Wowhead guides recommend (every Imp and Voidwalker grimoire, the Succubus's Lash of Pain, Seduction and Lesser Invisibility) and the Felhunter's interrupt.
  grimoires = { keep = { "Firebolt", "Blood Pact", "Fire Shield", "Phase Shift", "Consume Shadows", "Sacrifice", "Suffering", "Torment", "Lash of Pain", "Seduction", "Lesser Invisibility", "Spell Lock" }, reason = "Secondary demon abilities can wait." },

  milestones = {
    [40] = { riding = 0, mount = 0,
      note = "Your Felsteed is paid for in souls, not gold." },
  },

  -- Considered and deliberately left at keep: passives, effects, racial and Forever-only spells whose use is not yet known.
  reviewed = {
    "Bane of Doom Effect", "Bane of Havoc", "Chaos Bolt", "Curse of Doom Effect",
    "Dance of the Wicked", "Demon Charge", "Demonic Grace", "Demonic Howl", "Grimoire of Synergy",
    "Haunt", "Hellfire Effect", "Invocation", "Master Demonologist", "Menace", "Metamorphosis",
    "Ritual of Doom Effect", "Shadow Cleave", "Shadowflame", "Soul Harvest", "Soul Harvesting",
    "Summon Dreadsteed", "Summon Felsteed", "Summon Imp", "Vengeance",
  },
})

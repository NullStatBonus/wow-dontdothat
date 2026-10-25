# Proposal

## Why

Hunter and Paladin are supported; the other seven Classic classes are not, so their players get no warnings at all. Each class has spells that cost real trainer gold and add little while leveling (utility, PvP, group and endgame spells, and redundant ranks), and Warlocks additionally spend gold on demon grimoires.

## What Changes

- Add rule data for Mage, Warlock, Priest, Druid, Shaman, Rogue and Warrior, classifying every spell family in the WoW Forever and Classic Era tables (kept, informational, defer-low-value, defer, or reviewed-and-kept), with spec-aware rotations flagged needs-review and a test that fails on any unclassified spell.
- Mark each class's talent-only spells (taken from the game's talent tables) so they count as part of a rotation only while the talent is active.
- Skip higher ranks only where the game data shows they add nothing the player needs: Psychic Scream (ranks 2 to 4), Gouge (2 to 5), Kick (2 to 4) and Shield Bash (2 to 3). The brief's other "rank 1 is enough" lines are not applied because the data contradicts them (for example Fear lasts 10, 15 and 20 seconds by rank), and its "keep Frostbolt and Frost Nova at rank 1 on your bars" is an action-bar tip, not training advice, so it produces no rule.
- Warlocks: a level 40 mount target of 0 gold (the Felsteed quest is free and teaches Apprentice Riding) with a Warlock-themed note, and a new item rule that asks before buying a demon grimoire, except Imp Firebolt and Voidwalker Torment.
- Bundle spell tables for the seven classes by extending the spell-data generator.
- Out of scope: Season of Discovery rune abilities, pet and demon spells that are not class abilities, rank skips without data support, and weapon-skill and profession advice.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `rule-engine`: the seven classes are supported with their own rule data, rank skips and talent spells.
- `item-purchase-warnings`: a class can flag specific items by name family; Warlock grimoires use it.
- `milestones`: the Warlock level 40 target and note.

## Impact

- `DontDoThat/Rules/Data/{Mage,Warlock,Priest,Druid,Shaman,Rogue,Warrior}.lua` (new) and both `.toc` files.
- `DontDoThat/Rules/Schema.lua`: validate `grimoires`.
- `DontDoThat/Intercepts/ItemGuard.lua`: grimoire flagging at vendors.
- `DontDoThat/Data/SpellData.lua`, `tools/build-spell-data.py`: tables for the seven classes.
- `tests/`: a class test per class and a generic coverage test.
- `CLAUDE.md` release rule: new user-visible capability, so 0.7.0 becomes 0.8.0 in both `.toc` files at archive.

# Proposal

## Why

The addon only knows Hunters. Paladins have the same problem (gold is tight until the first mounts) and a few class-specific wrinkles: a cheap level 40 mount, mana-hungry Seal and heal rotation, and utility, PvP and group spells that can wait. Supporting them fully means rule data for their spells and a milestone target that reflects the cheap mount.

## What Changes

- Add Paladin rule data, classifying every Paladin spell family found in the WoW Forever and Classic Era data (including Forever-only spells like Seal of Fury and Holy Strike), with a test that fails on any unclassified spell: Holy, Protection and Retribution specs, rotations (core and situational), tags, reasons and overrides for spells that can wait. Seals, Judgement, Holy Light, Flash of Light and Blessing of Might are kept; utility, PvP and group spells (for example Blessing of Protection, Lay on Hands, Turn Undead, resistance auras) are deferred. Rotations are marked needs-review until sourced.
- Out of scope: Season of Discovery rune abilities (not sold by the class trainer).
- Mark the nine talent-only Paladin spells (Consecration, Divine Favor, Holy Shock, Blessing of Kings, Blessing of Sanctuary, Holy Shield, Seal of Command, Sanctity Aura, Repentance) so they count as part of a rotation only while their talent is active. The list comes from the game's talent tables.
- Bundle Paladin spell data (IDs, ranks, levels) by generalising the spell-data build script, which today is Hunter-only.
- Let a class override the level 40 and level 60 milestone targets. Paladins get a level 40 target of 10 gold (UNVERIFIED placeholder, editable) because the Warhorse needs no separate riding purchase, and keep the default level 60 target.
- Let a class carry a short note on a milestone, shown on the Progress page. Paladins get a joke about the cheap mount.
- Out of scope: Verigan's Fist and weapon advice (the Weapons category already warns), mana water defaults, Paladin-specific profession wording, and any invented rank skips.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `milestones`: a class can override a milestone's targets and add a note shown with it.
- `rule-engine`: Paladin is a supported class with its own rule data.

## Impact

- `DontDoThat/Rules/Data/Paladin.lua` (new), `DontDoThat_*.toc`: load it.
- `DontDoThat/Rules/Schema.lua`: allow `milestones` and `talentSpells` on class data (`talentSpells` already exists).
- `DontDoThat/Model/Milestones.lua`, `Options/Options.lua`: per-class targets and notes in the milestone items, status and progress lines.
- `DontDoThat/Data/SpellData.lua`, `tools/build-spell-data.py`: Paladin tables.
- `tests/`: Paladin rule tests and milestone override tests.
- `CLAUDE.md` release rule: adds a user-visible capability, so 0.6.0 becomes 0.7.0 in both `.toc` files at archive.

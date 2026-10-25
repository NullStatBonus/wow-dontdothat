## 1. Spell data

- [x] 1.1 Generalise `tools/build-spell-data.py` to build a given class (mask and skill lines), excluding the Runes and Engraving lines, send a browser User-Agent when downloading (the default Python one gets HTTP 403 from wago.tools), and confirm the Hunter table is unchanged when regenerated
- [x] 1.2 Generate the Paladin tables into `DontDoThat/Data/SpellData.lua` from the Forever build (Era-only families are classified in the rule data and listed in the coverage test), with Hunter's `costByLevel_class` as an UNVERIFIED proxy and no seen prices

## 2. Rule data

- [x] 2.1 Add `DontDoThat/Rules/Data/Paladin.lua`: specs (tabs 1, 2, 3), rotations (needs review), tags and tier mapping, reasons, overrides, the nine `talentSpells`, a `reviewed` list, and the level 40 milestone override with its note, following the spell plan in `design.md`
- [x] 2.2 Let `Rules/Schema.lua` validate class-level `milestones` (costs as non-negative integers, optional note string) and a `reviewed` string list
- [x] 2.3 Load `Paladin.lua` in both `.toc` files
- [x] 2.4 Add `tests/rules_paladin_test.lua`: core spells kept, each tier represented with a reason, the nine talent spells without their talent, the needs-review flag
- [x] 2.5 Add a coverage test: every distinct spell name in the generated Paladin table is in a rotation, a tag, an override or `reviewed`

## 3. Milestones

- [x] 3.1 Add `Milestones.For(class)` merging class overrides over the defaults
- [x] 3.2 Use the player's class in `Options.MilestoneItems`, `MilestoneProgress` and the status text, and show a milestone's note
- [x] 3.3 Add tests for the Paladin level 40 target and note, Hunter unchanged, progress toward the overridden target, and an edited cost

## 4. Verify and release

- [ ] 4.1 On a Paladin: capture a trainer with `/ddt export` to check which families are sold, prices (including Plate Mail), and that the Warhorse teaches Apprentice Riding; correct the placeholders and the Forever-only rows
- [x] 4.2 At archive, bump `## Version:` to 0.7.0 in both `.toc` files and name it in the commit message

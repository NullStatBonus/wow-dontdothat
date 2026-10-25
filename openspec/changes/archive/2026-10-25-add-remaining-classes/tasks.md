## 1. Groundwork

- [x] 1.1 Generalise `tools/build-spell-data.py` to a per-class configuration for all nine classes (mask, class skill lines, effect prefixes), excluding the Runes, Engraving, Racial and generic skill lines, and confirm the Hunter and Paladin blocks are unchanged when kept
- [x] 1.2 Generate the tables for the seven classes into `DontDoThat/Data/SpellData.lua`, with Hunter's `costByLevel_class` as an UNVERIFIED proxy
- [x] 1.3 Add `tests/rules_classes_test.lua`: for each of the seven classes, every spell family in its bundled table is in a rotation, a tag, an override or `reviewed`, every spec is in tab order, and every rotation is flagged needs-review
- [x] 1.4 Add `tools/class-families.py`, which lists a class's families from the cache with ranks, first level and talent and Forever-only flags, to fill `reviewed` and `talentSpells` without missing any
- [x] 1.5 Let `Rules/Schema.lua` validate `grimoires` (a `keep` string list and a `reason` string)

## 2. Mage

- [x] 2.1 Add `Rules/Data/Mage.lua` following the plan in `design.md`, load it in both `.toc` files, and generate its `reviewed` and `talentSpells`
- [x] 2.2 Add `tests/rules_mage_test.lua`: spec-aware Fireball and Frostbolt, the skipped spells, talent spells, Teleports and Portals

## 3. Warlock

- [x] 3.1 Add `Rules/Data/Warlock.lua` with the level 40 milestone (0 gold, the Felsteed note) and `grimoires`, load it, and generate `reviewed` and `talentSpells`
- [x] 3.2 Flag grimoires in `Intercepts/ItemGuard.lua`: read the item name from the link, match `Grimoire of <family>` for a Warlock, honour the Shopping switch, minimum price and ask-before-buying, and trace the decision
- [x] 3.3 Add `tests/rules_warlock_test.lua` and extend `tests/items_test.lua`: Fear kept at every rank, the skipped curses, grimoires flagged and kept, other classes unaffected, Shopping off, below the minimum, and the milestone target and note

## 4. Priest

- [x] 4.1 Add `Rules/Data/Priest.lua` with `skipRanks` for Psychic Scream {2,3,4}, load it, and generate `reviewed` and `talentSpells`
- [x] 4.2 Add `tests/rules_priest_test.lua`: core and skipped spells, Psychic Scream ranks, Fade deferred whole, talent spells

## 5. Druid

- [x] 5.1 Add `Rules/Data/Druid.lua`, load it, and generate `reviewed` and `talentSpells`
- [x] 5.2 Add `tests/rules_druid_test.lua`: forms and feral spells kept, Wrath, Moonfire and Starfire spec-aware, the skipped utility, talent spells

## 6. Shaman

- [x] 6.1 Add `Rules/Data/Shaman.lua`, load it, and generate `reviewed` and `talentSpells`
- [x] 6.2 Add `tests/rules_shaman_test.lua`: core totems and weapons kept, the redundant totems deferred, Healing Wave and Chain Lightning ranks never skipped, talent spells

## 7. Rogue

- [x] 7.1 Add `Rules/Data/Rogue.lua` with `skipRanks` for Gouge {2,3,4,5} and Kick {2,3,4}, load it, and generate `reviewed` and `talentSpells`
- [x] 7.2 Add `tests/rules_rogue_test.lua`: core and skipped spells, Gouge and Kick rank behaviour, poison families, talent spells

## 8. Warrior

- [x] 8.1 Add `Rules/Data/Warrior.lua` with `skipRanks` for Shield Bash {2,3}, load it, and generate `reviewed` and `talentSpells`
- [x] 8.2 Add `tests/rules_warrior_test.lua`: core and skipped spells, Shield Bash ranks, Demoralizing Shout never skipped, talent spells

## 9. Verify and release

- [ ] 9.1 On each class: capture a trainer with `/ddt export` to check what is sold and its prices, confirm the Felsteed quest teaches Apprentice Riding, and correct the placeholders and Forever-only rows
- [x] 9.2 At archive, bump `## Version:` to 0.8.0 in both `.toc` files and name it in the commit message

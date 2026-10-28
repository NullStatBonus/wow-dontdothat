# Tasks

## 1. Spell identity resolver

- [x] 1.1 Add a resolver in `Model/SpellData.lua` from spell name (as authored in rule files) to family ID, using `SpellTables`; verify with a new test covering ranked families, pet vs class same-name spells, and an unknown name returning nil
- [x] 1.2 Add a localized-name map built from `GetSpellInfo(id)` over `SpellTables` rows, guarded and `pcall`-wrapped per `docs/contracts.md`; verify with a harness fake whose `GetSpellInfo` returns scrambled names and still resolves every row
- [x] 1.3 Add a probe step to `Debug/Probe.lua` that reports whether the Forever trainer exposes a spell ID directly, and whether `GetTalentInfo` can be mapped to a spell ID; verify the probe output appears in `/ddt` debug report in the harness test
- [x] 1.4 Document the identity model (family ID, name map, fallback) in `docs/contracts.md` and verify the doc matches the resolver's API

## 2. Rules by ID

- [x] 2.0 Make every spell the rule files name resolvable: add `tools/build-rule-spells.py` (reads `tools/rule-spell-names.txt`, resolves each name by class through the cached wago tables, skill-line abilities first and talent ranks second) to write `Data/RuleSpells.lua` with the rows the trainer-based tables lack (`kind = "other"`, no cost), have `SpellData.Rows` include them, and let `~Prefix` keys in rule data expand to every family starting with the prefix; verify `SpellData.FamilyId` resolves every name in every `Rules/Data/*.lua` and a new test fails on one that does not

- [x] 2.1 Resolve rule data names to family IDs at load in `Rules/Schema.lua`; verify `tests/rules_schema_test.lua` fails on an unresolved name and names the rule
- [x] 2.2 Switch `Rules/Engine.lua` rotation, tag, override, `why`, `skipRanks` and `talentSpells` lookups to IDs; verify the existing `rules_*_test.lua` suites pass unchanged in expected verdicts
- [x] 2.3 Replace the `Apprentice` regex in `Rules.MatchProfessionLearn` with apprentice spell IDs mapped to profession keys; verify `tests/profession_learn_test.lua` passes with scrambled client names
- [x] 2.4 Map active talents to IDs in `Intercepts/Adapter.lua` and `Model/PlayerProfile.lua` (per the 1.3 probe result); verify `tests/model_profile_test.lua` with a non-English talent name
- [x] 2.5 Route trainer rows in `Intercepts/Trainer.lua` through the name map and the digits of the rank text; verify `tests/trainer_overlay_test.lua` gives identical verdicts on a scrambled-name client
- [x] 2.6 Switch the other readers of rule data and spell names to family IDs, using `SpellData.DisplayName` for any text shown: `Model/Savings.lua`, `Model/Tally.lua`, `Model/Ledger.lua` (cost key), `Model/Icons.lua`, `Model/Milestones.lua`, `Intercepts/Context.lua`, `Debug/Probe.lua`; update the tests that build profiles and actions with a `fid(class, name)` helper; verify `lua tests/run.lua` passes
- [x] 2.7 Update `docs/rules-data.md` and the generators in `tools/scaffold_class_rules.py` for the name-then-resolve authoring; verify a regenerated class file passes `tests/rules_classes_test.lua`

## 3. Settings by ID

- [x] 3.1 Key every saved spell store by family ID with no conversion: `ruleOff.abilities`, `professionAsked` (profession keys), `db.global.icons` and `db.char.costCache`; verify with tests that a store round-trips by ID and that an old name-keyed entry is ignored without error
- [x] 3.2 Switch `Options/Options.lua` (rules page lists, groups and toggles by family ID, shown with `DisplayName`) and `Model/Settings.lua` readers to ID keys; verify `tests/settings_test.lua` and `tests/options_test.lua` pass and a toggle survives a scrambled-name client
- [x] 3.3 Note in `docs/test-plan.md` a manual check that a toggle survives a client language change, and verify the test plan lists it

## 4. Locale table

- [x] 4.1 Add `Locales/enUS.lua` and an `ns.L` table whose `__index` returns the key, loaded before UI code in both TOCs; verify `tools/check-toc.sh` and `tools/check-tocs-match.sh` pass and a test shows a missing key returns itself
- [x] 4.2 Wrap player-facing text in `UI/` and `Intercepts/` in `L[...]` as whole-sentence keys, replacing concatenated fragments; verify `tests/alert_test.lua` and `tests/trainer_confirm_test.lua` produce the same English text
- [x] 4.3 Wrap text in `Options/Options.lua`, `Core/Slash.lua` and `Model/` (Milestones, Savings) the same way; verify `tests/options_test.lua` output is unchanged in English
- [x] 4.4 Add a locale test that fails on a translation key the source never uses and on a placeholder count mismatch, using a fixture locale; verify it fails on a deliberately broken fixture and passes on a good one
- [x] 4.5 Write `docs/localization.md` for contributors and link it from `CONTRIBUTING.md` and the README (English-client note for item names); verify the documented steps add a fixture locale that the test accepts

## 5. Integration

- [x] 5.1 Run `lua tests/run.lua` and `tools/check-version.sh` and verify everything passes
- [x] 5.2 In-game check on a Classic Era client in English: trainer marks, a rank skip, a profession lesson and a saved toggle behave as before; record the result in `docs/test-plan.md`

## 6. Everything else by ID

- [x] 6.1 Recognise talents by the ID in their hyperlink: `tools/build-talent-data.py` writes `Data/TalentData.lua` (talent ID to rank spell IDs) and `Adapter.ReadActiveTalents` maps it to spell families, falling back to the name only when there is no link; verify tests with scrambled talent names and with no link
- [x] 6.2 Match Warlock grimoires by item ID: a generator writes the grimoire item IDs and their families from the game's item tables, `ItemGuard` reads the ID with `GetItemInfoInstant`, and the English `Grimoire of` pattern goes; verify `tests/grimoires_test.lua` passes with an item whose name is in another language
- [x] 6.5 Run `/ddt trainerids` in game; a method gave an ID that matches the row (the trainer tooltip), so trainer rows read it and keep the name map as a fallback; verified with a harness test where the client offers no name lookup at all
- [x] 6.3 Identify trainers in the tally by `UnitGUID("npc")` instead of the localized NPC name; verify the tally tests with two trainers that share a name
- [x] 6.4 Update `docs/rules-data.md`, `docs/localization.md` and the README so they no longer say item names need an English client; verify no doc still says so

- [x] 6.6 Track tally rows for spells outside the bundled tables by the trainer tooltip's spell ID, not the name; verify with a tally test where the same spell appears under another name
- [x] 6.7 Add identity checks to `/ddt trainerids` (talent links, riding spell IDs, profession apprentice spells, the open trainer window and craft rows) and fix the stale shapes in `docs/contracts.md`; verify with probe tests and by reading the report in game

- [x] 6.8 Recognise Era riding by the racial passive spell IDs alongside Forever's Apprentice/Journeyman Riding, as found by the in-game run; verify with a test per racial spell and a riding spec delta

- [x] 6.9 Check the other classes offline: give every rule-named talent spell all its IDs (`tools/rule-spell-names.txt` now lists them, the generator keeps every ID across skill lines, talents and both builds) and add Paladin/Warlock class mounts to riding; verify with a test that every talent-granted rule spell is reachable from a talent link for all nine classes
- [x] 6.11 Read Era level 60 riding from the racial riding skill's max rank (150), found by the client's name for the racial spell; verify with a test of ranks 75 and 150 in a renamed client
- [ ] 6.10 Repeat `/ddt trainerids` in game on a non-Hunter with talent points (a Paladin or Warlock with the class mounts if possible); verify the identity checks show talents "with points" resolving and the class mount IDs known

## Workflow follow-up

- On archive, bump `## Version:` in both TOCs to the next minor (new capability), add the entry to `CHANGELOG.md` in the same commit and name the version in the commit message.
- Item names (vendor item families) are also matched by English name and are not covered here; follow up separately.

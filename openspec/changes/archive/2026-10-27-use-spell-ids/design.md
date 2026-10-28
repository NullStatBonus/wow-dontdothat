# Design

## Context

Rules, verdict keys and `off.abilities[class][name]` use English spell names. The client hands the addon localized names from `GetTrainerServiceInfo`, `GetTalentInfo` and `GetSkillLineInfo`. `SpellTables` already holds `{ id, name, rank, level, kind }` per class, with `SpellData.Ids` and `SpellData.Rank` for lookups. `Adapter.parseRank` already reads `(%d+)`, so ranks are locale-safe. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Identity by family ID inside the engine and settings.
- Rule authoring stays readable (names in source).
- Locale tables so a contributor adds one file.

**Non-Goals:**
- Shipping a second language.
- Rewriting rule files as numeric literals.
- Translating the debug log.

## Decisions

```
client (localized)            load/boundary                 inside
GetTrainerServiceInfo  --->   name map from GetSpellInfo    family ID
GetTalentInfo          --->   (built once from SpellTables) --> Engine, Settings
GetSkillLineInfo       --->   apprentice spell IDs          profession key
rule files (English)   --->   resolve via SpellTables       family ID
```

1. **Names in source, IDs at load.** Rule files keep `"Arcane Intellect"`; a resolver turns each into a family ID and a test fails on any miss. Alternative: numeric literals in rule files. Rejected as unreadable and it breaks `tools/scaffold_class_rules.py` output.
2. **Family ID.** The ID of the lowest-rank row of a family, so ranks group and same-named spells from different classes or pets do not collide. Alternative: the name, which is the current bug.
3. **Trainer rows by the tooltip's spell ID, name map as fallback.** The trainer API returns only a name, but the tooltip knows the spell: `tooltip:SetTrainerService(i)` then `tooltip:GetSpell()` returns the spell ID (confirmed in game with `/ddt trainerids` on a Warrior trainer; `GetTrainerServiceInfo`, the item link and the other calls give nothing). The adapter caches it by row name and rank text. The name map from `GetSpellInfo`, built once per class (plus pet spells), is the fallback when the tooltip gives nothing.
15. **Findings from the in-game `/ddt trainerids` runs (Classic Era, Hunter and Alchemy trainers).** The tooltip's spell ID works for class rows, Pet Trainer rows (which use the ordinary trainer window, not the craft window) and a profession's first lesson (the row is titled "Apprentice Alchemist", its tooltip spell is Alchemy, 2259). Profession recipe rows give no spell ID (the tooltip holds an item name only), so tally rows for them stay keyed by name; nothing evaluates them. Talent hyperlinks are `|Htalent:<id>:<rank>|h` and every talent ID is in the generated table. Apprentice and Journeyman Riding do not exist on Era: riding there is the racial passive of the mount (Horse Riding 824, Wolf 825, Ram 826, Tiger 828, Raptor 10861, Kodo 18995, Undead Horsemanship 10906, Mechanostrider 10907, each with a skill line of the same name), and level 60 riding is the same skill at max rank 150, which no spell ID shows. The adapter finds that skill line through the client's own name for the racial spell and reads its max rank.
16. **All in-game runs so far were on a Hunter with no talent points.** Checked offline for the other classes: every one of the 105 talent-granted spells the rules name is reachable from a talent hyperlink once the spell tables include a talent's own rank spells (Holy Shock 20473, Era's Feral Charge 16979 and Tactical Mastery 12295 were missing, which would have judged a player with those talents as without them); a test guards it. Class mounts (Summon Warhorse 13819, Charger 23214, Felsteed 5784, Dreadsteed 23161) count as riding on both clients.
4. **Professions by apprentice spell ID.** `GetSkillLineInfo` returns no spell ID, so a profession is identified by the spell ID of its apprentice tier (Cooking is 2550). The adapter maps the client's name for that spell, or for a skill line, to the ID, and the engine, `professionAsked` and the known-profession set are all keyed by it. The rule data keeps authoring English names (`apprentice = { Cooking = 2550 }`); the English name only serves a client that names nothing and the skill lines whose name differs from the spell's.
5. **No settings migration.** Nobody uses the addon yet, so every name-keyed saved store (`ruleOff.abilities`, `professionAsked`, `db.global.icons`, `db.char.costCache`) simply switches to ID keys. Old name-keyed entries are never matched and age out. Alternative: a versioned conversion with a `legacy` bucket, rejected as dead code.
6. **Locale table.** `ns.L` with a metatable whose `__index` returns the key, so a missing translation shows English and never errors. One file per locale under `Locales/`, loaded before UI code. Alternative: AceLocale-3.0, rejected as a new dependency for no gain; revisit if the CurseForge localization tool is wanted.
7. **Whole-sentence keys.** Sentences with `%s`/`%d` are one key each; fragment concatenation (`"Costs about " .. x`) is replaced so word order can differ. Positional formats where a sentence has several arguments.
8. **Guard test.** Fails on a locale key the source never uses, and on a mismatched count of format specifiers between a key and its translation.

9. **One mechanical pass for consumers.** `Rules.Load` produces ID-keyed tables and every reader (Options, Savings, Tally, Ledger, Icons, Context, Milestones) takes IDs and asks `SpellData.DisplayName` for text. Tests build names through a `fid(class, name)` helper. Alternative: dual name and ID keys while classes switch over. Rejected: two identity models would stay alive until the end.
10. **Stable IDs.** `FamilyOfId` accepts any ID a family has listed, so an ID stays valid when the spell tables are regenerated.
11. **Rule-only spells.** Rule files name spells the trainer tables lack (talent-granted, default attacks, conjured items) and use Classic Era names where the Forever tables use others (Curse of Agony / Bane of Agony, same ID). `tools/build-rule-spells.py` resolves `tools/rule-spell-names.txt` against both builds into `Data/RuleSpells.lua`. A row whose ID the tables already hold becomes another name for that family; any other row joins or starts a family. `~Prefix` keys expand to every family starting with the prefix. Separate from `Data/SpellData.lua` so regenerating it needs no trainer export.

12. **Talents by hyperlink ID.** `GetTalentLink` carries the talent's database ID, which `Data/TalentData.lua` (generated from the Talent table, identical in Era and Forever) maps to its rank spell IDs. The name map stays only as a fallback for a client without links.
13. **Grimoires by item ID.** A generator writes the grimoire item IDs and the ability each teaches, from the game's item tables; rule data keeps authoring the ability names to keep. `ItemGuard` reads the item ID, not the item name.
14. **Trainers by GUID.** The tally identifies a trainer by `UnitGUID("npc")`, which is language-proof and unique, instead of its localized name.

## Risks / Trade-offs

- [Name map misses a spell the client names differently from the table] → the test cannot see client names; log unmatched trainer rows to the debug report.
- [Large diff across rule files and tests] → resolver is additive first, rules switch over class by class.

## Migration Plan

None for saved data (no existing users). `Data/RuleSpells.lua` is regenerated with `tools/build-rule-spells.py` when a rule file names a new spell.

## Open Questions

- Does Forever expose a spell ID from the trainer directly? Settled by the probe.
- Do talent-gated rules key on the talent's own ID or the spell it grants? Decide when writing the specs.

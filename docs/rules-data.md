# Rule data schema

Rule data files live in `DontDoThat/Rules/Data/` and call `ns.Rules.Load(table)`. `Load` validates the table and raises a message beginning `DontDoThat rule data (<id>): ...` on malformed data. Money is integer copper. Anything unverified is commented in the data file.

## Spell names and IDs

Rule files are written with English spell names (the Classic Era names, which the Forever tables sometimes rename: Curse of Agony is Bane of Agony). `ns.Rules.Load` compiles every name to a spell family ID (`SpellData.FamilyId`, see `docs/contracts.md`), and the engine, the settings and the Rules page work in IDs only. Anywhere the table below says "name" it means this.

- A name that matches no spell raises `DontDoThat rule data (<class> <field>): no spell named '<name>' for this class`, and `tests/spell_ids_test.lua` fails on it.
- A key or list entry written `~Prefix` stands for every family whose name starts with the prefix (`~Create Firestone` covers Lesser, normal, Greater and Major). It must match at least one.
- Professions (`ProfessionLearn.lua`) are identified by the spell ID of their apprentice tier, for example Cooking = 2550. `gathering` lists the ones that are never asked about and must also appear in `apprentice`.
- The trainer-based tables (`Data/SpellData.lua`) do not list talent-granted spells, default attacks or conjured items. Add such a name to `tools/rule-spell-names.txt` (`CLASS<TAB>Name`) and run `python3 -I tools/build-rule-spells.py` to write `Data/RuleSpells.lua`. It looks the name up in the Classic Era and Forever tables, so it needs the cached wago CSVs in `tools/.cache`.
- The Warlock `grimoires.keep` list names demon abilities, not items. A grimoire is recognised by its item ID (the number in its item link), and `Data/RuleItems.lua` maps each grimoire item ID to its ability. Regenerate it with `python3 -I tools/build-rule-items.py`, which downloads the item tables into `tools/.cache/items`. `tests/grimoires_test.lua` fails on a kept name that no grimoire has.

## Class data (`class = "HUNTER"`)

| Field | Meaning |
|---|---|
| `specs[KEY]` | `{ name, rotation = { core = {names}, situational = {names}, needsReview = bool } }`. `needsReview` marks thinly sourced rotations; the Rules page must label them. |
| `tagTiers` | Tag to default tier, e.g. `PvP = "deferLow"`, `RaidGroup = "defer"`. Tiers: `keep`, `info`, `deferLow`, `defer`. |
| `tags` | Ability name to list of tags. Every tag must exist in `tagTiers`. The most severe tier wins. |
| `overrides` | Ability name to tier. Beats everything else. |
| `ranks[family]` | List of rows `{ rank, unlockLevel, cost = copper|nil, manaCost = n|nil }`, ranks consecutive from 1, `unlockLevel` non-decreasing. `cost` nil means unknown; a non-nil data cost is reported as an estimate. |
| `abilityLevels` | Optional ability name to trainer level (informational). |
| `supersessionWindow` | Optional number; replaces the default window of 4 levels. |

## Evaluation order

Rules apply only while `profile.milestone.state == "active"`. Then: override, rotation (core in any plausible spec keeps; situational is `info`), tags, ability that belongs only to a non-plausible spec (`deferLow`, reason names the spec and tree split), rank supersession (next rank within the window), keep. Empty or missing `plausibleSpecs` means every spec is plausible.

## Load order

`Rules/Schema.lua`, `Rules/Engine.lua`, then the data files.

# Rule data schema

Rule data files live in `DontDoThat/Rules/Data/` and call `ns.Rules.Load(table)`. `Load` validates the table and raises a message beginning `DontDoThat rule data (<id>): ...` on malformed data. Money is integer copper. Anything unverified is commented in the data file.

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

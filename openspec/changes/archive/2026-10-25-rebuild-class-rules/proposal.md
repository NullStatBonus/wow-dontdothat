# Proposal

## Why

The classes added in v0.8.0 are barely visible on the Rules page and partly wrong. Worth buying is empty for Mage, Druid, Priest and Warlock because the page reads only `overrides` and ignores the rotation lists that hold their core spells. Situational spells appear in no list. Ranks to skip is empty for most classes. And the tiers followed a short brief literally, so spells leveling builds rely on (Smite, Thunder Clap, Hamstring, Scorch, Entangling Roots, Evasion) sit in "not worth buying". Players cannot trust or check what the addon says.

## What Changes

- Rules page: Worth buying and a new Optional list, each grouped by spec (All specs, then each spec); Save your gold, Not worth buying yet and Ranks to skip as now; a collapsed "Not a purchase" list for passives and effects. Every spell family in a class's rule data or bundled table appears in at least one list, for all nine classes including Hunter and Paladin.
- Re-assess every class from common leveling builds (Frost or Fire mage, Affliction/Demonology warlock, Smite-and-wand then Shadow priest, Feral druid with Balance utility, Enhancement then Elemental shaman, Combat/Assassination rogue, Arms warrior). A spell the brief called skippable stays kept for the specs that use it and only waits for the specs that do not.
- Rank skips come only from expert leveling guides (Wowhead's "Spells to Buy" guides), not from any computed rule: a rank whose level a guide's training list omits, or that is above a rank limit it states, is skipped. The earlier computed rule is dropped. Hunter's current list is kept pending the user's choice, since the guides disagree with two of its entries.
- Remove the level-gap feature ("skip a rank when a better one comes within N levels"): its engine rule, the Advanced > Tuning slider, the "Skip ranks a better one replaces soon" switch, and its requirements. The "Skip ranks that are a small upgrade" switch stays as the one on/off for ranks to skip.
- Bring the class-plan scaffolding into `tools/` so the plans and the skip lists can be reviewed and regenerated.
- Projected savings: a Progress section showing what following the advice keeps up to the stop-after mount (per spec and settings), a per-spec level 40 and level 60 overview on each class page, and a gold value under every switch that changes what is flagged. Prices come from Wowhead's Classic trainer lists (`Data/TrainerPrices.lua`, written by `tools/fetch-trainer-prices.py`), with prices seen at the player's trainers taking precedence.
- Settings layout: every list is grouped (a Pet group for skills a Pet Trainer teaches; Auto Shot left off); profession switches move to What to watch; Advanced is flattened to Sound & messages, Tuning, Classes and Debug; one spacing rule in the page builder.
- Out of scope: trainer stock and prices confirmed at a real trainer, new warnings, and the item rules.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: grouped class lists with a Pet group, a class overview and gold values on switches, projected savings on Progress, profession switches on What to watch, a flatter Advanced, consistent page layout, and the Tuning rank window removed.
- `rule-engine`: rank skips from expert guides only, the level-gap rule removed, resurrections and interrupts always worth buying, unverified spells optional, and assessment by leveling builds.

## Impact

- `DontDoThat/Options/Options.lua`: `ClassSummary`, the class pages, Progress and the page builder; `DontDoThat/Model/Savings.lua`, `Data/TrainerPrices.lua` and `tools/fetch-trainer-prices.py` (new).
- `DontDoThat/Rules/Data/*.lua`: rotations, tags and `skipRanks` for the eight classes except Hunter's skips.
- `tools/scaffold_class_rules.py` and `tools/class_plans/` (new); `DontDoThat/Rules/Engine.lua`, `Schema.lua`, `Model/Settings.lua`, `Model/Ledger.lua`, `Model/SpellData.lua`, `Intercepts/Adapter.lua` and `Trainer.lua` lose the level-gap logic.
- `tests/`: coverage over all nine classes, per-class assertions updated, rank-rule tests.
- `CLAUDE.md` release rule: new user-visible lists and rank guidance for every class, so 0.8.1 becomes 0.9.0 in both `.toc` files at archive.

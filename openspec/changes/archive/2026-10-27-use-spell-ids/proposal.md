# Proposal

## Why

The rule engine compares localized client strings (trainer rows, talents, professions) to English spell names, so on any non-English client no advice fires. Spell IDs already ship in `SpellTables`, so identity should rest on them. Contributors are welcome to add languages, which needs the UI text routed through a locale table first.

## What Changes

- Rule files keep authoring spell names, but a load step resolves each to a family ID through `SpellTables`. The engine, the verdicts and the settings work in IDs.
- Trainer rows are mapped to IDs through a `GetSpellInfo`-built name map, with the rank taken from the digits of the subtext. Talents and professions get the same treatment, and the English `Apprentice` regex goes.
- A test fails on any rule name that does not resolve, and the harness fakes a scrambled-name client to prove nothing depends on English.
- Saved spell switches, asked-about professions, remembered icons and observed prices are keyed by family ID. Nobody has saved data yet, so there is no conversion: an old name-keyed entry is simply never matched.
- Talents are recognised by the ID in their hyperlink, Warlock grimoires by item ID, and tally trainers by GUID, so no game text is compared with English anywhere.
- User-facing text goes through `ns.L` (English-as-key, `__index` falls back to the key) with enUS as the only shipped locale, plus a contributor guide and a test that rejects stale keys and mismatched format specifiers. Debug log text stays English.

## Capabilities

### New Capabilities
- `localization`: UI text is looked up through a locale table, falls back to English, and a locale file can be added without touching code.

### Modified Capabilities
- `rule-engine`: spells are identified by family ID, not by English name.
- `addon-settings`: saved ability toggles are keyed by family ID.
- `milestones`: riding is recognised by spell ID, including the Classic Era racial riding passives.
- `item-purchase-warnings`: class item families (Warlock grimoires) are recognised by item ID, not by name.

Which other specs change (purchase-warnings, spec-inference, item-purchase-warnings) is decided when the specs artifact is written.

## Impact

- Code: `Rules/Engine.lua`, `Rules/Data/*`, `Model/SpellData.lua`, `Model/Settings.lua`, `Intercepts/Adapter.lua`, `Intercepts/Trainer.lua`, `Options/Options.lua`, the UI and intercept text, `tools/` rule generators, the test harness.
- Saved variables: keys change from names to IDs; no migration (no existing users).
- No new library dependency.
- Release: behavior change plus a new capability, so a minor bump per CLAUDE.md.
- Out of scope: shipping any non-English locale, translating spell names (the client already does), and translating debug output.

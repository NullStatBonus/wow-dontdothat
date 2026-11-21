# Proposal

## Why

"Reset all settings" deletes the keys from the live profile, expecting AceDB's defaults to show through. AceDB copies plain defaults into the profile once, at load, and sets no fallback, so after the reset those keys stay nil until the next `/reload` or login. Missing `itemModes` read as "off" and missing `minPrice` as 0: every vendor and auction warning stops, and What to watch shows every category as Off. The 2026-11-20 bug review found this three times (two Claude reviews and Codex), and two reproduced it with the bundled AceDB. The player's saved variables confirm the mechanism: default values are absent on disk and only appear after load.

## What Changes

- Reset all settings puts each cleared setting back to its default value in the live profile at once, so warnings, What to watch and every other page use the defaults without a reload. What it keeps (tally, professions asked, mount marks, revision notice, style marker) stays as it is.
- After a reset the options pages are built again, so the Classes page shows the default skip revision's list instead of the one picked before the reset.
- Logout still saves only changed values (AceDB strips the restored defaults as usual).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: requirement "Reset all settings" gains scenarios for warnings working at once after a reset and for the Classes page following the default revision.

## Impact

- `DontDoThat/Model/Settings.lua` (`ResetAll`), `DontDoThat/Options/Options.lua` (the Reset all button handler).
- Tests: `tests/settings_test.lua`, a real-AceDB test in `tests/warning_style_test.lua` (it already logs in with the bundled AceDB).
- `docs/test-plan.md`: an in-game check that warnings work right after a reset.
- Patch release 0.13.4. No saved-data shape change.

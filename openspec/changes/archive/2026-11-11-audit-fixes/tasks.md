# Tasks

## 1. Per-character state

- [x] 1.1 Save `professionAsked` and `milestoneOverride` in `db.char`; read and write them there
- [x] 1.2 `Settings.MigrateCharState` copies the shared values once per character; Reset all keeps the profile copies
- [x] 1.3 Add the Character section to the debug export
- [x] 1.4 Tests: migration, per-character writes, reset keeps answers

## 2. Correctness

- [x] 2.1 Item alerts pass the chosen sound channel
- [x] 2.2 Spellbook "not learned" stays false in `SpellData.Services`
- [x] 2.3 Re-apply the auction house wrappers on `AUCTION_HOUSE_SHOW`, with diagnostics
- [x] 2.4 Tests for 2.1 to 2.3 and for the auction wrappers

## 3. Efficiency

- [x] 3.1 One trainer compute per `SafeRefresh` pass
- [x] 3.2 Tally and Milestones pages share the cached answer; a setting change clears it
- [x] 3.3 Sorted spec keys once per rules table; no per-row closure; tier list only with debug on

## 4. Cleanup

- [x] 4.1 `Intercepts/Prompt.lua` (both TOCs) with the shared alert settings, sound-only copy, banner fallback and chat notice
- [x] 4.2 Remove dead reset code and unused `Log.Enable` and `Log.Disable`; pass `env` to `textObject`
- [x] 4.3 Correct the stale `reportText` pointer in CLAUDE.md

## 5. Docs and release

- [x] 5.1 `docs/test-plan.md`: per-character state, auction window re-check
- [x] 5.2 Bump both TOCs to 0.11.2 and write the CHANGELOG section at archive

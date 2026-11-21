# Tasks

## 1. Reset restores defaults

- [x] 1.1 In `DontDoThat/Model/Settings.lua`, make `ResetAll(p, defaults)` copy (deep) every default profile value whose key is now nil, with `defaults` falling back to `ns.defaults.profile`; keep `KEEP_ON_RESET` keys and the debug switch-off as they are. Verify with `tests/settings_test.lua`: the existing "reset all" test passes with defaults given (cleared keys come back with default values, kept keys unchanged), a restored table is not the defaults table itself, and nil defaults still clears without error.
- [x] 1.2 Extend the real-AceDB tests in `tests/warning_style_test.lua`: after `ResetAll(ns.db.profile)`, `itemModes.armor == "both"`, `minPrice == 100`, `ItemWarning.Flagged` flags a 200-copper vendor armor buy, `styleMarked` and `professionAsked` kept; after logout the saved profile has no `itemModes` or `minPrice`; after relog the defaults still read. Mutation-check: with the copy removed, the new assertions fail.

## 2. Options page

- [x] 2.1 In `DontDoThat/Options/Options.lua`, have the Reset all button call `Options.Rebuild()` instead of `Options.Refresh()`; verify by reading the handler and with any options test that covers the button (add one assertion if a test drives it).
- [x] 2.2 Add to `docs/test-plan.md` one check, verified from saved variables: Reset all settings, buy armor over 1 silver at a vendor and answer No; `itemsAvoided` goes up and the profile holds no `itemModes` or `minPrice`. Verify section numbers stay unique and in order.
- [x] 2.3 Have the Reset all button also call `Toast.ResetPosition()` (ends a Move in progress, re-anchors the warning), so Done after a reset cannot save the old position again (found by the Codex check of this fix); verify with the Home reset test in `tests/options_test.lua` (the call happens once).

## 3. Integration checks

- [x] 3.1 Run `make test`, `make check` and `openspec validate reset-restores-defaults --strict`; verify all pass.

## Workflow follow-up

- Archive with `/opsx:archive`; bump both TOCs to 0.13.4; CHANGELOG line in ASD-STE100, for example "Fixed: After Reset all settings, the addon warns about purchases again at once. Before, warnings stopped until you reloaded."
- Commit, PR, tag `v0.13.4` on the merge commit.

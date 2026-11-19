# Tasks

## 1. Update the embedded Ace3 libraries

- [x] 1.1 Download the WoWUIDev/Ace3 tarball at commit ac3d122 into a scratch directory; verify the commit hash in the archive and that it contains every module under `DontDoThat/Libs`.
- [x] 1.2 Replace every Lua and XML file under `DontDoThat/Libs` (LibStub, CallbackHandler-1.0, AceAddon-3.0, AceDB-3.0, AceHook-3.0, AceEvent-3.0, AceConsole-3.0, AceConfig-3.0 with Registry/Cmd/Dialog, AceGUI-3.0 and widgets) with the ac3d122 copies, same module set; verify the file list matches upstream for those modules (`diff` of sorted lists) and `bash tools/check-embeds.sh` passes.
- [x] 1.3 Hash-compare (`shasum -a 256`) every file under `DontDoThat/Libs` against the ac3d122 tarball and every shared file against `../wow-closest-vendor/ClosestVendor/Libs`; verify all are identical, and that `LICENSE-Ace3.txt` content equals Closest Vendor's `LICENSE.txt`.
- [x] 1.4 Record MAJOR/MINOR from the `NewLibrary` (or LibStub) call of every bundled module and widget, for use in 1.6; verify the known values: AceDB-3.0 40, AceConfigDialog-3.0 93, AceConfigRegistry-3.0 22, AceGUI-3.0 41, ColorPicker 29, Heading 21, Icon 22, Label 29, CallbackHandler-1.0 8, LibStub 2.
- [x] 1.5 Add the globals AceDB 40 needs (`UnitNameUnmodified`, `strlenutf8`, and `RegionalUniqueNamesEnabled` returning false) to the stubs and cleanup list in `tests/warning_style_test.lua`; verify `make test` passes with the new libraries (`tests/options_ace_test.lua` loads only LibStub, CallbackHandler and AceConfigRegistry, so it needs no stub).
- [x] 1.6 Rewrite `DontDoThat/Libs/VERSIONS.txt` in the shared provenance format (upstream URL, full ac3d122 commit and retrieval date, one line per module with MAJOR and MINOR, license file `LICENSE-Ace3.txt`, local patches: none, update steps); keep `LICENSE-Ace3.txt`; verify every MINOR listed matches task 1.4.
- [x] 1.7 Grep `README.md`, `docs/` and `tools/` for `r1403` and `d295b12`; verify no stale reference remains.

## 2. Character-key migration

- [x] 2.1 Add `Adapter.ReadLegacyCharKey(env)` in `DontDoThat/Intercepts/Adapter.lua` (via `call`; nil when `UnitName` or `GetRealmName` is missing or not a string) with tests; verify the tests fail when the guard is removed.
- [x] 2.2 Add `Settings.MigrateCharKey(sv, db, oldKey)` in `DontDoThat/Model/Settings.lua` per design decision 4 (move `sv.char[old]` only when `sv.char[new]` is nil; `SetProfile` in pcall when `sv.profileKeys[old]` differs from the current profile; clear `sv.profileKeys[old]`); verify with pure tests in a new `tests/char_key_migration_test.lua`: data moved, second run no-op, profile picked after the move survives, keys equal untouched, data under the new key not overwritten, nil old key skipped, fresh install (`sv.char` nil, keys differ) raises no error and moves nothing.
- [x] 2.3 Call it in `addon:OnInitialize` right after `AceDB:New` and before `ClassifyStyle`, with `self.db.sv` and `ns.Adapter.ReadLegacyCharKey(_G)`; verify nothing reads `db.char` before the call.
- [x] 2.4 Add end-to-end tests in `tests/char_key_migration_test.lua` that load the real bundled AceDB 40 with a Forever-shaped fake client (`RegionalUniqueNamesEnabled` true, `C_GameRules`, `Enum.GameRule`, `UnitNameUnmodified` with surname) and saved data under `Name - Realm`; verify `db.char.ledger`, `db.char.costCache` and the profile choice survive, a second load changes nothing, an Era-shaped client is untouched, and a fresh Forever install with an empty `DontDoThatDB` loads without error.
- [x] 2.5 Mutation-check the migration tests: break the move, the clear of `profileKeys[old]`, the equal-keys guard, the no-overwrite guard and the nil-`sv.char` guard one at a time; verify a test fails for each, then restore.
- [x] 2.6 Add a `docs/test-plan.md` section `## 21. Settings library update` (20 went to the mount fund line) (manual checks from group 3.3) and remove "The libraries that the game loaded" from "Not covered yet" if the section covers it; verify section numbers stay unique and in order.

## 3. Integration checks

- [x] 3.1 Run `make test` and `make check`; verify both pass.
- [x] 3.2 Run `openspec validate align-ace3-acedb-migration --strict`; verify it passes.
- [x] 3.3 Manual smoke on Classic Era and WoW Forever with Don't Do That, Closest Vendor and KeepThat all loaded: open each addon's settings window, `/reload`, visit a merchant; on Forever, use a character with existing savings and a non-default profile and verify Progress and the profile are unchanged after the update; verify no Lua errors.

## Workflow follow-up

- At archive (`/opsx:archive`): bump `## Version:` in both `DontDoThat/DontDoThat_Vanilla.toc` and `DontDoThat/DontDoThat_Camelot.toc` to 0.13.1.
- At archive: add the `## X.Y.Z` section to `CHANGELOG.md` in ASD-STE100 style, two lines, for example "Fixed: On WoW Forever, color pickers in other addons show the correct transparency. Before, they showed the opposite value." (wording to confirm: Don't Do That has no color picker of its own; the fix reaches other loaded addons only when this copy of the library is the newest one loaded) and "Fixed: On WoW Forever, each character keeps its savings and profile after the library update."
- Commit the archive, version and code together, naming the version; tag `vX.Y.Z` and push the tag per `docs/publishing.md`.

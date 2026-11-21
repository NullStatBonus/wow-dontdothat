# Tasks

## 1. Candidate keys

- [x] 1.1 Add `Adapter.ReadCharKeys(env)` in `DontDoThat/Intercepts/Adapter.lua` (first entry from `ReadLegacyCharKey`; `Name Surname` only when `RegionalUniqueNamesEnabled` is true and `UnitNameUnmodified` gives a non-empty name and surname); verify with tests in `tests/char_key_migration_test.lua`: Forever gives both keys, Era (no surname or the function false or missing) gives one, missing `UnitName` gives an empty list, an erroring call gives no error.
- [x] 1.2 In `addon:OnInitialize` (`DontDoThat/Core/Addon.lua`), replace the single call with one `MigrateCharKey` call per candidate (via `Settings.MigrateCharKeys`), each in pcall, still right after `AceDB:New` and before `ClassifyStyle`; verify by reading the order in the file and with the tests in 2.1.

## 2. End-to-end tests and docs

- [x] 2.1 Extend the real-AceDB tests in `tests/char_key_migration_test.lua` to log in the way `OnInitialize` now does (all candidates): downgrade (AceDB loaded with `RegionalUniqueNamesEnabled` missing, data under `Name Surname`) restores ledger, costCache and profile; then an upgrade moves it forward again with nothing left under `Name - Realm`; Era untouched; both keys populated leaves both; existing forward, second-login and fresh-install tests still pass.
- [x] 2.2 Mutation-check: drop the Forever key from `ReadCharKeys`, drop the surname guard, and call only the first candidate in the login; verify a test fails for each, then restore.
- [x] 2.3 Add to `docs/test-plan.md` section 21: on WoW Forever, disable every addon that ships AceDB 40 (Closest Vendor, KeepThat), `/reload`, and check Progress and the profile are unchanged; enable them again, `/reload`, check again. Verify section numbers stay unique and in order.

## 3. Integration checks

- [x] 3.1 Run `make test`, `make check` and `openspec validate reverse-char-key-migration --strict`; verify all pass.

## Workflow follow-up

- Archive with `/opsx:archive`; bump both TOCs to 0.13.2; CHANGELOG line in ASD-STE100, for example "Fixed: On WoW Forever, a character keeps its savings and profile when you remove an addon with a newer settings library."
- Commit, PR with "Closes #38", tag `v0.13.2` on the merge commit.

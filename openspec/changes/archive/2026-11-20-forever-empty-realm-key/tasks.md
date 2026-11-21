# Tasks

## 1. Reader

- [x] 1.1 In `DontDoThat/Intercepts/Adapter.lua`, make `ReadLegacyCharKey` accept an empty-string realm (nil only for a missing or empty name, a non-string realm, or an error), and update its comment; verify with the adapter tests in `tests/char_key_migration_test.lua`: `""` realm gives `"Hero - "`, nil realm gives nil, and `ReadCharKeys` on Forever with `""` gives both `"Hero - "` and `"Hero Surname"`.

## 2. End-to-end tests and docs

- [x] 2.1 Let the real-AceDB `login` helper in `tests/char_key_migration_test.lua` take the realm name; add tests with `GetRealmName` returning `""`: data and profile saved under `"Hero - "` reach `"Hero Surname"` under AceDB 40 with nothing left behind, a second login changes nothing, and the older-library downgrade brings them back to `"Hero - "`. Verify each new test fails with the 0.13.2 reader (mutation check), then passes.
- [x] 2.2 In `docs/test-plan.md` section 21, note that on Forever the old key is `Name - ` (empty realm), and add a check: with a save from 0.13.0 or earlier and no other addon that ships AceDB 40, Progress keeps its savings after updating. Verify section numbers stay unique and in order.

## 3. Integration checks

- [x] 3.1 Run `make test`, `make check` and `openspec validate forever-empty-realm-key --strict`; verify all pass.

## Workflow follow-up

- Archive with `/opsx:archive`; bump both TOCs to 0.13.3; CHANGELOG line in ASD-STE100, for example "Fixed: On WoW Forever, the addon now finds savings from version 0.13.0 and earlier."
- Commit, PR, tag `v0.13.3` on the merge commit.

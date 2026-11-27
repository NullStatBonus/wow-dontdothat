## 1. Adapter and CheckThat module

- [x] 1.1 Add `Adapter.checkThat()` and `Adapter.readVersion` (existence-checked `C_AddOns.GetAddOnMetadata` or `GetAddOnMetadata`) in `DontDoThat/Intercepts/Adapter.lua`.
- [x] 1.2 Add `DontDoThat/CheckThat.lua` (status, fail, entries `version`, `testsettings`, `setting`, run hook registration) and list it in both TOC files; run `make check`.
- [x] 1.3 Test the module against a fake adapter: CheckThat missing, old (no `Entry` or `OnRun`), raising, and current.

## 2. Test settings

- [x] 2.1 Add the state logic (record, run id rules, profile names, debug carry-over, marks on the temporary profile) as pure Lua in `DontDoThat/Model/`; test every scenario of the spec.
- [x] 2.2 Wire it to AceDB in `Core/Addon.lua`: swap, restore at the start of `OnEnable`, re-run `ClassifyStyle`, `ClearDebug` and `Log.SetEnabled` after a restore, and the `OnDatabaseShutdown` write-back of the profile key. Keep debug on at load while the record and a run exist.
- [x] 2.3 Close open questions and previews before the swap, call `Options.Refresh`, and keep the slash handler off its captured `p` after the swap. `Reset all settings` keeps `allowedItems` while the mode is on.
- [x] 2.4 Add `/ddt testsettings on|off` to `Core/Slash.lua` and the help text, with every player-facing sentence in `L[...]` and `Locales/enUS.lua`.
- [x] 2.4b Add the settings banner and a Profiles page (bundle AceDBOptions-3.0, locked while the mode is on). Print one `Profile in use: <name> (your own|temporary)` line at login and at each profile switch (AceDB `OnProfileChanged`, deduplicated), and in every test-settings chat line.
- [x] 2.5 Run hook: `runStarted`, `runEnded`, `runGone` with the run id and the log lines of the design.
- [x] 2.6 Test with the addon loaded in real TOC order (DontDoThat before CheckThat), a downgrade (a build that ignores the record), a removed CheckThat, and a save between swap and restore.
- [x] 2.7 Replay anonymized saved variables from earlier releases (one Forever, one Era) through load and restore; assert the player's profile and `db.char` do not change.

## 3. Debug evidence

- [x] 3.1 Write `debug log turned on` and `debug log turned off` from both `/ddt debug` and the settings page checkbox.
- [x] 3.2 Add test-settings state, profile name and CheckThat status to `Export.Build` in `DontDoThat/Debug/Export.lua`; add a test.
- [x] 3.3 Write the `checkthat:` log lines of the spec; add tests, including that an entry call writes nothing.

- [x] 3.4 Write `items: purchase call made|dropped` for every vendor and auction purchase call, and `confirm: training call made for row <n>` for every Forever trainer purchase through the overlay; test each, including that a declined question writes none.

## 4. Documentation

- [x] 4.1 README: the command, the log lines, the entries and the debug-report line.
- [x] 4.2 `docs/contracts.md`: the CheckThat lines, entries and the log bound (500 entries).
- [x] 4.3 `docs/test-plan.md`: turn it into a pointer to the CheckThat plans (as ClosestVendor does) and update the Testing rules in AGENTS.md. Record the per-change version exception: the TOC stays at 0.15.0 until 1.0.0 is released.
- [x] 4.4 `docs/listing.md` if it lists commands.

## 5. Verify

- [x] 5.1 Break each behavior in turn, confirm its test fails for the expected reason, then restore it.
- [x] 5.2 `make test` and `make check`.

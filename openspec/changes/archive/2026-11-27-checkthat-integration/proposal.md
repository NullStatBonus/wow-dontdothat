# Proposal

## Why

DontDoThat's CheckThat plan can only ask the player to read the version, and it cannot rely on the player's own settings. Issue #73 asks for the addon to give CheckThat evidence and a test-settings mode, as ClosestVendor does. The addon has many users, so the mode must never leave a player on test settings, and a player must always know which profile is in use.

## What Changes

- Add `DontDoThat/CheckThat.lua`. It reaches CheckThat only through the adapter, checks that each function exists and wraps each call in `pcall`. With CheckThat missing, old or failing, the addon behaves as it does today.
- Register CheckThat entries: `version` (the TOC version as `major*10000 + minor*100 + patch`), `testsettings` (`on` or `off`) and `setting` (a setting's value, the mount marks, the allowed-item count).
- Add `/ddt testsettings on|off`. `on` switches the character to a temporary AceDB profile with default settings and puts the player's own profile aside. `off` switches back. The saved file never names the temporary profile (a shutdown hook writes the player's own profile back), and a login with no open run restores the player's profile.
- Register the CheckThat run hook. A run start turns test settings on, a run end turns them off.
- Chat names the profile in use, and says whether it is the player's own or temporary, at every login and at every profile switch, and in every test-settings line.
- Add a banner to every settings page while test settings are on, with a Restore my settings button.
- Add a Profiles page to the settings, using the standard AceDBOptions-3.0 control (bundled from the same Ace3 commit as the other libraries). It is locked while test settings are on. This makes the shared profile visible and switchable for the first time.
- Keep the player's Always Allow list when Reset all settings runs while test settings are on.
- Log one line for each of: debug on, debug off, a test-settings change, a restore at login, and each CheckThat integration event.
- Add the test-settings state, the profile in use and the CheckThat status to the debug report. Document the command, the page, the log lines and the entries.
- Does not release: the TOC stays at 0.15.0 until 1.0.0 is released as one piece of #73. This is an exception to the per-change bump rule in AGENTS.md, recorded there by this change.

## Capabilities

### New Capabilities
- `checkthat-integration`: how the addon works with the CheckThat test runner: entries, the run hook, the test-settings mode, the banner and the profile-in-use chat lines.

### Modified Capabilities
- `slash-interface`: adds `/ddt testsettings on|off`.
- `debug-tools`: debug on and off write a log line; the report shows the test-settings state.

## Impact

- New file `DontDoThat/CheckThat.lua`, listed in both TOC files; new adapter function `Adapter.checkThat`.
- New bundled library `Libs/AceDBOptions-3.0` (same Ace3 commit as the other libraries; `embeds.xml`, `VERSIONS.txt`).
- `Core/Slash.lua`, `Core/Addon.lua`, `Debug/Export.lua`, `Options/Options.lua` (banner, Profiles page, refresh after a switch).
- Saved data: a small `db.char.testSettings` record that exists only while test settings are on. Older versions ignore it. The player's own profile is never modified.
- `README.md`, `docs/contracts.md`, `docs/listing.md` (only if it lists commands) and `docs/test-plan.md`.

## Open

- The pattern (banner, Profiles page, profile-in-use lines, `testsettings` entry) is meant for the other addons. A shared write-up is not part of this change.
- Merchant, trainer and auction recordings for the offline blocks come from CheckThat (CTProbe); they do not block this change.
- A mockup is at https://claude.ai/artifact/2y9ENwkNJ5mYbm5b3yFXmu.

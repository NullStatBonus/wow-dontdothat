## Context

Issue #73 asks DontDoThat to adopt CheckThat's tooling the way ClosestVendor did. ClosestVendor swaps its per-character settings tables in place. DontDoThat differs: settings live in `db.profile` (AceDB, shared "Default" profile), and `db.char` holds data that must never be touched by a test (`ledger`, `allowedItems`, `catalog`, `costCache`, `milestoneOverride`). The addon is published, so saved data stays backward compatible and a player must never stay on test settings.

## Goals / Non-Goals

**Goals**
- CheckThat entries, run hook and `/ddt testsettings` with ClosestVendor's outward behavior (command, log lines, run-hook rules).
- A mode that cannot strand a player, including when CheckThat is removed or the player's profile is missing.

**Non-Goals**
- The foundation plan, the Always Allow feature plan, offline blocks and recordings (#73, later changes).
- Swapping or freezing `db.char` data. The foundation plan avoids steps that need it. Always Allow and ledger handling are decided in the plan review.
- Editing the PR 72 plan and its hooks file (the Always Allow feature plan change does that).
- Swapping `allowedItems`, `milestoneOverride` or `professionAsked` (the `setting` entry reports them instead; revisit only if plans need masking, with the shutdown hook of decision 2).
- A release or version bump. The TOC stays at 0.15.0 until 1.0.0 is released with the rest of #73. This is an exception to the per-change bump rule in AGENTS.md, recorded there by this change. The TOC stays at 0.15.0 until 1.0.0 is released with the rest of #73.

## Decisions

1. **Temporary AceDB profile, never saved.** `on` records `db.char.testSettings = { profile = <own>, runId }`, calls `db:SetProfile("DDT test")` (short, fixed; AceDB limits names to 50 characters; `pcall`, and nothing changes if it fails) and `db:ResetProfile()`. `off` calls `SetProfile(own)` and then `DeleteProfile(temp, true)`. The profile key is per character, so a character on the shared profile is unaffected.
2. **The saved file never names the temporary profile.** A shutdown hook (AceDB `OnDatabaseShutdown`) writes the recorded profile back to `sv.profileKeys[charKey]`. A downgrade, a removed addon, a missing CheckThat and a crash all leave the player on their own profile. The temporary profile is entered at login only when the record exists and a run is open.
3. **The login restore runs at the start of `OnEnable`.** CheckThat lists DontDoThat as an optional dependency, so its global does not exist in `OnInitialize`. The restore asks `CheckThat.ActiveRun("DontDoThat")`: no plan, CheckThat missing or too old means restore. After a restore the addon runs `ClassifyStyle`, `ClearDebug` and `Log.SetEnabled` again on the restored profile and clears the stale `debug` flag. A test loads the addon in real TOC order.
4. **Debug across a load.** Debug is cleared at each load. While `db.char.testSettings` exists and a run is open, the load keeps debug on, so the login lines are recorded. Outside a run nothing changes. The swap copies the debug flags to the profile it switches to, also on "on while on".
5. **The temporary profile is marked as migrated.** After `ResetProfile` the swap sets `styleMarked` and the revision-notice mark, so the next load does not set `alert.style = "warning"` or print the skip-list notice. The swap does not call `SkipRevision.Notice` or `ClassifyStyle`.
6. **Profile references.** Consumers read `ns.db.profile` at call time (none cache it). The swap closes open questions and previews, fires AceDB's callbacks, calls `Options.Refresh`, and the slash handler does not use its captured `p` after the swap.
7. **`Reset all settings` keeps the player's Always Allow list while test settings are on.** The reset empties `allowedItems` only when the mode is off.
8. **Run ownership.** `runId` in the record: a start with the same id changes nothing; a new id turns the mode on; a start with no id is logged and ignored; an `end` turns it off. Lines follow ClosestVendor.
9. **Entries** return the TOC version as a number, the `testsettings` state and a setting's value; the `setting` entry also reports mount marks and the allowed-item count, so a foundation step fails early with a clear reason when the character does not match the plan's assumptions.
10. **Adapter.** `Adapter.checkThat()` returns the global `CheckThat` or nil. Only `CheckThat.lua` uses it.

## Risks / Trade-offs

- The player or another addon switches profiles while the mode is on: `off` still returns to the recorded profile.
- AceDB raises if `DeleteProfile` targets the active profile. `off` switches first and wraps the delete in `pcall`; a leftover temporary profile is harmless and is removed by the next `off`.
- `/reload` during a run keeps the mode on by design (decisions 2 and 3).
- Saved variables are written at logout or reload, so a crash writes nothing and the player's own profile stays in the file.

## Migration Plan

Additive. `db.char.testSettings` has no default and exists only while the mode is on. No migration of existing data. A new test replays real saved variables from before this change through the load and restore path.

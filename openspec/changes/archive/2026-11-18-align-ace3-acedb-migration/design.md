# Design

## Context

See proposal.md (Why). Current state that shapes the approach:

- `DontDoThat/Libs` holds Ace3 Release-r1403 (commit d295b12): AceDB-3.0 minor 33. Upstream ac3d122 has AceDB minor 40. Closest Vendor (`../wow-closest-vendor/ClosestVendor/Libs`) already ships ac3d122, but only LibStub, CallbackHandler-1.0, AceGUI-3.0 (with widgets), AceConfigRegistry-3.0 and AceConfigDialog-3.0. AceAddon, AceDB, AceHook, AceEvent, AceConsole, AceConfigCmd and the AceConfig-3.0 wrapper must come from upstream directly.
- AceDB 33 key: `UnitName("player") .. " - " .. GetRealmName()`. AceDB 40 key: `UnitNameUnmodified("player") .. " - " .. GetRealmName()` normally, and `name .. " " .. surname` (from `UnitNameUnmodified`) when `RegionalUniqueNamesEnabled()` is true (WoW Forever). AceDB 40 also derives the realm key from `C_GameRules` on Forever; Don't Do That uses no realm, factionrealm or factionrealmregion section, so only the char key and `profileKeys` matter.
- `addon:OnInitialize` (`DontDoThat/Core/Addon.lua`): `Settings.StyleBefore(_G.DontDoThatDB)` snapshots raw saved profiles, then `AceDB:New("DontDoThatDB", ns.defaults, true)`, then `Settings.ClassifyStyle(db.profile, before, db:GetCurrentProfile())`, `Settings.ClearDebug`, `Tally.Init(db)` (first reader of `db.char`), `Log.Init`, `Probe.Init`. `OnEnable` later runs `Settings.MigrateCharMarks(db.char, ...)`.
- Verified: nothing reads `db.char` before `Tally.Init`. `AceDB:New` does not touch `sv.char`; `db.char` is built lazily on first access (the db metatable's `__index` calls `initSection`). `AceDB:New` does write `sv.profileKeys[newKey] = currentProfile` (falling back to "Default"), so after `New` the new key always has a profile entry.
- `StyleBefore` reads only raw `profiles`, never `char` or `profileKeys`, so the migration does not disturb the snapshot. `ClassifyStyle` classifies the profile named by `GetCurrentProfile()`, so a profile switch from the migration must happen before it.
- Game calls for player state go through `DontDoThat/Intercepts/Adapter.lua`, which reads functions from an injected `env` through `call(env, fname, ...)` (pcall, nil when missing). `Adapter.lua` loads after `Core/Addon.lua` in the TOCs but before `ADDON_LOADED`, so `ns.Adapter` exists in `OnInitialize`.
- Tests: `tests/warning_style_test.lua` runs the real bundled AceDB with stubbed globals; `tests/options_ace_test.lua` runs only the real AceConfigRegistry. AceDB 40 additionally calls `UnitNameUnmodified`, `RegionalUniqueNamesEnabled` (guarded), `C_GameRules`/`Enum.GameRule` (Forever branch only) and `strlenutf8` (profile name checks).
- Don't Do That has no colour setting of its own; the ColorPicker fix reaches players through the shared AceGUI that LibStub picks (highest minor across all loaded addons).

## Goals / Non-Goals

**Goals:**
- Every file in `DontDoThat/Libs` is byte-identical to upstream ac3d122, and to Closest Vendor's copy where both ship the file.
- A WoW Forever character keeps its `char` data and profile choice whichever AceDB minor LibStub loads.
- The migration is a pure, tested function; game calls stay in the adapter.

**Non-Goals:**
- Reverse migration when the loaded AceDB goes back to the old key (every AceDB 40 addon removed): tracked as issue #38.
- Merging data when both the old and the new key already hold `char` data.
- Migrating realm, factionrealm or other section keys (unused by Don't Do That).
- Changing the module set, or adding/removing libraries.

## Decisions

1. **Take all libraries from upstream ac3d122, verify against Closest Vendor.** Download the ac3d122 tarball, copy the same modules and file list (Lua and XML, widgets included) over `DontDoThat/Libs`, then hash-compare: shared files against `../wow-closest-vendor/ClosestVendor/Libs`, all files against the tarball. Alternative (copy only from Closest Vendor) fails because it lacks AceDB, AceAddon and the others.

2. **New key from `db.keys.char`, not recomputed.** The key the loaded AceDB actually used is the only source of truth: it covers AceDB 33 (keys equal, no-op), AceDB 40 on Era (`UnitNameUnmodified` equals `UnitName` there) and AceDB 40 on Forever. Copying AceDB's key logic would drift with future minors.

3. **Old key from a new adapter reader.** `Adapter.ReadLegacyCharKey(env)` returns `UnitName("player") .. " - " .. GetRealmName()` via `call`, or nil if either is missing or not a string. Nil means skip the migration.

4. **Logic in `Settings.MigrateCharKey(sv, db, oldKey)` in `Model/Settings.lua`**, called in `OnInitialize` right after `AceDB:New` and before `ClassifyStyle`. `sv` is the raw saved table (`db.sv`). Steps, all skipped when `oldKey` is nil or equals `db.keys.char`:
   - Guard: `sv.char` and `sv.profileKeys` may be nil (AceDB creates `sv.char` only on first access of `db.char`, so a fresh install has none); each step checks `type(...) == "table"` first.
   - `char`: if `sv.char[old]` is a table and `sv.char[new]` is nil, set `sv.char[new] = sv.char[old]` and `sv.char[old] = nil` (a move, so a second run finds nothing). If `sv.char[new]` exists, leave both untouched.
   - `profileKeys`: if `sv.profileKeys[old]` is a string different from `db:GetCurrentProfile()`, call `db:SetProfile(it)` in pcall. Then clear `sv.profileKeys[old]` in every case where it existed. Clearing is what makes it once: without it, a player who later picks another profile on Forever would be switched back at every login.
   - `SetProfile` fires `OnProfileChanged`; no listener is registered yet (Toast registers later), so nothing else reacts.
   Alternative (a saved "migrated" flag) adds a stored value AceDB would have to keep; the move-and-clear is self-marking.

5. **Tests.** A new `tests/char_key_migration_test.lua` with two layers: pure tests of `Settings.MigrateCharKey` on fake `sv`/`db` tables, and an end-to-end test that loads the real bundled AceDB 40 with a Forever-shaped fake client (`RegionalUniqueNamesEnabled` true, `C_GameRules`, `Enum.GameRule`, `UnitNameUnmodified` returning name and surname, `UnitName`, `GetRealmName`, `strlenutf8`) and saved data under `Name - Realm`. Cases: ledger/costCache and profile choice survive; second run no-op; profile picked after the move survives the next login; Era (keys equal) untouched; data already under the new key not overwritten. Each assertion is mutation-checked (break the move, the clear, the guard; see the test fail).

6. **Provenance file.** `DontDoThat/Libs/VERSIONS.txt` rewritten: upstream URL and full ac3d122 commit, retrieval date, one line per module with MAJOR and MINOR (from each file's `NewLibrary` call), license file name (`LICENSE-Ace3.txt`, content equal to Closest Vendor's `LICENSE.txt`), local patches: none, and update steps (download tarball, copy, hash-compare with sibling addons, update this file, run tests).

## Risks / Trade-offs

- [Players who already loaded AceDB 40 from another addon have a thin `sv.char[new]` (defaults plus a little new data); the no-overwrite rule leaves their older history under the old key] → Accepted as decided; documented. A merge is out of scope.
- [`sv.profileKeys[old]` was written by AceDB 33 as "Default" for players who never picked a profile] → Equal to the current profile in the common case, so only the clear happens.
- [A player who already picked a profile under the new key and still has an old-key entry gets the old choice once] → Rare (only when another addon's AceDB 40 loaded earlier); one-time and visible in the profile dropdown.
- [Later downgrade to AceDB 33 strands data under the new key] → Issue #38.
- [Bundled lib tests break on the new globals] → Task 1.5 adds the stubs to `warning_style_test.lua` (the only existing test that loads AceDB).

## Migration Plan

Ships as one patch release. Rollback: an older release with AceDB 33 reads the old key, which the migration cleared or moved; see issue #38 (only matters on Forever).

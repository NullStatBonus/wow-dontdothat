# Design

## Context

See proposal.md (Why). `Settings.MigrateCharKey(sv, db, oldKey)` (0.13.1) already works in either direction: it moves `sv.char[oldKey]` to `db.keys.char` only when the target is empty, switches to `sv.profileKeys[oldKey]` when it differs from the current profile and then clears it, and returns early when `oldKey` equals `db.keys.char`. `OnInitialize` calls it once, with `Adapter.ReadLegacyCharKey(_G)` (`Name - Realm`). Under an older AceDB on Forever that key equals the key in use, so nothing moves back.

AceDB 40 builds its Forever key as `name .. " " .. surname` from `UnitNameUnmodified("player")` when `RegionalUniqueNamesEnabled()` is true, and works out every key once, when its file loads.

## Goals / Non-Goals

**Goals:** data follows the loaded AceDB in both directions with the existing move rules; no change to `MigrateCharKey`.

**Non-Goals:** merging two populated keys; realm or other section keys (unused); keys of AceDB versions not yet released.

## Decisions

1. **`Adapter.ReadCharKeys(env)` returns the candidate keys**, `{ "Name - Realm", "Name Surname" }`. The second is added only when `RegionalUniqueNamesEnabled` returns true and `UnitNameUnmodified` gives a non-empty name and surname; otherwise the list has only the first. All calls go through the adapter's `call` (pcall, nil when missing). `ReadLegacyCharKey` stays and supplies the first entry. Alternative: recompute AceDB's own key logic for "the other key" — rejected, because the loop over candidates needs no knowledge of which one AceDB picked.
2. **`OnInitialize` calls `MigrateCharKey` once per candidate** through a small `Settings.MigrateCharKeys(sv, db, keys)` loop (so the tests run the same loop), in the order above, each in pcall, right after `AceDB:New` and before `ClassifyStyle`. The candidate equal to `db.keys.char` is a no-op. With a key AceDB has never used, the first candidate holding data moves and the second is stopped by the no-overwrite rule.
3. **No split data.** Each move removes its source before anything reads `db.char`, so a character's data sits under one key at a time; toggling another addon between sessions only moves it again. A saved "migrated" flag is not needed.
4. **Testing a downgrade with the bundled AceDB 40.** Load AceDB with `RegionalUniqueNamesEnabled` missing, so its key is `Name - Realm` (what AceDB 33 uses on Forever), then define `RegionalUniqueNamesEnabled` to return true before the move, so the reader still offers `Name Surname`. No second AceDB copy is bundled.

## Risks / Trade-offs

- [Both keys hold data (another addon's AceDB 40 ran before 0.13.1)] → Both left as they are; the player sees the copy under the key in use. Same as 0.13.1.
- [A client where `UnitNameUnmodified` returns a surname but AceDB uses `Name - Realm`] → The reader offers `Name Surname`, which normally holds nothing, so nothing moves.
- [Profile choice flips once on each library change] → Intended: the choice follows the data.

## Migration Plan

Ships as one patch release. Rollback to 0.13.1 keeps forward moves only; data moved back under `Name - Realm` is moved forward again by 0.13.1's move.

# Design

## Context

AceDB 33 (bundled up to 0.13.0) keys a character as `UnitName("player") .. " - " .. GetRealmName()`. AceDB 40 does the same when regional unique names are off, and uses `"Name Surname"` when they are on. On WoW Forever `GetRealmName()` returns `""` at login (KeepThat PR #24, measured from the player's saved variables; a nil there would make AceDB 33 error at load, so the value is a string). The Forever key under AceDB 33 is therefore `"Name - "`.

`Adapter.ReadLegacyCharKey` rejects an empty realm and returns nil, so `ReadCharKeys` offers only `"Name Surname"` on Forever. Forward (AceDB 40 in use): the only candidate equals the key in use, so the data under `"Name - "` is never found. Back (AceDB 33 in use, key `"Name - "`): `"Name Surname"` is offered and moves, so this direction works; only the forward move is broken.

## Goals / Non-Goals

**Goals:** the reader returns exactly the key AceDB 33 builds, including an empty realm; the existing move rules handle the rest unchanged.

**Non-Goals:**
- The realm or faction-realm keys (Don't Do That stores nothing under them; AceDB 40 uses the ruleset there on Forever).
- An `UnitNameUnmodified` variant of the old key: AceDB 33 used `UnitName`, and AceDB 40 with surnames off is not a Forever case.
- The other findings from the 2026-11-20 bug review; they ship separately.

## Decisions

1. **Accept any string realm, including `""`.** The reader returns `name .. " - " .. realm` when the name is a non-empty string and the realm is a string. Nil only for a missing or empty name, a non-string realm, or a call that errors. Alternative: special-case Forever by detecting surnames — rejected; matching AceDB's own expression is simpler and right on every client.
2. **No change to `MigrateCharKey`, `MigrateCharKeys` or `OnInitialize`.** `"Name - "` is a valid, distinct key, so the existing loop moves it forward under AceDB 40 and back under an older AceDB.
3. **Test with the real bundled AceDB.** The test login helper takes the realm name as a parameter; the new tests pass `""` for Forever, forward and back, with a second login that changes nothing.

## Risks / Trade-offs

- [Era client returning an empty realm during a loading glitch] → the key `"Name - "` holds nothing there, so nothing moves; same as any unused candidate.
- [Players who already started fresh under `"Name Surname"` on 0.13.1/0.13.2] → their old data under `"Name - "` stays where it is, because data under the key in use is never overwritten. They keep the newer data. This matches the existing "Data already under the new key" scenario.

## Migration Plan

Patch release 0.13.3. Rollback to 0.13.2 leaves moved data in place under the key in use.

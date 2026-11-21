# Proposal

## Why

On WoW Forever, `GetRealmName()` returns an empty string at login (measured from the player's saved variables in KeepThat PR #24, where every Forever session logged "no player identity"). An older AceDB (minor 33, bundled before 0.13.1) therefore filed a Forever character as `"Name - "`. `Adapter.ReadLegacyCharKey` returns nil when the realm is empty, so on Forever the 0.13.1 move from `"Name - "` to `"Name Surname"` never runs. A Forever player who updated without another addon that ships AceDB 40 sees their savings, prices and profile choice as reset. The tests passed because they always stub a realm name.

## What Changes

- The earlier-key reader builds the key the way AceDB 33 does: `UnitName("player") .. " - " .. GetRealmName()`, including when the realm is an empty string. It still returns nil when the name is missing or empty, or the realm is not a string.
- Data and the profile choice saved under `"Name - "` move to `"Name Surname"` at login on Forever, with the existing move rules (never overwrite, at most once, keys equal = no-op).
- Tests cover the empty realm with the real bundled AceDB, forward and back.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: the requirement "Character data survives a character-key change" gains a scenario for a Forever client with no realm name.

## Impact

- `DontDoThat/Intercepts/Adapter.lua` (`ReadLegacyCharKey`).
- `tests/char_key_migration_test.lua`.
- `docs/test-plan.md` section 21 (note that the old key has an empty realm on Forever).
- Patch release 0.13.3. No saved-data shape change.

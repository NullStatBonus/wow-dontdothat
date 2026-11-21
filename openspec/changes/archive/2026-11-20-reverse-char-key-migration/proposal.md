# Proposal

## Why

0.13.1 moves a WoW Forever character's saved data and profile choice from `Name - Realm` to `Name Surname` when the loaded settings library (AceDB 40) uses the new key. The game loads the newest AceDB from any installed addon, so if the player later removes every addon that ships AceDB 40, the older AceDB uses `Name - Realm` again and the savings, observed prices, mount marks and profile choice sit unused under `Name Surname` (issue #38).

## What Changes

- At login, offer both earlier keys to the existing move: `Name - Realm` and, on WoW Forever, `Name Surname`. Whichever differs from the key in use and holds data is moved, so the data follows the loaded library in both directions.
- The Forever key is offered only when the client reports regional unique names and the character has a surname, so Classic Era is never touched.
- The existing rules stay: one move per key change, the old entry is removed, data already under the key in use is never overwritten.
- Out of scope: merging two copies when both keys already hold data (for example a thin copy left by another addon's AceDB 40 before 0.13.1). Both stay as they are, as in 0.13.1.
- Patch release (0.13.1 -> 0.13.2). Closes #38.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `addon-settings`: "Character data survives a character-key change" covers a change back to the older key as well as forward.

## Impact

- `DontDoThat/Intercepts/Adapter.lua`: a reader for the earlier keys. `DontDoThat/Core/Addon.lua` (`OnInitialize`): try each key. `Settings.MigrateCharKey` is unchanged.
- `tests/char_key_migration_test.lua`: downgrade, round trip, Era and both-keys cases. `docs/test-plan.md` section 21: one manual check.
- Saved data: `DontDoThatDB.char` and `DontDoThatDB.profileKeys` on WoW Forever, moved back once after a library downgrade. No new saved value.

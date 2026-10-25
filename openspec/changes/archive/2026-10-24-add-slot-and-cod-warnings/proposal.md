## Why

Bank slots, hunter stable slots, and cash-on-delivery mail are gold sinks the addon does not see. Each is a one-click purchase behind a game confirmation, so they are cheap to guard the same way talent and pet resets already are, and they spend gold the player wants for their mounts.

## What Changes

- Intercept the game's confirmation for buying a bank slot, buying a stable slot, and paying a COD mail, and replace it with the addon's Accept / Cancel question: the warning sound, the price, a short reason, and the earn-back line.
- Count a declined purchase in the existing "Purchases you turned down" tally and an accepted one as spent against the rules.
- Add three on/off switches on the Items page, all on by default: bank slots, stable slots, COD mail.
- Leave the game's own dialog in place, with a note added, wherever the addon's question cannot be used.
- The minimum price does not apply to these; every slot or COD payment is warned about.
- Out of scope: weapon skills, Mail armor proficiency, flight paths, repairs.

## Capabilities

### New Capabilities
- `slot-and-cod-warnings`: guarding bank slot, stable slot, and COD mail payments with a confirmation question, the tally treatment, and graceful fallback.

### Modified Capabilities
- `addon-settings`: the Items page gains the three switches.

## Impact

- Changed: `Intercepts/Resets.lua` (generalised so each guarded dialog supplies its own price lookup, accept action, and completion hook), `Options/Options.lua`, `Core/Addon.lua` defaults, `Model/Tally.lua` wording if needed.
- No new files expected beyond tests; no new libraries.
- The three dialogs and their accept functions are taken from Blizzard's own source (`CONFIRM_BUY_BANK_SLOT`, `CONFIRM_BUY_STABLE_SLOT`, `COD_CONFIRMATION` and its auto-loot variant). They are unverified in game on both clients.

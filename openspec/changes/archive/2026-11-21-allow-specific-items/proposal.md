# Proposal

## Why

A player who always buys a certain item (a weapon upgrade, a potion they use, a recurring reagent) has two choices today: answer the question every time, or turn off the item's whole category and lose its warnings for everything else. Issue #29.

## What Changes

- The item question gets a third button, **Always Allow**. It buys the item and stops the addon asking about that item on this character again, at vendors and at the auction house.
- An allowed item gets no question, no tooltip line and no banner. Other items in its category are still warned about. Class item families, such as warlock grimoires, can be allowed too.
- A purchase of an allowed item, including the one that adds it, is counted neither as spent against the rules nor as avoided.
- What to watch > Shopping gets an "Always Allowed on this character" list with a Remove button for each item.
- Reset all settings also clears this character's allowed items.
- The debug report lists this character's allowed items, and the item trace shows when a purchase passed because it was allowed.
- Items are recognised by item ID, so an allow works in any client language. Random-suffix gear shares one ID, so allowing one suffix allows all of them.

Out of scope: asking again when an allowed item costs much more than before (#68); a timed "don't ask again today" choice (#69); allowing an item from settings (#70).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `item-purchase-warnings`: the vendor question offers Always Allow; a new requirement for allowed items.
- `savings-ledger`: an allowed purchase adds nothing to avoided or spent against the rules.
- `addon-settings`: the Shopping area lists allowed items; Reset all settings clears them.
- `debug-tools`: the report lists this character's allowed items.

## Impact

- Code: `Intercepts/ItemGuard.lua` (`Inspect`, `Run`, `Report`), `UI/ConfirmPopup.lua` (a three-button question), `Options/Options.lua` (Shopping list, Reset all), `Core/Addon.lua` (new `char` default), `Debug/Export.lua`, locale files.
- Saved data: a new per-character table, keyed by item ID. No migration; older versions ignore it.
- Docs: `README.md`, `docs/listing.md`, `docs/test-plan.md`.
- Version: minor bump (new player-visible feature).

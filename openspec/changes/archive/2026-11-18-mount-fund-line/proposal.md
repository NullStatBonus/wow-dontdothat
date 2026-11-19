# Proposal

## Why

"Buy anyway?" tells the player what an item costs and how long it takes to earn back, but not what it does to the thing they are saving for. Tying the warning to the mount goal makes the trade-off concrete.

## What Changes

- The "Buy anyway?" question gains one line, just before "Buy anyway?", when the purchase would leave the player short of the current mount goal: "After this you'll have 61g of the 100g for your level 40 mount."
- The line is left out when the player would still have enough after the purchase, when the gold or goal can't be read, and once the milestone is finished.
- Applies to every question that shows a price: trainer spells, vendor and auction house purchases, bank and stable slots. Not COD mail or resets, which annotate the game's own dialog.
- Minor release (adds a user-visible feature).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `purchase-warnings`: adds the mount fund line to the purchase question.

## Impact

- `DontDoThat/UI/ConfirmPopup.lua` (`Popup.Ask`), the goal math now in `Options.MilestoneProgress` (`Options/Options.lua`), `Locales`.
- Tests for the line's three cases. README "Warnings you can see and hear", `docs/listing.md` if it describes the question, `docs/test-plan.md`.
- No new setting; no saved-data change.

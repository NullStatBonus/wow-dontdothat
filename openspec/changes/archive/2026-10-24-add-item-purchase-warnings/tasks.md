## 1. Spike

- [ ] 1.1 In game on each target client, confirm whether the vendor buy handler and the AH bid/buyout placement can be wrapped and called from the confirm callback without `ADDON_ACTION_FORBIDDEN`; record the result in design.md Decision 5 and in the debug log helpers

## 2. Models and data

- [x] 2.1 Add `Data/GoldRates.lua` with the level bands above, each `needsReview = true`
- [x] 2.2 Add `Model/EarnBack.lua` with `Seconds` and `Describe` (minutes below 2 hours, hours plus 5-minute rounding above, "under a minute", level 60 rate above 60) and tests
- [x] 2.3 Add `Model/ItemCategory.lua` mapping class/subclass IDs to the thirteen categories, unmatched to Keys/quest/misc, and tests
- [x] 2.4 Add `Model/ItemWarning.lua` deciding whether a purchase is flagged from category mode, surface, total price, and minimum, and tests covering Off/Vendor/AH/Both, the minimum edge, and zero minimum
- [x] 2.5 Add `Ledger.RecordItemAvoided` and the avoided fields to `NewState`, tolerate missing fields in old saves, and tests
- [x] 2.6 Add `itemModes` defaults and `minPrice = 100` to `ns.defaults.profile`

## 3. Prompts

- [x] 3.1 Make `ConfirmPopup` append the earn-back line when a cost is present; update trainer (`Confirm.lua`) and reset (`Resets.lua`) callers and their tests
- [x] 3.2 Include the earn-back line in the alert banner text

## 4. Intercepts

- [x] 4.1 Add `Intercepts/Merchant.lua`: wrap the buy path, resolve item, quantity, total, ask, then call the original on accept; record avoided or spent; forbidden-action switch-off; pass-through on any failure
- [x] 4.2 Add `Intercepts/Auction.lua` per the spike result: either the same wrapped prompt for bid and buyout, or badge and tooltip only
- [ ] 4.3 Add badge and tooltip line for flagged vendor and AH items when no prompt is possible
- [x] 4.4 Respect overall enable, "Ask before buying", badges and tooltips, and alerts settings for item warnings
- [x] 4.5 Add the new files to both `.toc` files and run `tools/check-toc.sh` and `tools/check-tocs-match.sh`

## 5. Settings and tally

- [x] 5.1 Add the Items page: thirteen dropdowns, gold/silver/copper boxes with coin icons, carry-over and validation, and a reset control; update the subpage list
- [x] 5.2 Add the Avoided purchases row to the Tally page and include it in tally reset
- [x] 5.3 Add options tests for modes, defaults, minimum entry, overflow, and invalid input

## 6. Docs and verification

- [x] 6.1 Update `README.md`, `docs/contracts.md`, and `docs/test-plan.md` for item categories, the minimum price, the earn-back line, and avoided cost
- [x] 6.2 Run the full test suite and `openspec validate add-item-purchase-warnings --strict`
- [ ] 6.3 In-game check of vendor prompt (accept and cancel), a stack purchase, the minimum price, and the Items page

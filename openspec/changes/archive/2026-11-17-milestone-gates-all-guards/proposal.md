# Proposal

## Why

The mount stop point (stop after the level 40 or level 60 mount, plus the "mark done" checkboxes) only silences trainer advice. Vendor and auction house warnings, and the bank slot, stable slot, COD mail, talent reset and pet reset questions, keep asking after the player has bought the mount they chose to stop at. Separately, a declined talent or pet reset is counted at a guessed price from an unverified table, even when the game has already quoted the real price.

## What Changes

- Every warning surface (trainers, vendors, auction house, bank slot, stable slot, COD mail, talent reset, pet reset) stops once the chosen mount milestone is finished, and resumes if it becomes active again (for example, a milestone checkbox is cleared or the stop point is moved from 40 to 60).
- A declined talent reset or pet reset adds the price the game quoted to the savings total. The escalating-cost table is used only when no quote is known.
- Remove stale descriptions of the profession rank marks and skill margin, which were taken out in commit 688bae9: README line 34 and the rule-engine and addon-settings specs. No behavior changes for this part.
- The first-profession question's spec stops promising a price; the question itself is unchanged (it shows no price on purpose).
- "Start the count over" says what it clears: recorded counts and trainer prices. Spell totals read from the spellbook are worked out again.
- Talent reset and pet skill reset get their own on/off switches under What to watch > Other. Stable slot and pet skill reset switches show only for Hunters, so non-Hunters see three switches.
- Deferred to GitHub issues: #27 (auction house browse marks) and #28 (count shopping spend only when the purchase really happens).
- The default minimum shopping price is documented as 1 silver, which is what the addon already uses (the README and spec said 10 silver).
- Patch release (0.12.0 -> 0.12.1): this fixes existing behavior to match the stop-point setting.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `purchase-warnings`: "Inactive when not applicable" covers every warning surface and follows the chosen stop point, not only the level 60 mount.
- `savings-ledger`: respec and pet reset avoided savings prefer the price quoted by the client.
- `rule-engine`: drop "profession skill caps" from the rule switches; remove the "Profession margin setting" requirement.
- `addon-settings`: Tuning section and What to watch areas no longer mention the profession margin or the rank switch; Other lists the new reset switches.
- `slot-and-cod-warnings`: per-kind switches cover talent and pet skill resets; Hunter-only switches hidden for other classes.

## Impact

- `DontDoThat/Intercepts/ItemGuard.lua`, `DontDoThat/Intercepts/Resets.lua`, `DontDoThat/Intercepts/Context.lua`, `DontDoThat/Model/Ledger.lua`.
- Tests: `tests/items_test.lua`, `tests/guarded_dialogs_test.lua`, `tests/ledger_test.lua`.
- Docs: `README.md` (stop point wording), `docs/test-plan.md`. No new setting, so `docs/listing.md` and the `reportText` header need no change unless their wording claims otherwise.
- Saved data: unchanged; no migration.

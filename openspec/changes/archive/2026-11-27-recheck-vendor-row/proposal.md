## Why

The vendor "Buy anyway?" question keeps only the merchant row index. If the player leaves it open and the vendor's list changes or the window closes, Accept (and Always Allow) buys whatever now sits at that index, and Always Allow saves the wrong item. The auction path already re-reads the row and drops the purchase (issue #71).

## What Changes

- The vendor purchase callback reads the row again before it buys. It drops the purchase, and logs it, when the item, link or price differs from the one the question named, or the row is gone.
- A dropped vendor purchase writes `items: vendor row <n> changed while the question was open, purchase dropped`.
- No saved data changes. The TOC stays at 0.15.0 until 1.0.0 is released (see AGENTS.md).

## Capabilities

### Modified Capabilities
- `item-purchase-warnings`: the vendor purchase prompt completes the purchase only for the row it named.

## Impact

- `DontDoThat/Intercepts/Merchant.lua`, `tests/merchant_test.lua`.
- Closing the question when the vendor window closes is not part of this change: the re-check already makes a late Accept safe.

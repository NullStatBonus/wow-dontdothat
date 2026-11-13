# Proposal

## Why

The warning sound for vendor and auction house item purchases ignores the player's chosen sound channel and always plays on Master. Trainer and reset alerts already use the chosen channel.

## What Changes

- Item purchase alerts pass the player's sound channel to the alert, so they play on the same channel as other alerts.

## Capabilities

### New Capabilities

### Modified Capabilities
- `item-purchase-warnings`: "Respects existing switches" gains a scenario stating the warning sound uses the chosen sound channel.

## Impact

- `DontDoThat/Intercepts/ItemGuard.lua` (its alert settings), `tests/items_test.lua`, `docs/test-plan.md`.

# Proposal

## Why

The mount goals are one set of numbers for both clients: 100g at level 40, and 1,000g riding plus 200g mount (1,200g) at level 60. Those match WoW Forever, but Classic Era prices are split differently, and its level 60 goal is about 1,000g, not 1,200g. Neither client's goal accounts for the 10% reputation discount (and, on Era, the extra PvP rank discount), so a player who reaches Honored is told they need more gold than they do.

## What Changes

- Separate default mount goals per client, from the game's own item data and several guides:
  - **WoW Forever:** level 40 riding training 100g (first mount included); level 60 riding training 1,000g plus a 200g epic mount.
  - **Classic Era:** level 40 riding 20g plus an 80g mount; level 60 epic mount 1,000g. Era has no epic riding lesson, so level 60 is detected from the epic mount item (see design).
- The goal drops automatically when the player qualifies for a discount: 10% at Honored with the home race's faction, and on Classic Era another 10% at PvP rank 3 (Sergeant / Sergeant). Discounts add, to at most 20%. Progress shows the discount that applies.
- Class goals that come from class quests (Paladin, Warlock) are not discounted.
- Patch release (0.12.2): the goals were wrong for Era, and the Era level 60 mount was never detected.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `milestones`: per-client default goals; reputation and PvP discounts applied to the goal.

## Impact

- `DontDoThat/Model/Milestones.lua` (per-client defaults, discount), `DontDoThat/Intercepts/Adapter.lua` (read faction standing and PvP rank), `DontDoThat/Options/Options.lua` (Progress line), Locales.
- Interacts with `mount-fund-line`: the question's goal must use the same discounted target.
- Tests; README and `docs/listing.md` mount prices; `docs/test-plan.md`.
- No saved-data change.

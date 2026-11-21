# Proposal

## Why

The 2026-11-20 bug review (Claude and Codex) filed issues #43–#61, and later reviews filed #28 and #63–#65. They are guard holes (a purchase that is never checked, or the wrong one is bought), counting errors in Tally, Savings and the ledger, stale or missing data, debug-report gaps and convention breaks. One minor release fixes them together and replaces the long manual test plan with a short one, because almost all of these fixes can be proven by unit tests.

## What Changes

- **Guards act on what the question named.** Era trainer "Buy anyway" buys the row the question showed (#45). The auction question re-checks the auction before it acts and drops it when the list changed (#47). The Bids tab buyout is guarded (#48). A question that cannot be shown is not counted as a decline (#49). Era vendor rows read the right extended-cost value (#43). A plain right-click on a vendor bundle is priced as the whole bundle (#50).
- **Reset and COD dialogs.** A reused game dialog watches the reset kind it shows now (#44). Each Forever pet reset records its own quote (#53). Reopened dialogs, the Forever COD auto-loot price, a locale-safe pet-wipe check and the character-key migration are fixed (#60).
- **Counting.** Tally leaves out spells the character can never buy and keeps "not learned" from the spellbook (#51, #52). Finishing the mount goal keeps earlier Tally amounts (#55). Prayer of Mending is counted once (#54). Tally, Savings and the question agree (#59). Spent-anyway counts only purchases that really happen, and bids do not count (#28).
- **Data.** Missing ranks (ClassMask 0 rows) and Holy Shock spell IDs are fixed in the generator (#58). Forever talent points per tree feed automatic spec choice (#46).
- **Debug and options.** Rejected events are stored once (#56). The report lists every setting with defaults applied (#65). "Worth about Xg" follows the skip revision (#57). `/ddt trainerids` skips headers on Forever, and the remaining untranslated strings go through `L` (#60).
- **Code-only items from #61.** The bubble resets the tooltip minimum width, and the blocked-action watcher also matches `UNKNOWN()`.
- **Refactor.** Model, Options, Core and Slash code reads the game through adapters (#64).
- **Test plan.** `docs/test-plan.md` is rewritten as a few action + `Check:` + `Log:` checks for what unit tests cannot prove (#63, #61).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `purchase-warnings`: the confirmed purchase is the one the question named; an unshown question is not a decline.
- `savings-ledger`: Tally counts only purchasable spells; spend counts only on real purchases; amounts survive the mount goal.
- `slot-and-cod-warnings`: reused dialogs and repeated pet resets.
- `debug-tools`: every setting in the report; rejected events once.
- `spec-inference`: Forever talent points.

## Impact

- Intercepts (Resets, Auction, Merchant, ItemGuard, Confirm, Adapter, Context), UI (ConfirmPopup, InfoBubble), Model (SpellData, Tally, Ledger, Settings, EarnBack), Rules/Engine, Options, Debug (Capture, Export, Probe), Core, generators and generated data.
- Saved data: `eventFailures` is deduplicated on load. No other shape change.
- Minor release 0.14.0.

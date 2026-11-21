# Design

## Context

Twenty-one bug and refactor issues touch most modules. Each fix is small; the risk is in overlap and in fixes that need the game client to prove. The goal is one minor release proven mostly by unit tests.

## Goals / Non-Goals

**Goals:** fix #28, #43–#60, #64, #65; the code-only parts of #61; rewrite the manual plan (#63).

**Non-Goals:**
- Enhancements: #27 (mark items in the auction house), #29 (allow specific items), #33 (own mount goal), #36 (class training plans), #66 (toast background color).
- #37 (scope of rank rows on class pages): a UX investigation, not a defect.
- #61's taint and commodity-quote questions stay as manual checks in the test plan; they are fixed only if they reproduce.

## Decisions

1. **Remember the target when the question opens.** Era trainer accept calls `BuyTrainerService(savedIndex)` (#45). The auction question keeps the item link, buyout and list type and re-reads them at accept; a mismatch drops the purchase and logs it (#47). Simpler than cancelling on every list event.
2. **Shown flag on the popup data.** `ConfirmPopup` ignores `OnCancel` until `StaticPopup_Show` returns a frame (#49).
3. **One `OnHide` hook per frame, key stored on the frame** (#44).
4. **Bundle price:** a nil quantity means one whole bundle (#50).
5. **Ledger and the mount goal (#55):** while the goal is active, the ledger result is kept in `ledger.lastActive`; once it is finished, that result is shown. Judging as if the goal were still active was tried first and rejected in review: ranks bought after the mount, as advised, then counted as spent. A new optional field, no migration.
6. **Tier filter (#59):** Ledger uses the same defer-tier and purchasable filters as `Savings`, through one shared helper.
7. **Real spend (#28):** at proceed, the guard stores a pending spend (amount, money before, time); purchases within the window add to it. Each `PLAYER_MONEY` drop counts up to the pending total, within 5 seconds; a bid (amount below buyout) never counts. The alert-only and cannot-show paths store a pending spend too. A blocked `UNKNOWN()` call disables item questions only while our purchase call runs.
8. **Forever talents (#46):** the talent generator also emits talent → tab order. The Forever reader sums `currentRank` of trait nodes whose spell maps to a talent, per tab. Unit-tested with a fake `C_Traits`.
9. **Report settings (#65):** a Rules block reads each value with defaults applied; a test fails when a profile default key is missing from it.
10. **Adapters (#64):** Model gets values as arguments; `Adapter` gains time and popup helpers; a test loads Model files with an empty environment.

## Risks / Trade-offs

- [Money-drop matching may miss a purchase when two happen at once] → counts the smaller value; logged.
- [Regenerated spell data changes more rows than expected] → diff reviewed; data tests pin one row per rank.

## Migration Plan

`eventFailures` is turned into a deduplicated list on load. Spell switches and trainer records saved under the old Holy Shock and Shadow Word: Death family IDs move or are dropped (`Settings.MigrateFamilyIds`). `ledger.lastActive` is new and optional. Version 0.14.0.

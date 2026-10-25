# Design

## Context

Trainer purchases are guarded by wrapping the Train button click (`Intercepts/Confirm.lua`) and resets by watching the game's static popups (`Intercepts/Resets.lua`). Both raise an Accept / Cancel question through `UI/ConfirmPopup.lua` and stop for the session if the client reports `ADDON_ACTION_FORBIDDEN`. Settings live in `ns.defaults.profile` and are built in `Options/Options.lua` as AceConfig tables. The ledger (`Model/Ledger.lua`) already records respecs avoided and spent-against totals. No merchant or auction code exists yet. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Reuse the existing prompt, alert, ledger, and settings machinery so item warnings behave like trainer warnings.
- Keep category classification and money/time maths as pure functions that the Lua test harness can cover.

**Non-Goals:**
- Judging whether an individual item is a good buy (upgrade for the player, usable by class). Classification is by item category only.
- Tracking the player's real income. The earn-back rate is a static table.
- Tracking whether a declined item is bought later.

## Decisions

**1. Classify by item class and subclass IDs.** `Model/ItemCategory.lua` maps `(classID, subClassID)` from the item's info to one of the thirteen categories. Pure function; the data is a table in the same file. Class reagents, ammo, and quivers are split out by their own class/subclass IDs. Anything unmatched falls to Keys/quest/misc (Off by default), so a gap is silent, not noisy. Alternative: match by name; rejected as brittle and not localizable.

**2. Mode stored as one string per category.** `profile.itemModes = { armor = "both", ... }`, values `off|vendor|ah|both`. Defaults live in `ns.defaults`, so AceDB fills new categories for existing installs. Alternative: two booleans per category; rejected because the UI is one dropdown and a string maps to it directly.

**3. Minimum price stored as copper.** `profile.minPrice`, default 100 (10 silver). The Settings page shows three AceConfig `input` entries, each labeled with its coin icon, that read and write slices of the one integer. Silver and copper carry upward on save. Alternatives: one parsed text box (typo-prone), Blizzard's `MoneyInputFrame` (needs a custom AceGUI widget for little gain), preset dropdown (the player asked for free entry).

**4. Vendor interception wraps the buy path, as the trainer does.** Wrap the merchant item button's click/modified-click handler and the buy call it ends in, show the question, and call the original only on accept. The wrapper resolves quantity and total price before asking. If the client reports forbidden-action, the question switches off for the session and badge/tooltip remain, as in `Confirm.lua`. Alternative: `hooksecurefunc` post-hook; rejected because it cannot block.

**5. AH interception is conditional on a spike.** Wrap the bid/buyout placement the same way if it can be wrapped without taint on the target clients. If not, ship badge and tooltip only for the AH, which `purchase-warnings` already allows. The spike is the first task and decides which branch is built.

**6. Earn-back lives in one shared helper.** `Model/EarnBack.lua` exposes `Seconds(copper, level)` and `Describe(copper, level)`; rates come from `Data/GoldRates.lua` as copper per hour by level band, each band `needsReview = true`. `ConfirmPopup` appends the line when a cost is present, so trainer, reset, and item prompts all gain it in one place. Rates: 1–9 0.4g, 10–19 1g, 20–29 2g, 30–39 3g, 40–49 5g, 50–59 8g, 60+ 12g per hour. They are deliberately conservative; sources for Classic grinding rates are thin and anecdotal. Alternative: measure the player's income; deferred.

**7. Avoided cost is its own ledger field.** `itemsAvoided` (count) and `itemsAvoidedCopper` on the character ledger state, added by `Ledger.RecordItemAvoided`. Confirmed purchases reuse the spent-against total. `NewState` initialises both fields; existing saved states read missing values as zero. The Tally page shows a separate "Avoided purchases" row.

## Risks / Trade-offs

- [AH call path unverified for Classic Era and Anniversary] → Spike first; badge/tooltip fallback is already specified.
- [Wrapping a purchase handler can taint or break buying] → Same forbidden-action watcher and session switch-off used for the trainer; plain-purchase pass-through for anything unrecognized.
- [Item info not cached when the prompt is built] → Treat as unclassified and skip the prompt; never block on a missing lookup.
- [Gold/hour table is a guess] → Wording says "about", data is flagged `needsReview`, and the table is isolated in one file.
- [Decline then buy again double-counts as avoided plus spent] → Accepted for v1; rare and hard to detect.
- [Many cheap stacked purchases evade the minimum per click] → The minimum applies to the total of the click, not per unit.

## Migration Plan

AceDB supplies defaults for the new keys, so existing profiles pick them up on load with no migration code. Rollback is removing the new files from both `.toc` files; unused saved keys are harmless.

## Open Questions

- Whether a future version should replace the static rates with the player's measured income.

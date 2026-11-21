# Tasks

Each fix gets a unit test; break the fix, see the test fail for the expected reason, restore it. Record that on the task's verify line.

## 1. Resets (`Intercepts/Resets.lua`)

- [x] 1.1 #44: one `OnHide` hook per frame; store the current key on the frame when presenting.
- [x] 1.2 #53: on Forever's pet wipe, always take the current talent-wipe quote.
- [x] 1.3 #60: guard a dialog reopened while ours is up; Forever COD auto-loot reads the shift-clicked mail (`GetInboxHeaderInfo(data)`); pet-wipe detection does not depend on the English word "pet".

## 2. Auction, vendor and item guard

- [x] 2.1 #43: read the 8th `GetMerchantItemInfo` value as `extendedCost` where the 7th is `isUsable`.
- [x] 2.2 #50: a nil quantity prices one whole bundle; tooltip shows the bundle price.
- [x] 2.3 #47: keep link, buyout and list type; re-check at accept; drop and log on mismatch.
- [x] 2.4 #48: guard the `"bidder"` list; still skip `"owner"`.
- [x] 2.5 #28 (verified: `tests/item_guard_test.lua`; mutations of the bid check, `min`, window and dropped-purchase check each fail): pending spend confirmed by a `PLAYER_MONEY` drop; bids never count; alert-only path counts too.
- [x] 2.6 #61: blocked-action watcher also matches `UNKNOWN()`.

## 3. Question and bubble

- [x] 3.1 #45: Era trainer accept buys the service index saved when the question opened.
- [x] 3.2 #49: ignore `OnCancel` until `StaticPopup_Show` returns a frame.
- [x] 3.3 #61: reset `GameTooltip` minimum width on leave.
- [x] 3.4 #60: untranslated string in `UI/ConfirmPopup.lua` goes through `L`.

## 4. Counting (Model, Rules)

- [x] 4.1 #51: `SpellData.Services` applies the `Savings` racial/effect and first-talent-rank filters.
- [x] 4.2 #52: keep spellbook `false`.
- [x] 4.3 #55: ledger evaluates with the stop milestone active.
- [x] 4.4 #59: one tier filter for Ledger and Savings; `Tally.ObserveLive` compares row contents; profession prompts pass `action.cost`.

## 5. Data

- [x] 5.1 #58: keep ClassMask 0 rows that belong to the class; Holy Shock taught spell IDs; regenerate; data test.
- [x] 5.2 #54: no rankless duplicate row; data test of one row per family rank.
- [x] 5.3 #46: talent → tab data; Forever trait reader for points per tree; fake `C_Traits` test.

## 6. Debug and options

- [x] 6.1 #56: store each rejected event once; dedupe saved lists on load.
- [x] 6.2 #65: Rules block in `Export.Build`; test against the profile defaults.
- [x] 6.3 #57: revision (and prices) in the "Worth about" cache key; clear on `Options.Rebuild()`.
- [x] 6.4 #60: `/ddt trainerids` converts Forever service types; `MigrateCharKey` keeps a profile picked under the new key and keeps the old choice when `SetProfile` fails; Options, coin and volume strings through `L`.

## 7. Adapters (#64)

- [x] 7.1 `EarnBack`, `Options`, `Core/Addon`, `Core/Slash` read the game through adapters; test that loads Model files with an empty environment.

## 7b. Found while applying

- [x] 7.2 The rebuilt spell data gives Holy Shock and Shadow Word: Death new family IDs. `Settings.MigrateFamilyIds` moves saved spell switches and drops trainer records under the old IDs; called at enable. Verified by `tests/settings_test.lua` (mutation: no move fails).
- [x] 7.3 Forever talent points get a log line on change (`spec: talent points per tree …`); verified by `tests/talent_tabs_test.lua` (mutation: log every call fails).

## 8. Docs and checks

- [x] 8.1 README, `docs/listing.md` where behavior changed.
- [x] 8.2 #63: rewrite `docs/test-plan.md` as short action + `Check:` + `Log:` checks for what unit tests cannot prove; numbered in order.
- [x] 8.3 `make test`, `make check`, `openspec validate bug-review-fixes --strict`.

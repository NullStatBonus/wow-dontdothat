## 1. Generalise the guarded-dialog table

- [x] 1.1 In `Intercepts/Resets.lua`, let a `KINDS` entry supply `price(env, data)`, `accept(env, data)`, and `done` (the function to hook for completion), keeping the event quote and `confirmFn` working for talent and pet resets
- [x] 1.2 Pass the popup's `data` from the `StaticPopup_Show` hook through to `present` and `accept`
- [x] 1.3 Add the new accept functions to the forbidden-action watcher and `refuse` wording

## 2. New kinds

- [x] 2.1 Add the bank slot entry (`CONFIRM_BUY_BANK_SLOT`, price `BankFrame.nextSlotCost`, accept `PurchaseSlot`)
- [x] 2.2 Add the stable slot entry (`CONFIRM_BUY_STABLE_SLOT`, price `GetNextStableSlotCost()`, accept `BuyStableSlot`)
- [x] 2.3 Add the COD entry covering `COD_CONFIRMATION` and `COD_CONFIRMATION_AUTO_LOOT` (price `OpenMailFrame.cod`, accept per variant, completion via `TakeInboxItem` / `AutoLootMailItem`)
- [x] 2.4 Wire declined, accepted, and closed-without-answer outcomes to `Ledger.RecordItemAvoided` and `RecordItemPerformed`
- [x] 2.5 Give each kind its title and advice text, each ending with the earn-back line via the shared helper

## 3. Settings

- [x] 3.1 Add `profile.guard = { bank = true, stable = true, cod = true }` to the defaults and honour it in `active(kind)`
- [x] 3.2 Add the three toggles to the Items page and include them in its reset control

## 4. Export and docs

- [x] 4.1 Add the guarded-dialog state to the Items section of `/ddt export`: which kinds are enabled, and which dialogs have been seen this session with the price read
- [x] 4.2 Update `README.md`, `docs/contracts.md`, and `docs/test-plan.md` for the three new prompts

## 5. Tests and verification

- [x] 5.1 Tests for the generalised table: price lookup per kind, decline and accept counting, closed without answer, switches off, and ordinary mail recording nothing
- [x] 5.2 Options tests for the three toggles and the reset
- [x] 5.3 Run the full suite and `openspec validate add-slot-and-cod-warnings --strict`
- [ ] 5.4 In-game: buy a bank slot, a stable slot, and take a COD mail with the question accepted and cancelled (validate when gold allows)

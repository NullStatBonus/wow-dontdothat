# Design

## Context

`Intercepts/Resets.lua` already does this for talent and pet resets: it hooks `StaticPopup_Show`, and when the game opens a listed dialog it plays the alert, shows its own Accept / Cancel question, hides the game's dialog, and on accept calls the same function the game's Accept calls. On a refusal it switches off for the session and annotates the game's dialog instead. Each guarded dialog is an entry in a `KINDS` table. Two assumptions in that code do not hold for the new dialogs: the price arrives by event (`CONFIRM_TALENT_WIPE`), and Accept calls a zero-argument function. See proposal.md for motivation.

From Blizzard's own dialog source:

| Dialog | Price at show time | Accept does |
|---|---|---|
| `CONFIRM_BUY_BANK_SLOT` | `BankFrame.nextSlotCost` | `PurchaseSlot()` |
| `CONFIRM_BUY_STABLE_SLOT` | `GetNextStableSlotCost()` | `BuyStableSlot()` |
| `COD_CONFIRMATION` | `OpenMailFrame.cod` | `TakeInboxItem(InboxFrame.openMailID, OpenMailFrame.lastTakeAttachment)` |
| `COD_CONFIRMATION_AUTO_LOOT` | `OpenMailFrame.cod` | `AutoLootMailItem(index)`, index = the dialog's data |

## Goals / Non-Goals

**Goals:**
- Reuse the Resets mechanism so behaviour, fallback, and session switch-off match the existing guarded dialogs.
- Keep each kind's specifics (price, accept, completion hook) in its table entry.

**Non-Goals:**
- Slot or COD logic beyond the confirmation (for example judging whether a COD is worth paying).
- Weapon skills, Mail proficiency, flight paths, repairs.

## Decisions

**1. Generalise the `KINDS` entry instead of adding a second module.** Each entry gains `price(env, data)` (replacing the event quote where there is none), `accept(env, data)` (replacing the named zero-argument `confirmFn`), and `done` naming the global to hook for completion counting. Existing reset entries keep their event quote and `confirmFn`, expressed through the same fields. Alternative: a separate `Intercepts/Slots.lua` copying Resets; rejected, since it would duplicate the fallback, session switch-off, and counting code.

**2. Price is read when our question is built.** `present` already waits one frame after the popup shows. For the new kinds it calls `kind.price(env, data)` at that moment; a missing or zero price shows the question without a figure and records a zero cost. Bank and stable prices are plain reads; COD reads `OpenMailFrame.cod`.

**3. The COD popup's `data` is passed through.** `StaticPopup_Show(which, text1, text2, data)` reaches the hook as its arguments; `onPopupShown` keeps `data` and hands it to `accept`, which the auto-loot variant needs for its index. Both COD dialog names map to one entry with a shared label.

**4. Completion is counted by hooking the function the game's Accept calls.** `PurchaseSlot`, `BuyStableSlot`, `TakeInboxItem`, `AutoLootMailItem`, as `ConfirmTalentWipe` is today. `onConfirmed` already ignores calls when no prompt is pending, so ordinary mail takes (no COD) record nothing.

**5. Tally reuse.** Declined calls `Ledger.RecordItemAvoided(state, price)`; accepted calls `Ledger.RecordItemPerformed(state, price)`. No ledger changes. Dialogs closed without an answer use the existing `OnHide` counting, which records a decline.

**6. Switches in the profile.** `profile.guard = { bank = true, stable = true, cod = true }`, read in `active(kind)`. The Items page gets three toggles and its reset restores them. The minimum price is deliberately not consulted.

**7. Forbidden-action watcher covers the new accept functions.** The existing watcher lists `ConfirmTalentWipe` and `ConfirmPetUnlearn`; it gains the new function names so a refusal switches the question off for the session.

## Risks / Trade-offs

- [Dialog names and accept functions are from Blizzard source, unverified in game] → Fallback annotates the game's dialog; the export reports which dialogs were seen. If a dialog name is absent on a client, that kind is simply never triggered.
- [Accepting COD calls `TakeInboxItem` with frame state that may change before the player answers] → Read the arguments when Accept is pressed, not when the question opens; if the mail frame is gone, skip the call and leave the game's flow alone.
- [Hiding the game's dialog before our question could confuse COD flows] → Same hide-after-shown order as resets; if our question cannot show, the game's dialog stays.
- [Stable slots exist only for Hunters] → The dialog only opens for them; nothing class-specific is needed.
- [One-off slot purchases are only delayed, not avoided] → Counted as declined purchases like any other; wording stays "turned down".

## Migration Plan

AceDB supplies defaults for the new `guard` table. Rollback is reverting the `KINDS` generalisation; unused saved keys are harmless.

## Open Questions

- Whether to also record seen dialog names in the export report; deferred until the first in-game run shows whether it is needed.

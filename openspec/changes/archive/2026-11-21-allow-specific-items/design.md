# Design

## Context

Every vendor and auction purchase goes through `Guard.Run` (`Intercepts/ItemGuard.lua`). It calls `Guard.Inspect`, which decides `flagged` from the Shopping switch, the class item families (grimoires, matched by the item ID in the link), the category mode and the minimum price. The vendor tooltip line (`Guard.Tooltip`) and the banner when "Ask before buying" is off use the same `Inspect`. The question is `ConfirmPopup.Ask` → `ConfirmPopup.Show`, a single `StaticPopupDialogs` entry (`DONTDOTHAT_CONFIRM`) with Accept and Cancel, which the trainer (`Confirm.lua`) and reset (`Resets.lua`) questions also use. Accept runs `purchase()`, which notes a pending spend that `Ledger.RecordItemPerformed` counts when the money drops; Cancel calls `Ledger.RecordItemAvoided`.

Settings live in a shared AceDB profile; per-character facts (`milestoneOverride`, `professionAsked`) live in `db.char`. `Settings.ResetAll(p)` clears only the profile.

## Goals / Non-Goals

**Goals:** one check that every warning surface obeys; a third button that only the item question shows; a list the player can prune.

**Non-Goals:**
- Asking again when an allowed item costs much more than before: #68.
- A timed "don't ask again today" choice: #69.
- Allowing items from settings without a question first: #70.
- Re-checking the vendor row before a confirmed purchase (affects Accept too): #71.
- `/ddt get` / `/ddt set` access to the list: `Registry` holds scalar settings only.

## Decisions

1. **Store in `db.char.allowedItems`, keyed by item ID:** `[itemID] = { name = "...", icon = <fileID or path> }`. Name and icon are saved when the item is added, so the Shopping list and the report never wait on the item cache. Per character because the items players want are usually one character's gear or class reagents. A new `char` default `allowedItems = {}` in `Core/Addon.lua`; older versions ignore it, so no migration. Alternative: the shared profile — rejected, an item allowed for one class would stop questions on every alt.

2. **Check in `Guard.Inspect`, after the Shopping/mount checks and before the grimoire rule.** The item ID comes from the existing `itemId(link)` helper. When it is allowed, `Inspect` returns `why = "allowed"` and not flagged, so the question, the sound, the banner and the tooltip line all stop through one change. The trace then reads `passed through: allowed`. The check is a small function in `ItemGuard` (`Guard.Allowed(id)`, `Guard.Allow(id, name, icon)`, `Guard.Disallow(id)`) over `ns.db.char`, testable with a fake db.

3. **A second popup key for the item question.** `ConfirmPopup` registers `DONTDOTHAT_CONFIRM_ITEM` with `button3 = L["Always Allow"]` and `OnAlt`, which both Era and Forever `StaticPopup.lua` call for the third button (`OnAlt(dialog, data, "clicked")`). `Popup.Show(text, onConfirm, onCancel, onAllow)`: with `onAllow` it uses the item key, without it the existing two-button key, so trainer and reset questions do not change. `answer()` gains the `"allow"` kind with the same run-once rule. `Popup.Ask` passes `onAllow` through. An unanswered question under the other key is hidden when a new one opens, since the game reuses a shown frame only for the same key. Alternative: one key with `button3` toggled per show — rejected, `StaticPopupDialogs` entries are shared tables and a stale third button could reach a trainer question.

4. **Always Allow buys without counting.** The `onAllow` callback calls `Guard.Allow`, then runs the purchase with its money drop noted as an uncounted debit (the bid mechanism), so it never settles an earlier pending purchase; the same applies when an allowed item is bought later. Nothing is avoided; outcome `question shown, always allowed, bought`. Saving the allow before the purchase runs means a purchase that fails (full bags) still leaves the item allowed; that matches what the player chose. Then `Options.Rebuild()` if the options are built, so an open Shopping page shows the new row.

5. **Shopping list with standard AceConfig controls.** After the category group: a heading "Always Allowed on this character", then for each item, sorted by name, a `description` (`image` = saved icon, `name` = saved name, width ~1.5) and an `execute` "Remove" button that calls `Guard.Disallow` and `Options.Rebuild()`. With no items, one muted note: "Choose Always Allow when the addon asks about an item, and it won't ask about it again." The rows are built at page build time; every add/remove rebuilds. This is the same description-plus-button layout Options already uses on other pages, so no custom control.

6. **Reset all clears the list.** The Home Reset button handler (`Options.lua`, next to `Settings.ResetAll()`) also empties `ns.db.char.allowedItems` (in place, so held references stay valid). Other characters' `char` tables are not touched. `ResetAll(p)` itself stays profile-only.

7. **Report.** `Guard.Report` adds `allowedItems` (`id = name` pairs, or `"none"`) to the Items section. `Export.Build`'s Presentation "scope:" line adds "allowed items per character".

8. **Strings.** New full-sentence keys: "Always Allow", "Always Allowed on this character", "Remove", the empty-list note. Added to every locale file with English fallback per `docs/localization.md`.

## Risks / Trade-offs

- [The third button's layout on Era is unverified] → Blizzard lays out button3 itself; the test plan has one check that the question shows three buttons and Always Allow works.
- [Random-suffix items share an ID] → allowing "of the Bear" allows "of the Monkey". Stated in README "Good to know".
- [An allowed item is never asked about at any price] → stated in README; #68 tracks a price guard.
- [With "Ask before buying" off there is no question, so no way to add] → stated in README; removing still works.
- [Popup taint] → the new key uses the same StaticPopup path and `preferredIndex = 3` as today's key.

## Migration Plan

Minor release (0.15.0 after 0.14.0). New `char` table only; nothing existing changes shape. Downgrading leaves an unused table.

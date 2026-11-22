# Tasks

Each new behavior: write the test, break the behavior and see the test fail for the expected reason, restore it and see it pass (AGENTS.md, Testing).

## 1. Allowed items in the guard

- [x] 1.1 Add `allowedItems = {}` to `ns.defaults.char` in `DontDoThat/Core/Addon.lua`, and `Guard.Allowed(id)`, `Guard.Allow(id, name, icon)`, `Guard.Disallow(id)` and `Guard.AllowedList()` (sorted by name) over `ns.db.char.allowedItems` in `DontDoThat/Intercepts/ItemGuard.lua`; verify with new cases in `tests/item_guard_test.lua` (add, query, remove, sort, missing `db.char` returns not allowed).
- [x] 1.2 In `Guard.Inspect`, after the mount check and before the grimoire rule, return not flagged with `why = "allowed"` when the link's item ID is allowed; verify in `tests/item_guard_test.lua` that an allowed armor item and an allowed grimoire (`tests/grimoires_test.lua`) are not flagged, another item of the same category still is, `Guard.Tooltip` adds no line for the allowed item, and the trace outcome reads `passed through: allowed`.

## 2. Always Allow on the question

- [x] 2.1 In `DontDoThat/UI/ConfirmPopup.lua`, register `DONTDOTHAT_CONFIRM_ITEM` with `button3 = L["Always Allow"]` and `OnAlt`; `Popup.Show(text, onConfirm, onCancel, onAllow)` uses it only when `onAllow` is given; `answer()` handles `"allow"` once; `Popup.Ask` passes `onAllow` through. Verify in `tests/confirm_popup_test.lua`: with `onAllow` the item key is shown and `OnAlt` runs only `onAllow`, once; without it the two-button key is shown and has no `button3` (trainer and reset questions unchanged).
- [x] 2.2 In `Guard.Run`, when `itemId(link)` returns an ID, pass an `onAllow` that calls `Guard.Allow(id, name, info.icon)`, logs `items: always allowed <id> <name>` with `ns.Log.Add`, runs `guarded(proceed)` (no `NoteSpend`, no `RecordItemAvoided`), sets the outcome `question shown, always allowed, bought`, and calls `Options.Rebuild()` when available. Verify in `tests/item_guard_test.lua`: after Always Allow the purchase runs, the item is allowed, the log line is written, a later money drop adds nothing to `itemsSpent`/performed and nothing to avoided (`tests/ledger_test.lua` helpers), and the next purchase of the same item is not asked about.
- [x] 2.3 Add "Always Allow" to every locale file per `docs/localization.md`; verify `tests/locale_test.lua` and `tests/locale_check.lua` pass.
- [x] 2.4 Update `docs/test-plan.md` with one new section (next unique number): turn on debug logging, then `/reload`; buy a flagged item at a vendor, choose Always Allow, then buy it again. `Check:` the question had three buttons and the second purchase was not asked about. `Log:` `items: always allowed <id> <name>` then `items: vendor <name> ... -> passed through: allowed`. Verify section numbers stay unique and in order.

## 3. Shopping list and Reset all

- [x] 3.1 In `Options.Watch()` (`DontDoThat/Options/Options.lua`), after the categories group, add the "Always Allowed on this character" heading, one icon-and-name description plus a "Remove" execute per allowed item (calls `Guard.Disallow` and `Options.Rebuild()`), or the empty-list note. Verify in `tests/options_test.lua`: rows appear for saved items in name order, Remove empties the row and the item is flagged again, the empty note shows with no items; `tests/options_layout_test.lua` still passes.
- [x] 3.2 In the Home Reset all handler, also empty `ns.db.char.allowedItems` in place; verify with the Home reset test in `tests/options_test.lua` (list emptied, same table). Other characters are safe by construction: AceDB's `db.char` is only the current character's table.
- [x] 3.3 Add the new strings ("Always Allowed on this character", "Remove", the empty-list note) to every locale file; verify the locale tests pass.

## 4. Report and docs

- [x] 4.1 Add `allowedItems` (`id = name`, or `"none"`) to `Guard.Report`, and "allowed items per character" to the scope line in `Export.Build` (`DontDoThat/Debug/Export.lua`); verify in `tests/export_test.lua` that the report lists an allowed item's ID and name and says none when empty.
- [x] 4.2 Update `README.md`: "At vendors and the auction house" (Always Allow, where to remove it), Settings (the Shopping list), "Your characters" (allowed items are per character), Reset all (clears them), and "Good to know" limits (random suffixes share one ID; allowed items are never asked about at any price; no way to add with "Ask before buying" off). Verify by reading each section against the specs.
- [x] 4.3 Update `docs/listing.md` description with Always Allow; verify the summary still matches the headline behavior.

## 5. Integration checks

- [x] 5.1 Run `make test`, `make check` and `openspec validate allow-specific-items --strict`; verify all pass.

## Workflow follow-up

- Archive with `/opsx:archive`; bump both TOCs to 0.15.0 (minor: new feature), after 0.14.0 ships.
- CHANGELOG `## 0.15.0`, for example: "New: **Always Allow** on the purchase question. The addon stops asking about that item on this character."
- Commit, PR referencing #29, tag `v0.15.0` on the merge commit.

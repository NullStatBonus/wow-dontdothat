## Why

When the addon leaves the game's own dialog up and adds its note (talent and pet resets, COD mail, and any guarded
dialog once "Ask before buying" is off or the client refused the addon's question), it also showed the toast or
banner. In-game the toast sat behind the game's dialog, half hidden, repeating the note.

## What Changes

- A guarded dialog that carries the addon's note gets the warning sound and chat line only, no toast or banner.
- If the note cannot be added, the toast or banner still shows.
- Debug only: each real toast or banner logs who asked for it.
- Specs corrected: talent and pet resets keep the game's dialog with a note (since 0.10.7), not the addon's question.

## Impact

- `Intercepts/Resets.lua`, `UI/Toast.lua`, `UI/AlertBanner.lua`, `tests/guarded_dialogs_test.lua`, docs.
- Ships in 0.12.1 (not yet released), so no further version bump.

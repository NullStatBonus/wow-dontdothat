# Proposal

## Why

A code audit found two behaviours that were wrong for players, one calculation done several times per redraw, and
duplicated purchase-flow code that had already drifted. What a character has done (mount marked bought, professions
asked about) was saved for every character at once, vendor and auction alerts ignored the chosen sound channel, and the
Forever auction house could silently stop being guarded when the game replaced a function after login.

## What Changes

- What a character has done (milestone overrides, professions already asked about) is saved per character. Existing
  saved values are copied into each character once, on its first login after the upgrade.
- Vendor and auction alerts play on the sound channel the player chose, like trainer alerts.
- The trainer window works its verdicts out once per refresh instead of up to four times.
- A spell the spellbook says is not learned is treated as not learned; only "the game cannot say" falls back to the
  trainer catalog.
- The Tally and Milestones pages share one cached answer per redraw; a changed setting clears it.
- On Forever the auction house wrappers are re-checked when the auction window opens, and re-applied if the game
  replaced a function.
- Alert settings, the sound-only copy, the banner fallback and the chat notice live in one module (`Prompt`) instead of
  three copies.
- The debug export has a Character section with the per-character answers.
- Removed dead code in the reset dialogs and the debug log; fixed one `_G` that should have been the passed environment.
- Added tests for the auction house wrappers and the shared prompt helpers.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: per-character state and its one-time migration; reset keeps the per-character answers; alert channel
  applies to every alert surface.
- `milestones`: the manual override is per character.
- `item-purchase-warnings`: alerts honour the channel; the auction house question is kept in place when the game
  replaces the purchase function.
- `debug-tools`: the export includes the per-character answers.

## Impact

`Core/Addon.lua`, `Model/Settings.lua`, `Model/SpellData.lua`, `Intercepts/{Context,Trainer,TrainerFilter,ItemGuard,Confirm,Resets,Auction,Prompt}.lua`
(`Prompt.lua` is new and listed in both TOCs), `Options/Options.lua`, `Rules/Engine.lua`, `Debug/{Export,Log}.lua`,
`CLAUDE.md` (stale pointer), tests. Saved variables: `db.char` gains `professionAsked`, `milestoneOverride` and
`perCharState`; the profile copies are left in place for characters not yet migrated. Version 0.11.2.

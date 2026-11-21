# Design

## Context

`Settings.ResetAll(p)` (`Model/Settings.lua:215`) sets every profile key not in `KEEP_ON_RESET` to nil. AceDB-3.0 `copyDefaults` writes plain defaults into the profile with `rawset` at load and sets no metatable for them (only `"*"`/`"**"` keys get one; `ns.defaults.profile` has none), so a deleted key stays nil. Readers that treat nil as a default are fine (`alert.style` falls back to toast, `recommendedActive ~= false`), but `ItemWarning.Flagged` treats missing `itemModes` as "off" and `minPrice` as 0, and the What to watch page shows Off. The Reset button (`Options/Options.lua:340`) then calls `Options.Refresh()`, which redraws but does not rebuild, so lists fixed at build time (Classes skips for the picked revision) stay stale.

## Goals / Non-Goals

**Goals:** after a reset the live profile holds the same values a fresh load would; pages reflect it at once.

**Non-Goals:**
- Other findings of the 2026-11-20 review, filed as issues #43–#61 (for example #44 COD dialog reuse, #45 Era trainer selection, #46 Forever talent points); #28 already covers spend recorded before a purchase happens.
- The "Worth about Xg" cache ignoring the skip revision (`Options.lua:138`): #57.

## Decisions

1. **Copy the profile defaults back ourselves, in `ResetAll`.** After clearing, for each key of the defaults' `profile` table that is now nil, set a deep copy of the default (`Settings.ResetAll(p, defaults)`, `defaults` falling back to `ns.defaults.profile`). Kept keys are never touched. Alternative: `db:RegisterDefaults(ns.defaults)` — rejected: it first strips defaults from every section, including `char` and `global`, and recreates tables that equal their default (an empty `ledger` or `catalog`), so modules holding a reference to the old table would write to a detached one. A deep copy keeps restored tables separate from `ns.defaults`, so later edits never change the defaults.
2. **Rebuild the options pages after a reset.** The button calls `Options.Rebuild()` (which also refreshes) instead of `Options.Refresh()`.
3. **Test with the real AceDB.** Extend the AceDB-backed test in `tests/warning_style_test.lua`: after a reset, `itemModes.armor` is "both", `minPrice` is 100, `ItemWarning.Flagged` flags a 2s vendor armor buy, the kept keys survive; after logout the saved profile has no `itemModes`/`minPrice` (AceDB stripped them), and a relog still reads the defaults.

4. **End a Move in progress on reset.** The button also calls `Toast.ResetPosition()`: without it, a Move started before the reset stays open, and Done writes the old position into the fresh `toast` table. Found by the Codex check of this fix.

## Risks / Trade-offs

- [A default added later with `"*"` keys] → the copy would write the wildcard key literally. None exist today; the design note in the code says so.
- [Rebuild cost] → one rebuild per confirmed reset; negligible.

## Migration Plan

Patch release 0.13.4. Nothing saved changes shape.

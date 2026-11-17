# Design

## Context

`Rules.Evaluate` returns "keep" unless `profile.milestone.state == "active"` (`Rules/Engine.lua:297`), so trainers already follow the stop point. `ItemGuard` (`Guard.Inspect`) and `Resets` (`active(kind)`) never build a profile; they check only the addon switch and their own switches. `Resets.lua:186` already passes the quoted price to `kind.avoided`, but the talent and pet handlers drop it and `Ledger.Record*Avoided` has no parameter for it.

## Goals / Non-Goals

**Goals:** one milestone check shared by every guard; quoted reset prices in avoided savings.

**Non-Goals:** caching the profile; changing what counts as milestone completion; a true baseline for the tally reset (spell totals stay derived from the spellbook); AH browse marks (#27); confirming spend after the purchase (#28).

## Decisions (added scope)

- **Reset switches** reuse the `guard` table: `talent` and `pet` keys, default true in `Core/Addon.lua`, so existing saves read as on with no migration. The kinds in `Resets.lua` gain `guard = "talent"` / `guard = "pet"`.
- **Hunter-only rows** use the option's `hidden` with the player's class token. Hiding is display only: the saved value is kept.
- **Tally reset text** is a wording change only.

## Decisions

- **One helper, `Context.Saving(env)`**: returns true while warnings should run: a profile exists and its milestone state is "active". It reuses `Context.Profile`, so the stop point, the riding detection and the checkboxes are read exactly as trainers read them. Alternative (a cheaper milestone-only reader) rejected: it would duplicate the riding/override logic and could drift.
- **Unsupported class -> no warnings** (`Context.Profile` returns nil), matching the existing requirement.
- **Error -> keep warning**: if building the profile throws, the guards behave as today (warn). A bug in the check must not silently disable the safeguard.
- **Where it is checked**: `Guard.Inspect` sets `info.why = "mount bought"` (shows in the debug trace and `/ddt export`); `Resets.active` returns false, which already makes the game's own dialog run untouched and shows in `Resets.Status`.
- **Ledger**: `RecordRespecAvoided(state, tbl, quoted)` and `RecordPetResetAvoided(state, tbl, quoted)` use `quoted` when it is a number, mirroring `Record*Performed(state, tbl, actualCost)`. Existing callers keep working.

## Risks / Trade-offs

- `Context.Profile` reads talents and skills on each guarded purchase. It is called only when a purchase or dialog happens, not per frame; acceptable.
- Savings already recorded at the estimated price are not recalculated.

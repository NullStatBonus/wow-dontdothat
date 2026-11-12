# Design

## Context

All characters share one AceDB profile ("Default"). Trainer refreshes call the verdict computation from the filter and
from the overlay; each call rebuilds the player profile. Vendor, auction and trainer guards each carried their own copy
of the alert-settings mapping, the sound-only copy, the banner fallback and the chat notice.

## Goals / Non-Goals

**Goals:** per-character answers without losing existing data; fewer repeated computations without stale results; one
copy of the shared prompt pieces; keep the auction guard in place on Forever.

**Non-Goals:** merging the trainer, item and reset question flows into one `Run`; replacing the vendor and auction
function wrappers (the taint risk stays and needs in-game work); trimming `Debug/Capture.lua` and `Debug/Probe.lua`;
moving `specOverride` (keyed by class, left in the profile).

## Decisions

- **Per-character migration copies, never moves.** `Settings.MigrateCharState` copies the profile values into `db.char`
  once per character (`char.perCharState`). The profile copies stay, and Reset all keeps them, because characters that
  have not logged in since the upgrade still migrate from them. Moving would lose them for those characters.
- **One compute per refresh pass, no cross-event cache.** `SafeRefresh` opens a pass; `TrainerOverlay.Compute` inside it
  is memoised, outside it is always fresh (the Train button asks at click time). A pass started inside another gets its
  own. A cache kept across events would need invalidation on many events and risks stale marks.
- **Options pages reuse the existing 0.25 s `recent()` cache**, and a changed setting clears it so the status line never
  lags a toggle.
- **`Prompt.lua` extracts only the identical pieces.** The flows differ in real ways (profession-asked marks, the
  `confirming` flag, ledger recording, trace entries), so they stay separate.
- **Auction wrappers are re-applied, not assumed.** The export showed `PlaceBid` wrapped at login and later not ours; the
  wrapper now re-checks on `AUCTION_HOUSE_SHOW` and wraps whatever function is current unless it is already ours.
  Diagnostics (`modernPlaceBidMade`, write-then-read log line) stay to show future replacements.

## Risks / Trade-offs

- Dead profile keys remain until every character has migrated; a later release may drop them.
- The re-check runs only when the auction window opens; a replacement after that is not caught until the next opening.
- The Forever auction path is still a wrapper over a game function, with the taint risk noted in the audit.

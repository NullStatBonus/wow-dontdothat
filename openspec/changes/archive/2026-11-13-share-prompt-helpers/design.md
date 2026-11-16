# Design

## Decisions

- `Prompt.AlertSettings()` returns a fresh table each call, so callers may still change it (Resets turns the banner off when its own question is up; Confirm adds `alertTiers`).
- `Prompt.SoundOnly` copies, never mutates, the settings it is given.
- `Prompt.BannerInstead` and `Prompt.Say` keep the existing `pcall` guards, so a missing banner or chat frame still never breaks a purchase.
- `Confirm.AlertSettings` remains, delegating to the shared helper, so existing callers keep working.
- Resets is changed only where the helper is adopted; its other cleanups are left to a later change.

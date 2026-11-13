# Proposal

## Why

The trainer, item (vendor and auction house) and reset guards each carry their own copy of the same four pieces: mapping the alert settings from the profile, the sound-only copy used while a question is on screen, the banner fallback when no question can be shown, and the chat notice when a guard switches itself off. The copies can drift apart; one shared module keeps them identical.

## What Changes

- New `Intercepts/Prompt.lua` (loaded before `Confirm.lua` in both TOCs) with `AlertSettings`, `SoundOnly`, `BannerInstead` and `Say`.
- `ItemGuard.lua`, `Confirm.lua` and `Resets.lua` call it instead of their own copies. `Confirm.AlertSettings` stays as an alias.
- No behavior change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None (pure refactor; `skip_specs: true`).

## Impact

`DontDoThat/Intercepts/{Prompt,ItemGuard,Confirm,Resets}.lua`, both TOCs, and the test loaders that load those guards.

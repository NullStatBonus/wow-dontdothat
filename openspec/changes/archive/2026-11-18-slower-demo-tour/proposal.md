# Proposal

## Why

`/ddt demo` shows the marks, tooltip and question at once, then four notices two seconds apart, and clears everything after ten seconds. A notice is replaced before it can be read, and nothing says which sample is which.

## What Changes

- The tour shows one sample at a time, five seconds apart: four notices (one per tier), then the pinned explanation, then the marks with their tooltip, then the question.
- Each step adds one chat line that says what is on screen, for example "Demo 2 of 7: a toast for a spell that is not worth buying yet."
- The tour ends about 40 seconds after it starts; a single `/ddt preview` still ends within ten seconds.
- Patch release (changes existing behavior).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `visual-preview`: the demo tour is paced one sample at a time with a caption per step.

## Impact

- `DontDoThat/UI/Demo.lua` (`Demo.Run`), `tests/demo_test.lua`, README command table, `docs/test-plan.md` section 14.
- No setting, no saved-data change.

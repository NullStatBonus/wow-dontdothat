## Why

On a class page, the lists "Save your gold", "Not worth buying yet" and "Ranks to skip" show a switch for each spell, and the row text names ranks. The switch is saved for the whole spell (`ruleOff.abilities` is keyed by spell), so it switches every rank. A player may expect it to change only the ranks on that row (issue #37).

## What Changes

- Keep the behavior: the switch stays per spell. A 1.0 release freezes that meaning, so a later per-rank control (issue #36) adds a new setting and does not change this one.
- Say it on the page: a muted line above the rows of each list that has switches reads "Each switch covers every rank of the spell, not only the ranks listed here."
- No saved data changes. The TOC stays at 0.15.0 until 1.0.0 is released.

## Capabilities

### Modified Capabilities
- `addon-settings`: the class page says what an ability switch covers.

## Impact

- `DontDoThat/Options/Options.lua` (`category`), `tests/options_test.lua`, `README.md`.

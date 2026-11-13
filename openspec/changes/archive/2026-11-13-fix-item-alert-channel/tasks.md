# Tasks

## 1. Fix

- [x] 1.1 Add `alertChannel = a.channel` to `alertSettings` in `DontDoThat/Intercepts/ItemGuard.lua`.
- [x] 1.2 Test in `tests/items_test.lua` that a flagged purchase with `profile.alert.channel = "Dialog"` passes `alertChannel = "Dialog"` to `Alert.Trigger`.

## 2. Docs and checks

- [x] 2.1 Add a `docs/test-plan.md` check: pick a non-Master sound channel, buy a flagged vendor item, the sound follows the channel.
- [x] 2.2 Run `luajit tests/run.lua` and `tools/check-*.sh`.

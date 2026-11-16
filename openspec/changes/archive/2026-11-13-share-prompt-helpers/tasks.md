# Tasks

## 1. Shared helper

- [x] 1.1 Add `Intercepts/Prompt.lua` and list it before `Intercepts\Confirm.lua` in both TOCs
- [x] 1.2 Use it in `ItemGuard.lua`, `Confirm.lua` (keeping `Confirm.AlertSettings`) and `Resets.lua`

## 2. Tests

- [x] 2.1 Add `tests/prompt_test.lua`
- [x] 2.2 Load `Intercepts/Prompt.lua` in the test loaders that need it; `luajit tests/run.lua` and `tools/check-*.sh` pass

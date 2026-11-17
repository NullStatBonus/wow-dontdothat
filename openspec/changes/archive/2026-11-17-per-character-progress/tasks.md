# Tasks

## 1. Storage

- [x] 1.1 Add `milestoneOverride = {}` and `professionAsked = {}` to the char defaults in `Core/Addon.lua`
- [x] 1.2 Read both from `db.char` in `Intercepts/Context.lua`; write from `db.char` in the milestone checkboxes (`Options.lua`) and `Settings.MarkProfessionAsked`
- [x] 1.3 Update `KEEP_ON_RESET` and any export or report that lists these values

## 2. Migration

- [x] 2.1 On login, once per character (`db.char.migratedMarks`), copy shared level 40 or 60 marks when the character's level is at least that level
- [x] 2.2 Tests: level 60 character keeps its mark; level 25 alt does not get the level 40 mark; runs once; profession answers start empty

## 3. Docs and checks

- [x] 3.1 README "Good to know": marks and profession answers are per character
- [x] 3.2 `docs/test-plan.md` new section: main and alt checks
- [x] 3.3 Run `make test` and `make check`

## Workflow follow-up

- Archive with `/opsx:archive`; patch bump

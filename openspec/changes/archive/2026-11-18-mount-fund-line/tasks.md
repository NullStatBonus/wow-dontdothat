# Tasks

## 1. Goal helper

- [x] 1.1 Add `Milestones.Target(env)` returning `level, copper, cut` for the active milestone, or nil (`Milestones.Goal` already exists for one level's price)
- [x] 1.2 Use it in `Options.MilestoneProgress`; Progress output unchanged

## 2. Question line

- [x] 2.1 In `Popup.Ask`, add the mount fund line after the earn-back line when gold minus cost is below the goal; pcall-guarded
- [x] 2.2 Add the string to Locales
- [x] 2.4 The `/ddt demo` and `/ddt preview prompt` sample question shows the line: the player's own when short, else an example
- [x] 2.3 Tests: still short, crosses below, still enough (no line), unknown price (no line), no active milestone (no line)

## 3. Docs and checks

- [x] 3.1 README "Warnings you can see and hear"; `docs/listing.md` if it describes the question; `docs/test-plan.md` new section
- [x] 3.2 Run `make test` and `make check`

## Workflow follow-up

- Archive with `/opsx:archive` after `milestone-gates-all-guards`; minor bump (0.13.0)

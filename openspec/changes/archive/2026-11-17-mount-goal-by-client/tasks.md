# Tasks

## 1. Per-client goals

- [x] 1.1 `Milestones.Client(env)` from the interface number
- [x] 1.2 `Milestones.EraDefaults` next to the Forever `Milestones.Defaults`
- [x] 1.3 `Milestones.Goal(level, class, client, standing)` used by `Options.MilestoneProgress`

## 2. Discounts and detection

- [x] 2.1 `Adapter.ReadDiscounts(env)`: home-faction standing and PvP rank; pcall-guarded
- [x] 2.2 Discounts apply to default targets only; Progress shows the discount
- [x] 2.3 Era level 60 detection: an epic mount item in the bags or bank (replaces the riding skill 150 check)
- [x] 2.4 Tests: Era and Forever goals, discounts, class target, unreadable standing, Era detection, Progress line

## 3. Docs and checks

- [x] 3.1 `docs/test-plan.md` section 19; CHANGELOG
- [x] 3.2 `make test` and `make check`

# Tasks

## 1. Settings storage and defaults

- [x] 1.1 Add `ruleOff`, `specOverride`, `tuning` (supersessionWindow 4, nearCapMargin 25, stopAfter 60, promptTiers `{ defer = true }`) and `alert.channel` to `ns.defaults.profile` in `Core/Addon.lua`; fix the Alerts cooldown fallback (`or 5`) and the `Alert.Trigger` fallback to the default of 3
- [x] 1.2 Add a small settings reader (`PromptsFor(tier)`, validated number getters) that tolerates a missing database, with a test

## 2. Engine and profile

- [x] 2.1 `PlayerProfile.Build` accepts player rule settings and exposes them as `profile.rules`; `Context.Profile` passes the saved ones and applies `specOverride` as `plausibleSpecs` only when the pick is one of the class's specs
- [x] 2.2 `Engine`: switched-off ability returns keep with source `disabled` first; skip off tags; skip off rule kinds (skipRank, offSpec, supersession, professionCap)
- [x] 2.3 `Engine`: supersession window and profession margin read the validated player value, else rule data
- [x] 2.4 `Milestones.State` takes `stopAfter`; `Context.Profile` passes it
- [x] 2.5 Engine, profile and milestone tests: each scenario in the rule-engine and milestones delta specs, plus "defaults leave every existing verdict unchanged" run over the Hunter and profession data

## 3. Prompts and alerts follow chosen tiers

- [x] 3.1 `Confirm.Decide` and `Alert.Trigger` use `PromptsFor(tier)` instead of `tier == "defer"`; `keep` never prompts
- [x] 3.2 Alert channel read from `alert.channel`, with fallback to Master for unknown values
- [x] 3.3 Tests: extra tier prompts and sounds, no tiers means no prompt or sound with badges unchanged, unknown channel falls back

## 4. Page template and General

- [x] 4.1 Add `pageTitle`, `section`, `row` and `note` builders with one type scale and one gray; remove spacer rows and the `11.5` order hack
- [x] 4.2 Convert General, Alerts, Purchases (renamed from Items), Milestones, Tally, Debug and About to the template; keep every existing control and behavior
- [x] 4.3 General: Tuning section (window, margin, stop-after-mount, tier checkboxes) with a reset control
- [x] 4.4 Alerts: sound channel dropdown
- [x] 4.5 Update `tests/options_test.lua` for the new structure, controls, defaults and reset

## 5. Rules page

- [x] 5.1 Replace the read-only lists with switch rows (icon, name, reason) per ability, keeping the Worth buying / Save your gold / Not worth buying yet / Ranks to skip grouping
- [x] 5.2 Per-class tag switches, rule-kind switches, a "My spec" dropdown built from `classData.specs`, and a per-class reset
- [x] 5.3 Profession pages get a skill-cap switch; update the intro text, which says these can't be changed
- [x] 5.4 Options tests for the switches, dropdown options and resets

## 6. Verify and finish

- [x] 6.1 Run the full test suite and `tools/check-toc.sh`, `tools/check-tocs-match.sh`
- [ ] 6.2 Manual in-game pass over all pages in both clients (look, switches taking effect without a reload)
- [x] 6.3 At archive, bump `## Version:` to 0.4.0 in both TOCs and name it in the commit message

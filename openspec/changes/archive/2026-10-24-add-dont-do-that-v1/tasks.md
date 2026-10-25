# Tasks

## 1. Scaffold and bundled libraries

- [x] 1.1 Create the `DontDoThat/` addon folder, `DontDoThat_Forever.toc` (`## Interface: 16001`, SavedVariables, load order) and the module directory layout from design.md; verify every file listed in the TOC exists and the TOC parses (checked by a script that resolves each listed path).
- [ ] 1.2 Bundle LibStub, CallbackHandler, AceAddon-3.0, AceDB-3.0, AceHook-3.0, AceEvent-3.0, AceConsole-3.0, AceConfig-3.0 (with AceConfigDialog and AceGUI) under `Libs/` with one `embeds.xml`, plus a `.pkgmeta`; verify in game that the addon loads with no Lua errors (`/console scriptErrors 1`) and `/ddt` prints a version line.
- [x] 1.3 Add a pure-Lua test harness (plain `lua` or `busted`) runnable outside the game with `Rules/` loaded and no WoW globals; verify a sample test passes from the command line.

## 2. Debug tooling and the in-game probe (first, to resolve API unknowns)

- [x] 2.1 Implement `Debug/Log` as a bounded ring buffer persisted in SavedVariables with `/ddt debug on|off` and `/ddt clear`; verify with a unit test that the oldest entries drop past the limit and that nothing prints to chat when debug is off.
- [x] 2.2 Implement `Debug/Probe` (`/ddt probe`): build info and Interface number, existence of trainer, talent, respec, and tooltip-related APIs, and `pcall`-wrapped read-only calls recording errors and restricted values; verify in game that the report completes even when a probed call errors.
- [x] 2.3 Add trainer snapshot (services, level, cost, rank, purchasable-out-of-order observation), talent points per tree, observed respec quotes, and interception outcomes to the probe; verify against an open trainer window in game.
- [x] 2.4 Implement `Debug/Export` (`/ddt export`): a copyable, preselected text window including settings, ledger, log, probe output, and library versions; verify in game that the text can be selected and copied with Ctrl+C.
- [ ] 2.5 Run the probe in the Forever client, record findings in the change's design notes (or a follow-up task list), and decide the Intercept adapter implementation; verify the findings document answers each open question in proposal.md Impact.

## 3. Rules engine (pure Lua)

- [x] 3.1 Define the rule data schema (rotations with core and situational lists, tags, overrides, tier defaults, rank tables, cost estimates, "needs review" flag) and document it in `docs/rules-data.md`; verify with a schema-validation test that sample data loads and malformed data is rejected with a clear message.
- [x] 3.2 Implement `Rules/Engine` verdicts with precedence override > rotation > tags > supersession > keep, tiers, and reasons; verify unit tests for each precedence scenario in `specs/rule-engine/spec.md`.
- [x] 3.3 Implement rank supersession with a configurable window default of 4; verify unit tests for Serpent Sting rank 8 (flagged) and ranks 1 to 7 (not flagged).
- [x] 3.4 Add the Hunter data file: BM rotation from the cited sources, Marksmanship and Survival rotations flagged "needs review", tag defaults (PvP defer-low-value, raid or group defer), and overrides (Keep: Serpent Sting, Hunter's Mark, traps, Deterrence, Disengage, Aspect of the Pack; Defer: Distracting Shot, Tranquilizing Shot, Volley, Aspect of the Wild); verify unit tests for each classification in the Hunter table agreed in the exploration.
- [x] 3.5 Add Herbalism and Skinning data with rank-tier (Apprentice to Artisan) rules and costs as editable data; verify unit tests that a rank-tier is flagged only while a skill is far from its cap.
- [x] 3.6 Encode explicit rank skips (rule data field, schema check, engine step checked before overrides) and the Hunter rank-skip map, with Wing Clip kept at every rank; verified with unit tests for each skipped and neighbouring rank and for the schema.
- [ ] 3.7 Bundle the class's spell tables (IDs, ranks, levels, prices) generated from the game's database tables by `tools/build-spell-data.py`, use the IDs for icons and spellbook "learned" checks, and add a Spell data check section to the debug report; verify in game that icons show without a trainer visit and that the report's sample spells show icons and believable known flags.

## 4. Player model

- [ ] 4.1 Implement `Model/PlayerProfile` (class, level, professions, static armor and weapon proficiency stubs per class); verify a unit test builds a profile from mock inputs and in game `/ddt export` shows it.
- [x] 4.2 Implement `Model/SpecInference` with lead margin, hysteresis, ambiguity (all specs plausible), dual specialization union, and role-aware depth conditions; verify unit tests for each scenario in `specs/spec-inference/spec.md`.
- [ ] 4.3 Wire talent-change events to recompute plausible specs using the adapter chosen in task 2.5; verify in game that spending a talent point updates the inferred spec in `/ddt export`.
- [ ] 4.4 Implement `Model/Milestones` (level 40 and level 60 targets from data, continuous deferral that is active until the level 60 mount and then finished, riding-learned detection, manual override); verify unit tests for state transitions and in game that learning riding advances the state.

- [ ] 4.5 Detect the riding skills by spell name to move the milestone along, with manual "I've already bought it" switches on the Milestones page; verify in game that learning Apprentice Riding advances the status, and that the switches work if it doesn't.

## 5. Ledger

- [x] 5.1 Implement `Model/Ledger` with the state-derived tally (available and unlearned, filtered by rules and level), verified versus projected by higher-rank-learned, and spent-against totals; verify unit tests for each scenario in `specs/savings-ledger/spec.md`.
- [x] 5.2 Implement the trainer-cost cache with estimate fallback and "estimate" marking; verify a unit test that an observed cost overrides an estimate.
- [x] 5.3 Implement respec counters and the editable escalating-cost table with cap; verify unit tests for avoided and performed counts and for the cap.
- [ ] 5.4 Persist and reset the ledger via AceDB; verify the ledger survives `/reload` and zeroes on reset.
- [x] 5.5 Track pet training resets in the ledger with their own counters and an editable escalating-cost table with cap, kept separate from talent respecs; verified with unit tests for the cost table, the cap, the counters, and the totals.

- [ ] 5.6 Keep a catalog of every trainer row seen, work out which were bought from rows that disappeared (guarded against collapsed categories and switched-off filters), and show Kept for sure, Kept so far and Spent on the Tally page with a reset button; verify in game that the numbers move as you skip and buy, and that closing categories or unticking filters never counts as buying.

## 6. Intercepts and warnings

- [x] 6.1 Implement `Intercepts/Adapter` against the client shape determined in task 2.5 (services, costs, ranks, talent read, learn) with all calls `pcall`-guarded; verify in game that the adapter reports trainer services without errors.
- [x] 6.2 Implement `UI/Badge`, `UI/InfoBubble` (mouseover plus click-to-pin), and `UI/TooltipAugment`; verify in game that a flagged trainer row shows the badge, reason, and cost.
- [ ] 6.3 Implement `Intercepts/Trainer` for class trainers, beast training, and profession trainers with badge and tooltip; verify in game for Hunter, Herbalism, and Skinning rows.
- [ ] 6.4 Implement `Intercepts/Talents` and `Intercepts/Respec` warnings (and confirmation where safe per the probe); verify in game that the respec dialog shows the estimated escalating cost.
- [ ] 6.5 Implement `UI/ConfirmPopup` for defer-tier purchases, wired so the action proceeds only on confirm, and with graceful degradation to badge and tooltip where interception is unsafe; verify in game that cancel prevents the purchase and confirm records spent-against.
- [ ] 6.6 Ensure no default-UI breakage: errors in warning logic are caught and logged; verify by forcing an error with debug on and confirming the default trainer still works.
- [x] 6.7 Implement the pure trainer-filter visibility logic (full service list plus verdicts in; visible service indexes and hidden count out; hides defer and deferLow, keeps keep and informational, preserves original indexes, shows everything when the addon is off or the deferral is finished); verify with unit tests for each scenario in the Recommended filter requirements of `specs/purchase-warnings/spec.md`.
- [ ] 6.8 Add the "Recommended" entry to the class and profession trainer filter list (checked by default) and lay out rows from the visibility mapping, built against the row structure found in task 6.1; verify in game that the entry appears, checking hides flagged rows, unchecking restores them, and buying a visible row purchases the spell it shows.
- [ ] 6.9 Make the filter degrade safely: if the dropdown entry or row layout cannot be installed, fall back to badges and tooltips, hide nothing, and log the reason; verify by forcing a failure with debug on and confirming the default trainer filters still work, and with a debug-build check that every clickable row's service index matches the service it displays.
- [ ] 6.10 Warn on the Pet Trainer's untrain option (estimated cost, confirmation prompt where interception is possible) and record avoided or performed pet resets in the ledger, using the confirmation dialog name and price found by the debug capture; verify in game at a Pet Trainer that the warning shows the quoted price, cancel records an avoided reset, and confirm records a performed one.

- [ ] 6.11 Mark profession trainer rows (Herbalism, Skinning rank tiers); blocked until an export from those trainers shows how their rows are named.

## 7. Alerts

- [ ] 7.1 Implement `Data/Sounds.lua` registry and playback with a Master-channel route and fallback sound; verify in game that Test plays each registered sound and an invalid entry falls back.
- [ ] 7.2 Implement `UI/AlertBanner` (centered, fading, item, cost, reason); verify in game that an attempt to buy a flagged spell shows it.
- [ ] 7.3 Trigger alerts on attempts only with a per-action cooldown; verify in game that hover is silent and a repeat within the cooldown does not replay.

## 8. Settings

- [ ] 8.1 Implement the AceDB defaults and the General page (master enable and three independent toggles, all on); verify in game that each toggle takes effect without a reload.
- [ ] 8.2 Implement the Alerts page (sound select, Test, banner toggle); verify in game.
- [ ] 8.3 Implement the Rules page (read-only; class, spec or profession, rule, tier, reason, tags, review status) and the Milestones page; verify in game that Hunter rules display and "needs review" is labeled.
- [ ] 8.4 Implement the Tally, Debug, and About pages (About explains the signals, tiers, and verified versus projected); verify in game that the Tally shows verified and projected separately and reset works.
- [x] 8.5 Register `/ddt` and `/dontdothat`; verify in game that both open settings.
- [ ] 8.6 Add the Recommended filter toggle to the General page, kept in sync with the in-trainer checkbox; verify in game that turning it off shows all trainer rows and that the setting persists across `/reload`.

## 9. Integration and release readiness

- [x] 9.1 Run the full pure-Lua test suite and verify it passes with no failures.
- [ ] 9.2 End-to-end in game as a Hunter below level 40: verify that a deferred spell is badged (and hidden while the Recommended filter is checked), alerts on attempt, a Keep spell is silent, the tally updates, milestone completion silences warnings, and `/ddt export` returns a complete report.
- [ ] 9.3 Write a README covering install, settings, commands, and known limitations (unverified costs, rotations needing review); verify its install and command steps work as written on a clean setup.

## Workflow follow-up

- Return the first probe export to refine costs, spell IDs, and rotations (a follow-up change).
- Archive the change after review and in-game verification.

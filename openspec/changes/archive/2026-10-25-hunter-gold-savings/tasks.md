## 1. Rank skips

- [x] 1.1 Add Wing Clip ranks 2, 3 and Freezing Trap ranks 2, 3 to `skipRanks` in `DontDoThat/Rules/Data/Hunter.lua` and fix the "deliberately not skipped" comment
- [x] 1.2 Add a test that Wing Clip rank 1 is kept and ranks 2, 3 and Freezing Trap ranks 2, 3 are defer with the skip-rank source

## 2. Talent-gated spells

- [x] 2.1 Add `talentSpells` (list of talent-only spell names) for Aimed Shot, Scatter Shot, Wyvern Sting, Intimidation, Bestial Wrath, Counterattack in Hunter.lua, and allow it in `Rules/Schema.lua`
- [x] 2.2 Read active talents by name in the adapter and carry them as `activeTalents` through `PlayerProfile.Build`
- [x] 2.3 In `Rules/Engine.lua`, ignore rotation membership for a talent spell unless its talent is active
- [x] 2.4 Add tests for a talent spell with and without its talent

## 3. One-time profession warning

- [x] 3.1 Add the gathering set and per-profession reason table to rule data, with a generic fallback reason
- [x] 3.2 Add the `professionLearn` evaluation to `Rules/Engine.lua`, returning a defer verdict with the profession-specific reason
- [x] 3.3 Recognise the first-tier row of a profession in the trainer adapter and build the action in `Intercepts/Trainer.lua`
- [x] 3.4 Prompt through the existing confirmation path in `Intercepts/Confirm.lua`, and record `professionAsked` in saved settings only when a question was answered
- [x] 3.5 Fall back to badge and tooltip without recording when the prompt is unavailable or turned off
- [x] 3.6 Add tests: first ask, second ask suppressed, gathering professions exempt, switches off records nothing

## 4. Verify and release

- [ ] 4.1 Check the profession trainer row names and talent lookup on a real client with the debug capture tools, and update the test plan
- [x] 4.2 At archive, bump `## Version:` to 0.5.0 in both `.toc` files and name it in the commit message

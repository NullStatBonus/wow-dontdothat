# Tasks

## 1. Stop point on every surface

- [x] 1.1 Add `Context.Saving(env)` in `Intercepts/Context.lua`: true when `Context.Profile(env)` gives a profile whose milestone is active; false for no profile; true if building the profile errors
- [x] 1.2 In `Guard.Inspect` (`Intercepts/ItemGuard.lua`), after the on/off and Shopping checks, return `info.why = "mount bought"` when not saving (also covers the merchant tooltip)
- [x] 1.3 In `Resets.active` (`Intercepts/Resets.lua`), return false when not saving
- [x] 1.4 Tests: flagged item passes through after the milestone is finished, and asks again once it is active; each reset kind leaves the game's dialog alone when finished; profile error still warns

## 2. Quoted reset prices

- [x] 2.1 Add a `quoted` parameter to `Ledger.RecordRespecAvoided` and `Ledger.RecordPetResetAvoided`; use it when it is a number
- [x] 2.2 Pass the cost through in the talent and pet `avoided` handlers in `Resets.lua`
- [x] 2.3 Tests in `tests/ledger_test.lua`: quoted price wins; nil quote falls back to the table

## 3. Docs and checks

- [x] 3.0 `README.md:34`: remove "Marks profession ranks that you cannot use yet." (the Professions part is already described by the first-lesson line under "Other ways to lose gold")
- [x] 3.1 `README.md`: say the stop point ends every warning, not only trainer marks
- [x] 3.2 `docs/test-plan.md`: add section 17 with in-game checks (stop at 40, buy an AH item, bank slot, respec; clear the checkbox and see warnings return; decline a respec and see the quoted price in Progress)
- [x] 3.3 Run `make test` and `make check`

## 4. Added scope

- [x] 4.1 Add `guard = "talent"` and `guard = "pet"` to the reset kinds in `Resets.lua`; default `talent = true, pet = true` in `Core/Addon.lua`
- [x] 4.2 Add "Resetting talents" and "Resetting pet skills" toggles under What to watch > Other; hide stable slot and pet skill reset for non-Hunters
- [x] 4.3 Reword the "Start the count over" note and confirm text to say spell totals are recalculated from the spellbook (update Locales)
- [x] 4.4 Tests: switched-off talent/pet kinds leave the game's dialog alone; Hunter-only toggles hidden for other classes
- [x] 4.5 Docs: README settings/Other list, `docs/listing.md` if it lists the guarded sinks, test-plan section 17 checks, debug report header lists the new switches
- [x] 4.6 Run `make test` and `make check`

## 5. Minimum price stays 1 silver

- [x] 5.1 Keep `minPrice = 100`; fix its comment in `Core/Addon.lua` to say 1 silver
- [x] 5.2 `README.md`: "less than **1 silver**"; check `docs/listing.md` for the same claim

## Workflow follow-up

- Archive with `/opsx:archive`: sync specs, bump both TOCs to 0.12.1, write the CHANGELOG section, then commit

## 1. Settings model

- [x] 1.1 Add `Settings.Nudge()` and `Settings.SetNudge(name)` in `DontDoThat/Model/Settings.lua`, deriving the level from marks, "Ask before buying" and prompt tiers, with `custom` writing nothing
- [x] 1.2 Add `Settings.Watching(area)` and a setter for `watch.spells`, `watch.professions` and `watch.shopping`, on unless saved as false
- [x] 1.3 Tests in `tests/settings_test.lua`: each nudge level, Custom, sound not affecting the level, area defaults

## 2. Area switches take effect

- [x] 2.1 Skip spell rows in `Intercepts/Trainer.lua` (marks, filter, prompt) when Spells is off
- [x] 2.2 Skip profession tier and learn rows when Professions is off
- [x] 2.3 Skip vendor and auction item guards when Shopping is off
- [x] 2.4 Tests for each area switch: off stops the warning, on again restores it with the inner settings untouched

## 3. Pages

- [x] 3.1 Build Home in `Options/Options.lua`: on/off, nudge choice with the Custom line, stop-after-mount
- [x] 3.2 Build What to watch: Spells (switch and Recommended filter), Professions, Shopping (switch, minimum price, collapsed Choose categories), Other (bank, stable, COD), and one reset control
- [x] 3.3 Build Progress from the existing Milestones and Tally content
- [x] 3.4 Build Advanced: Sound & messages, Tuning (window, margin, prompt tiers, reset), Rules, Debug
- [x] 3.5 Update `Options.Pages()`, the Blizzard registration and the `/ddt` tree to the five pages
- [x] 3.6 Reword visible labels and introductions in plain language, and keep the shared page look
- [x] 3.7 Update `tests/options_test.lua` for the five pages, the collapsed categories and the Advanced contents

## 4. Verify and release

- [ ] 4.1 Open the settings in game: check that Advanced's nested Rules tree fits the panel, and use the fallback from the design if not
- [x] 4.2 At archive, bump `## Version:` to 0.6.0 in both `.toc` files and name it in the commit message

## 1. Home

- [x] 1.1 Reword Home in `Options/Options.lua`: option descriptions on the radio labels, the new heading, the stop choice without a repeated label, and a Custom label and note that say what is set and where to change it
- [x] 1.2 Add `Settings.ResetAll` and the "Reset all settings" control with confirmation on Home

## 2. Remove other resets

- [x] 2.1 Remove the reset controls from Tuning, What to watch and the Rules page (per class and all), keeping the Tally's count reset

## 3. Progress and debug

- [x] 3.1 Show each Progress heading once
- [x] 3.2 Add `Settings.ClearDebug` and call it when the database loads in `Core/Addon.lua`; include it in the reset

## 4. Tests and release

- [x] 4.1 Update `tests/options_test.lua`, `tests/items_test.lua` and `tests/settings_test.lua`: new Home labels and Custom text, reset-all behaviour and what it keeps, no other reset controls, Progress headings, debug cleared
- [x] 4.2 At archive, bump `## Version:` to 0.8.1 in both `.toc` files and name it in the commit message

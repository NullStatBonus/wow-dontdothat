# Proposal

## Why

The Home page reads awkwardly: the explanations sit far below the options, "When to stop" says its name twice, and when the settings match none of the three levels it says "You changed this in Advanced", which tells the player nothing. Progress prints each section heading twice. Resets are scattered across five pages, so there is no obvious way to start over. Debug recording can be left on from an earlier session.

## What Changes

- Home: put each explanation on its option, reword the heading to "When you're about to buy something that can wait", and say what is set when the choice is Custom (marks, questions, and which tiers ask) with where to change it.
- Home: the stop choice reads "After my level 60 mount" under the heading "When to stop warning me", with no repeated label.
- Progress: show each section heading once.
- Replace the reset buttons on Tuning, What to watch and Rules with one "Reset all settings" on Home. It restores every setting to its default and keeps the tally and what the addon already knows you have done (professions asked about, mounts marked complete). The Tally's own "Start the count over" stays, since it clears data, not settings.
- Debug recording and item recording switch off at every login, and the reset turns them off too.
- Out of scope: anything about rules, data or warnings themselves.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: Home wording and Custom explanation, one reset on Home, no other reset controls, Progress headings once.
- `debug-tools`: debug recording is off at every login.

## Impact

- `DontDoThat/Options/Options.lua`: Home, Tuning, What to watch, Rules, Progress.
- `DontDoThat/Model/Settings.lua`: reset-all and the login clearing of debug flags.
- `DontDoThat/Core/Addon.lua`: clear the debug flags at login.
- `tests/options_test.lua`, `tests/items_test.lua`, `tests/settings_test.lua`: updated for the removed resets and new Home.
- `CLAUDE.md` release rule: modifies existing behavior only, so 0.8.0 becomes 0.8.1 in both `.toc` files at archive.

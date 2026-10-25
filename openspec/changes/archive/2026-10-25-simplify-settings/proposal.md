# Proposal

## Why

The settings work but are hard to understand. Five separate controls decide how pushy the addon is (master, "Ask before buying", sound, on-screen message, and which tiers ask), the same choice is spread over General, Alerts and Purchases, and eight pages list every control at the same level. A player who wants "ask me before I waste gold" has to read all of it. Most players should see a few clear choices, with the deep controls one deliberate step away.

## What Changes

- Replace the eight pages (General, Alerts, Purchases, Rules, Milestones, Tally, Debug, About) with five: **Home**, **What to watch**, **Progress**, **Advanced**, **About**.
- **Home** holds the on/off switch, a three-way "how firmly should I nudge you?" choice (Just mark things, Ask me first (default), Ask about everything) and "Stop warning me after".
- The nudge choice is a view over today's saved settings (marks, "Ask before buying" and the prompt tiers). A fourth entry, **Custom**, shows when the saved values match none of the three. No saved keys change, so nothing migrates.
- **What to watch** has four areas: **Spells**, **Professions**, **Shopping**, **Other**. Each can be turned off. Shopping carries the minimum price and a collapsed "Choose categories" holding the 13 dropdowns. Other holds the bank slot, stable slot and COD mail switches.
- **Progress** combines Milestones and Tally.
- **Advanced** holds Sound & messages (sound, channel, cooldown, on-screen message), Tuning (rank window, profession margin, prompt tiers), Rules (the existing tree) and Debug.
- Sound stays out of the nudge choice, so muting it does not turn the nudge into Custom.
- Reword controls in plain language and drop internal terms from visible labels.
- Out of scope: new warning behavior, a respec switch, and any change to rules or data.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: the page list, where each control lives, the Home nudge choice with Custom, the four watch areas, the Advanced section and the shared page layout.

## Impact

- `DontDoThat/Options/Options.lua`: pages and `Options.Pages()` rebuilt; existing builders for Rules, Tally, Milestones, Debug and About are reused inside the new pages.
- `DontDoThat/Model/Settings.lua`: nudge reading and setting, and the four watch-area switches.
- `DontDoThat/Intercepts/` and `Rules/`: Spells, Professions and Shopping switches are read where warnings are produced.
- `tests/options_test.lua`, `tests/settings_test.lua`: updated for the new pages and settings.
- `CLAUDE.md` release rule: a user-visible restructure with new presets and switches, so 0.5.0 becomes 0.6.0 in both `.toc` files at archive.

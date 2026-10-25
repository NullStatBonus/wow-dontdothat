# Proposal

## Why

The settings pages grew one at a time, so each uses its own font sizes, spacing tricks and colors, and it shows. Players also cannot act on the rules: they cannot stop a warning they disagree with (a PvP player told that PvP spells can wait), nor adjust the thresholds the engine hard-codes.

## What Changes

- One page template across all eight settings pages: a shared type scale, one muted gray, consistent section headings, icon-led rows, and fixed spacing instead of blank spacer rows. Fixes the Alerts cooldown slider showing 5 on a fresh profile when the default is 3.
- The Rules page becomes editable:
  - a switch per ability (an off ability is never warned about),
  - a switch per tag per class (PvP, RaidGroup, LowValue, Endgame),
  - a switch per rule kind (skipped ranks, rank supersession, off-spec leaning, profession skill caps),
  - a "My spec" dropdown per class (Automatic or one of its specs).
- A "Tuning" section on General:
  - the rank supersession window (levels),
  - the profession near-cap margin (skill points),
  - stop warning after the level 40 or the level 60 mount,
  - which tiers ask "Buy anyway?" and play the warning sound (any combination).
- An alert sound channel dropdown on Alerts.
- Disabled rules and tuned values flow through the rule engine, so badges, tooltips, the Recommended filter, the Ledger and the Tally all agree.
- Defaults reproduce today's behavior exactly: no existing player sees a change until they touch a control.

Out of scope: gold-per-hour override, mount costs, separate control of which tiers the Recommended filter hides, forcing a warning on something the rules keep, a custom-frame UI replacing AceConfig.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `addon-settings`: the rules review becomes editable; consistent page layout; Tuning section; My spec dropdown; alert channel control.
- `rule-engine`: disabled abilities, tags and rule kinds are skipped; supersession window and profession margin come from player settings; a spec override replaces inference.
- `purchase-warnings`: the confirmation prompt follows the player's chosen tiers instead of defer only.
- `warning-alerts`: the alert on attempt follows the chosen tiers; the sound channel is selectable.
- `milestones`: the player can end warnings after the level 40 mount.

## Impact

- `DontDoThat/Options/Options.lua` (page template, Rules, General, Alerts), `DontDoThat/Core/Addon.lua` (new profile defaults), `DontDoThat/Rules/Engine.lua`, `DontDoThat/Model/PlayerProfile.lua`, `DontDoThat/Model/Milestones.lua`, `DontDoThat/Intercepts/Confirm.lua`, `DontDoThat/UI/Alert.lua`, `DontDoThat/Intercepts/Context.lua`.
- Saved variables gain new profile keys with defaults; nothing existing is renamed or removed, so existing saved settings stay valid.
- Version 0.3.0 to 0.4.0 in both TOCs at archive.

# Proposal

## Why

Leveling characters in WoW Forever are chronically short on gold at the two points that matter most: the level 40 riding skill and first mount (about 100g), and the level 60 riding skill and Epic mounts (about 1,000g plus 200g per mount). Much of the gold that goes missing is spent on things that do not help until endgame: low-value spell ranks, PvP and raid-only abilities, pet skills, costly respecs, and profession ranks. Players rarely know which purchases are safe to skip. "Don't Do That" is an addon that tells them, at the moment of purchase, and keeps a running tally of what they saved.

## What Changes

- Add a new WoW addon, "Don't Do That" (`/ddt`), targeting WoW Forever (Mainline code family, Interface `16001`, shipped as a `_Forever.toc`).
- Warn the player when they are about to spend gold on an action the addon considers unnecessary from the start until the level 60 mount is bought, with no pause after the level 40 mount (saving for the level 40 mount first, then the level 60 mount). Warnings use one consistent language: a badge, a tooltip line, and, where the client allows safe interception, a confirmation prompt.
- Add a "Recommended" entry to the trainer window's existing filter list, checked by default, that hides rows the rules say to defer. It works in addition to badges, tooltips, and prompts, and falls back to badges alone if it cannot be installed safely.
- Cover pet spending as well as player spending: abilities the Hunter buys from a Pet Trainer are judged by the same rules as other trainer spells, and pet training resets (the Pet Trainer's untrain fee) are tracked and warned about like talent respecs, with their own editable escalating-cost table.
- Decide what to warn about using a data-driven rule engine. A spell's verdict is derived from the rotations of the player's inferred specs, then from ability tags (for example, PvP-centric abilities default to "defer, low value"), then from a generic rank-supersession rule, with explicit per-spell overrides taking precedence.
- Infer the player's spec(s) from talent points per tree. When the spec is ambiguous, evaluate conservatively: warn only if no plausible spec uses the ability.
- Track a gold-saved tally derived from character state, split into **verified** (a higher rank of the same spell is learned, so the lower rank was provably never bought) and **projected** (deferred but not yet superseded). Track talent respecs explicitly, with an "avoided" and a "spent against the rules" side, using an editable escalating-cost table.
- Play a loud sound and show a prominent on-screen banner when the player attempts a flagged action (not on hover), with a cooldown and a selectable sound from a data-driven registry.
- Add a settings section under Options > AddOns with subpages (General, Alerts, Rules, Milestones, Tally, Debug, About). The Rules page is read-only in v1. Blocking prompts, warnings, and alerts are independently toggleable and on by default.
- Add debug tooling (`/ddt probe`, `/ddt export`, a debug log) that exports API availability, trainer data, talent data, and observed costs, so in-game findings can be returned for tuning.
- v1 rule data covers Hunter, Herbalism, and Skinning. The data layout, player profile, and spec model are built so other classes, professions, and armor/weapon proficiencies can be added later as data files.

## Capabilities

### New Capabilities
- `rule-engine`: Evaluates a proposed action against rule data and returns a verdict (tier, estimated cost, reason). Covers precedence (override, rotation, tags, supersession), tiers, and rank-supersession.
- `spec-inference`: Infers the player's spec(s) and role from talent points per tree, including ambiguity handling and dual spec.
- `milestones`: Models the level 40 and level 60 mount milestones, their costs, and continuous deferral (active from the start until the level 60 mount is bought), which gates when warnings apply.
- `savings-ledger`: Derives the verified and projected gold-saved tally from character state, tracks respecs, and caches observed trainer costs.
- `purchase-warnings`: Intercepts and annotates trainer, talent, respec, and profession surfaces with badges, tooltips, and (where safe) confirmation prompts.
- `warning-alerts`: Plays the alert sound and shows the on-screen banner, with a sound registry, channel handling, and cooldowns.
- `addon-settings`: The Options > AddOns category and subpages, toggles, and the read-only rules/milestones/help views.
- `debug-tools`: Probe, export, and logging commands used to gather in-game data.

### Modified Capabilities
<!-- None: openspec/specs is empty. -->

## Impact

- New greenfield addon, no existing code or specs are modified.
- Bundled libraries: LibStub, CallbackHandler, AceAddon-3.0, AceDB-3.0, AceHook-3.0, AceEvent-3.0, AceConsole-3.0, AceConfig-3.0 (with AceConfigDialog and AceGUI). The `Rules/` layer stays pure Lua with no WoW or Ace dependencies, so it can be unit-tested outside the game.
- Persistent data in SavedVariables: settings, the savings ledger, observed trainer-cost cache, and a bounded debug log.
- Known unknowns resolved by the first in-game probe run, not by this plan: whether trainer purchases and talent learning can be intercepted without taint under the Midnight-style addon restrictions, whether higher spell ranks can be bought without the lower ones, the real talent-read API names, per-rank levels/costs/spell IDs, and the live respec quote. Costs, mount prices, and sound IDs are editable data, to be verified at launch.
- Marksmanship and Survival rotation data ships flagged "needs review".
- Out of scope for v1: per-rule disabling, classes and professions other than Hunter/Herbalism/Skinning, armor and weapon proficiency logic, a Classic client adapter, a minimap/LDB button, a floating tally frame, Legacy talents, and the Recommended filter for beast training.

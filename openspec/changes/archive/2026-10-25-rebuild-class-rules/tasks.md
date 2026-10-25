## 1. Tooling

- [x] 1.1 Fetch Wowhead's Classic "Spells to Buy" guides for all nine classes (the expert source for ranks to skip)
- [x] 1.2 Drop the computed rank rule and its script from the scaffold
- [x] 1.3 Add `tools/class_plans/` and `tools/scaffold_class_rules.py` so the seven class files can be regenerated from one reviewed plan

## 2. Rules page

- [x] 2.1 Extend `Options.ClassSummary` with `optional`, `other`, `keepGroups` and `optionalGroups`, reading rotation core and situational lists, keeping `keep`, `wait`, `low` and `skipped` as they are
- [x] 2.2 Build the class pages with Worth buying and Optional grouped by spec, Not a purchase collapsed, and counts in the headings
- [x] 2.3 Add a coverage test over all nine classes: every family in the bundled table appears in a list, and none is both reviewed and classified
- [x] 2.4 Update `tests/options_test.lua` for the new lists and Hunter's Worth buying additions

## 3. Re-assess the classes

- [x] 3.1 Mage: spec core lists for Frost, Fire and Arcane, Scorch and Arcane Missiles by spec, Teleports optional
- [x] 3.2 Warlock: DoTs, drains, Health Funnel, Searing Pain, pet summons and stones core
- [x] 3.3 Priest: Smite and Holy Fire core for Discipline and Holy, Shadow core list, Fade and group spells wait
- [x] 3.4 Druid: Balance, Feral and Restoration core lists including Entangling Roots, Barkskin, Faerie Fire (Feral), Prowl and Dash
- [x] 3.5 Shaman: Enhancement and Elemental core lists, weapon imbues, shocks, Stormstrike, travel spells core
- [x] 3.6 Rogue: Gouge, Sap, Evasion, Sprint, Kick, Vanish and the Instant and Deadly Poisons core for every spec
- [x] 3.7 Warrior: Thunder Clap, Hamstring, Slam and Sweeping Strikes core for Arms, Whirlwind and Bloodthirst for Fury, Protection set
- [x] 3.8 Paladin: review the core and situational lists against the same defaults
- [x] 3.9 Update the per-class tests in `tests/rules_<class>_test.lua` to match the new tiers

## 4. Rank skips

- [x] 4.1 Extract each class's expert rank guidance into the plan's `skip` (Mage, Warlock, Priest, Druid, Shaman, Rogue, Warrior) and `Paladin.lua`, and regenerate the class files
- [x] 4.2 Update the per-class tests to the expert-derived skips, with rank 1 never skipped
- [x] 4.3 Hunter: keep the committed skips except Arcane Shot 7 and Serpent Sting 7 (the guides recommend them)
- [x] 4.4 Warlock and Paladin: check further expert sources (Wowhead spec pages, Icy Veins via archive); Paladin gets Hammer of Justice 2-4

## 4a. Remove the level-gap feature

- [x] 4a.1 Delete the supersession rule, window setting, Tuning slider, rule-kind switch, rule-data key and next-rank-level plumbing, and update their tests

## 4b. Audit outcomes

- [x] 4b.1 Revert the brief's skipped spells that had no evidence to low value (Scorch, Pyroblast, Blast Wave, Holy Fire, Shackle Undead, Fade, Distract, Thunder Clap, Slam)
- [x] 4b.2 Demote unverified Forever and acquire-method-3 spells to Optional in the scaffold, with a plan-level `unverified` and `always_core` list
- [x] 4b.3 Make single-target resurrections and interrupts core (Revive, Rebirth, Counterspell, Pummel, Shield Bash, Silence, Rebuke, Spell Lock grimoire)
- [x] 4b.4 Hunter: Aspect of the Pack and Frost Trap Optional, the spells Hunters rely on core

- [x] 4b.5 Warlock and Paladin: worth buying from the Icy Veins and Wowhead recommended lists, unmentioned spells low value, Devotion Aura optional, the grimoire keep list widened to the guides' picks
- [x] 4b.7 Merge the Icy Veins walkthroughs into the rank skips for Mage, Priest, Druid, Shaman, Rogue and Warrior (union with Wowhead)
- [x] 4b.8 Group every Rules page list, add a Pet group, and leave general skills off the page (`general` and `pet` rule data, scaffold support)
- [x] 4b.9 Fetch trainer prices from Wowhead into Data/TrainerPrices.lua and use them in SpellData.Cost
- [x] 4b.10 Projected savings on the Progress page and a per-class overview (most a class could keep) under Advanced > Classes
- [x] 4b.11 One spacing rule in the page builder, bulleted amounts on Tally, projected savings and class overview
- [x] 4b.12 Move profession settings to What to watch and flatten Advanced (no Rules level, no profession pages)

## 5. Verify and release

- [x] 5.1 Open the Rules page in game for a few classes and check the lists read well and the skipped ranks look sensible; correct the plan where they do not
- [x] 5.2 At archive, bump `## Version:` to 0.9.0 in both `.toc` files and name it in the commit message

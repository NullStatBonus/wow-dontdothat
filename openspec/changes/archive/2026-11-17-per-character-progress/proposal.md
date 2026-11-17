# Proposal

## Why

The addon keeps all settings in one shared AceDB profile ("Default"), and that includes two things that are facts about one character: the "mark done" checkboxes for the level 40 and level 60 mounts, and which professions the player has already been asked about. Marking the level 40 mount done on a main with "stop after 40" leaves a new alt with no warnings at all, and an alt is never asked about a profession the main was asked about.

## What Changes

- The mount "mark done" checkboxes and the professions already asked about are kept per character. Settings (warn levels, appearance, categories) stay shared.
- Migration for existing saves: on each character's first login after the update, a level 40 or level 60 mark from the shared profile is copied to that character only if the character's level is at least that milestone's level. Profession answers are not copied: each character may be asked once about a profession, even if another character already was.
- The shared values are left in the saved data, unused, so downgrading still works.
- Patch release: fixes existing behavior.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `milestones`: milestone marks belong to the character.
- `purchase-warnings`: the one-time profession question is once per character.

## Impact

- `DontDoThat/Core/Addon.lua` (char defaults, migration on login), `DontDoThat/Intercepts/Context.lua`, `DontDoThat/Model/Settings.lua` (`MarkProfessionAsked`, `KEEP_ON_RESET`), `DontDoThat/Options/Options.lua` (milestone checkboxes).
- Tests for the migration and for alts. README "Good to know", `docs/test-plan.md`.
- Saved data: adds `char.milestoneOverride` and `char.professionAsked`; migration as above.

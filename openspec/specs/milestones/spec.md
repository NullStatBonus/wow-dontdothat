# milestones Specification

## Purpose
Defines the level 40 and level 60 mount milestones, their gold targets, and when warnings are active, so the addon only discourages spending while the player is still saving for a mount.

## Requirements

### Requirement: Mount milestones
The system SHALL define a level 40 milestone and a level 60 milestone, each with a riding cost and a mount cost expressed as editable data, with separate default values for Classic Era and WoW Forever.

#### Scenario: Default targets
- **WHEN** the addon loads with default data on WoW Forever
- **THEN** the level 40 milestone is 100 gold (riding training, first mount included) and the level 60 milestone is 1,000 gold riding training plus a 200 gold epic mount

#### Scenario: Default targets on Classic Era
- **WHEN** the addon loads with default data on Classic Era
- **THEN** the level 40 milestone is 20 gold riding plus an 80 gold mount, and the level 60 milestone is a 1,000 gold epic mount with no riding cost

### Requirement: Continuous deferral until the chosen mount
The system SHALL keep warnings active continuously, with no pause between milestones, and SHALL finish after the mount the player chose to stop at, the level 60 mount by default or the level 40 mount if chosen. The current milestone is the next unbought mount, level 40 and then level 60.

#### Scenario: Before any mount
- **WHEN** the player has acquired no mount
- **THEN** warnings are active and the current milestone is the level 40 mount

#### Scenario: After the first mount
- **WHEN** the player acquires the level 40 mount and the stop is the level 60 mount
- **THEN** warnings stay active and the current milestone becomes the level 60 mount

#### Scenario: After the final mount
- **WHEN** the player acquires the level 60 mount
- **THEN** the addon stops producing warnings

#### Scenario: Stopping at the level 40 mount
- **WHEN** the player chose to stop after the level 40 mount and acquires it
- **THEN** the addon stops producing warnings

#### Scenario: Changing the stop later
- **WHEN** the player changes the stop from the level 40 mount to the level 60 mount after buying the level 40 mount
- **THEN** warnings resume with the level 60 mount as the current milestone

### Requirement: Mount acquisition detection
The system SHALL detect that a milestone is complete when the player has learned the milestone's riding skill or class mount, and on Classic Era SHALL detect the level 60 milestone from an epic mount item in the bags or bank, since Era has no epic riding lesson. It SHALL allow the player to set the state manually if detection fails.

#### Scenario: Riding learned
- **WHEN** the player learns Apprentice Riding
- **THEN** the level 40 milestone is marked complete

#### Scenario: Era epic mount bought
- **WHEN** a Classic Era player has a level 60 epic mount item in the bags or bank
- **THEN** the level 60 milestone is marked complete

#### Scenario: Manual override
- **WHEN** the player marks a milestone complete in settings
- **THEN** the state changes accordingly regardless of detection

### Requirement: Milestone progress display
The system SHALL show the player each milestone's target cost, its status, and the player's current gold relative to the target.

#### Scenario: Under target
- **WHEN** the player has less gold than the active milestone's cost
- **THEN** the Milestones view shows the shortfall

### Requirement: Discounts are data
The system SHALL treat reputation and PvP rank discounts to mount costs as data and SHALL NOT assume a fixed price in logic. It SHALL lower a milestone's default target by each discount the player qualifies for: 10% at Honored or better with the home race's faction on both clients, and on Classic Era another 10% at PvP rank 3 or higher. Discounts SHALL add, and SHALL NOT apply to a class's own milestone target.

#### Scenario: Price data changes
- **WHEN** a milestone's cost data is edited in a data file
- **THEN** displays and savings use the new value

#### Scenario: Honored on Era
- **WHEN** a Classic Era player is Honored with their home faction and below PvP rank 3
- **THEN** the level 60 target is 900 gold and Progress says a discount applies

#### Scenario: Honored and PvP rank 3 on Era
- **WHEN** a Classic Era player is Honored with their home faction and PvP rank 3
- **THEN** the level 60 target is 800 gold

#### Scenario: Honored on Forever
- **WHEN** a WoW Forever player is Honored with their home faction
- **THEN** the level 60 target is 1,080 gold

#### Scenario: Class target not discounted
- **WHEN** a Paladin who is Honored opens Progress
- **THEN** the level 40 class target is unchanged

#### Scenario: Standing unknown
- **WHEN** the faction standing or PvP rank cannot be read
- **THEN** that discount is not applied

### Requirement: Class milestone overrides and notes
The system SHALL let a class's rule data override the riding and mount costs of the level 40 or level 60 milestone, and SHALL use the default targets for any milestone the class does not override. A class MAY also give a milestone a short note, which the Progress page shows with that milestone.

#### Scenario: Paladin level 40 target
- **WHEN** a Paladin opens Progress with default data
- **THEN** the level 40 target is 10 gold, shown with the Paladin note, and the level 60 target is the default

#### Scenario: Class without overrides
- **WHEN** a Hunter opens Progress
- **THEN** both targets are the defaults and no note is shown

#### Scenario: Progress toward an overridden target
- **WHEN** a Paladin with 6 gold is working toward the level 40 mount
- **THEN** the progress line compares the 6 gold with the 10 gold target

#### Scenario: Price data edited
- **WHEN** the Paladin level 40 cost is edited in the class data file
- **THEN** the Progress page and the progress line use the new value

### Requirement: Riding skill with a class mount
The system SHALL treat the level 40 milestone as complete for a class whose mount spell teaches Apprentice Riding as soon as the player has learned that skill, with no separate purchase assumed.

#### Scenario: Paladin learns the Warhorse
- **WHEN** a Paladin learns Summon Warhorse and with it Apprentice Riding
- **THEN** the level 40 milestone is marked complete

### Requirement: Warlock mount perk
The system SHALL give Warlocks a level 40 target of 0 gold, because the Summon Felsteed quest is free and teaches Apprentice Riding, with a Warlock-themed note on the Progress page, and SHALL leave the level 60 target at the default.

#### Scenario: Warlock Progress page
- **WHEN** a warlock opens Progress with default data
- **THEN** the level 40 line shows 0 gold and the note "Your Felsteed is paid for in souls, not gold."

#### Scenario: Level 60 unchanged
- **WHEN** a warlock opens Progress
- **THEN** the level 60 target is the default

#### Scenario: Learning the Felsteed
- **WHEN** a warlock learns Summon Felsteed and with it Apprentice Riding
- **THEN** the level 40 milestone is marked complete

### Requirement: Level 40 riding is recognised by spell ID
The system SHALL treat the level 40 riding goal as reached when the spellbook knows Apprentice Riding on WoW Forever, the player's racial riding passive on Classic Era, or a Paladin's or Warlock's level 40 class mount on either client.

#### Scenario: Forever level 40 riding
- **WHEN** the spellbook knows Apprentice Riding
- **THEN** the level 40 riding goal is reached

#### Scenario: Era level 40 riding
- **WHEN** a human learns Horse Riding on Classic Era
- **THEN** the level 40 riding goal is reached

#### Scenario: Class mounts
- **WHEN** a Warlock learns Summon Felsteed
- **THEN** the level 40 riding goal is reached

#### Scenario: Any client language
- **WHEN** the client runs in a language other than English
- **THEN** riding is recognised exactly as on an English client

### Requirement: Level 60 riding is recognised without English text
The system SHALL treat the level 60 riding goal as reached when the spellbook knows Journeyman Riding on Forever or a Paladin's or Warlock's level 60 class mount, and on Classic Era when the player's racial riding skill has a maximum rank of 150, finding that skill by the client's own name for the racial riding spell.

#### Scenario: Forever level 60 riding
- **WHEN** the spellbook knows Journeyman Riding
- **THEN** the level 60 riding goal is reached

#### Scenario: Class mount
- **WHEN** a Warlock learns Summon Dreadsteed
- **THEN** the level 60 riding goal is reached

#### Scenario: Era epic riding
- **WHEN** a player on Classic Era trains epic riding and the racial riding skill reaches a maximum rank of 150
- **THEN** the level 60 riding goal is reached, whatever language the client runs in

#### Scenario: Era basic riding
- **WHEN** the racial riding skill has a maximum rank of 75
- **THEN** the level 60 riding goal is not reached

### Requirement: Milestone marks belong to the character
The system SHALL keep the level 40 and level 60 "mark done" choices separately for each character, so marking a milestone on one character does not change any other character's milestones or warnings.

#### Scenario: Alt after a main is marked done
- **WHEN** the player marked the level 40 mount done on one character, with stop after the level 40 mount, and then logs in a new level 10 character
- **THEN** the new character's milestones are not marked and its warnings are active

### Requirement: Migrating shared milestone marks
The system SHALL, on each character's first login after the update, copy a level 40 or level 60 mark saved before the update to that character only when the character's level is at least that milestone's level.

#### Scenario: High-level character keeps its mark
- **WHEN** a level 60 mark was saved before the update and a level 60 character logs in
- **THEN** that character's level 60 milestone is marked done

#### Scenario: Low-level alt does not inherit
- **WHEN** a level 40 mark was saved before the update and a level 25 character logs in
- **THEN** that character's level 40 milestone is not marked

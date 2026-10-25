# milestones Specification

## Purpose
Defines the level 40 and level 60 mount milestones, their gold targets, and when warnings are active, so the addon only discourages spending while the player is still saving for a mount.

## Requirements

### Requirement: Mount milestones
The system SHALL define a level 40 milestone and a level 60 milestone, each with a riding skill cost and a mount cost expressed as editable data.

#### Scenario: Default targets
- **WHEN** the addon loads with default data
- **THEN** the level 40 milestone shows a 100 gold riding and first-mount cost and the level 60 milestone shows a 1,000 gold riding cost plus 200 gold per Epic mount

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
The system SHALL detect that a milestone is complete when the player has learned the milestone's riding skill, and SHALL allow the player to set the state manually if detection fails.

#### Scenario: Riding learned
- **WHEN** the player learns Apprentice Riding
- **THEN** the level 40 milestone is marked complete

#### Scenario: Manual override
- **WHEN** the player marks a milestone complete in settings
- **THEN** the state changes accordingly regardless of detection

### Requirement: Milestone progress display
The system SHALL show the player each milestone's target cost, its status, and the player's current gold relative to the target.

#### Scenario: Under target
- **WHEN** the player has less gold than the active milestone's cost
- **THEN** the Milestones view shows the shortfall

### Requirement: Discounts are data
The system SHALL treat reputation and talent discounts to mount costs as data and SHALL NOT assume a fixed price in logic.

#### Scenario: Price data changes
- **WHEN** a milestone's cost data is edited in a data file
- **THEN** displays and savings use the new value

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

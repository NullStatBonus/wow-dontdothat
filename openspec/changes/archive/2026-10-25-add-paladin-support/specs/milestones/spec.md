## ADDED Requirements

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

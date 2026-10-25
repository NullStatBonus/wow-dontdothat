## ADDED Requirements

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

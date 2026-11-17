## ADDED Requirements

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

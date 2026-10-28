## ADDED Requirements

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

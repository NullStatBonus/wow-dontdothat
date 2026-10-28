## ADDED Requirements

### Requirement: Spells are identified by spell ID
The system SHALL identify a spell by the spell ID of its family, not by its displayed name, so a verdict is the same whatever language the client runs in. A trainer row SHALL be matched to its spell by the spell ID the game gives for the row, and only when the game gives none by the displayed name and the numbers in its rank text.

#### Scenario: Non-English client
- **WHEN** a trainer lists a spell under a name that differs from the English one
- **THEN** the row receives the same verdict as on an English client

#### Scenario: Same name, different spells
- **WHEN** two spells of different classes or pets share a name
- **THEN** each is judged by its own rules

### Requirement: Rule data is checked against the spell tables
The system SHALL accept rule data written with spell names only when every name resolves to a spell in the bundled spell tables, and the test suite SHALL fail on a name that does not.

#### Scenario: Misspelled name
- **WHEN** a rule lists a name that matches no spell
- **THEN** the test suite fails and names the rule and the spell

### Requirement: Talents and professions match without English text
The system SHALL decide which talents are active and which profession a lesson belongs to without comparing English text.

#### Scenario: First lesson in a non-English client
- **WHEN** the player is offered the apprentice lesson of a new profession
- **THEN** it is recognized as that profession's first lesson

#### Scenario: Active talent in a non-English client
- **WHEN** a rotation spell needs a talent the player has
- **THEN** the talent counts as active

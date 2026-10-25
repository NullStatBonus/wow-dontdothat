## ADDED Requirements

### Requirement: Rules for the remaining classes
The system SHALL support Mage, Warlock, Priest, Druid, Shaman, Rogue and Warrior with the same verdict tiers as Hunter and Paladin, with one spec per talent tree in the game's tab order, and SHALL place every spell family in their game tables in a rotation, a tag, an override or a reviewed-and-kept list. Spec rotations SHALL be flagged "needs review" until checked against a source.

#### Scenario: Spec-aware spells
- **WHEN** a Frost mage with the Frost talents evaluates Fireball
- **THEN** it is not kept for a rotation and is judged as mostly used by another spec

#### Scenario: Undecided talents keep everything
- **WHEN** a mage with no talent points spent evaluates Fireball and Frostbolt
- **THEN** both are kept

#### Scenario: Skipped spells
- **WHEN** a mage evaluates Dampen Magic or Scorch
- **THEN** the verdict is defer-low-value with a plain-language reason

#### Scenario: Talent spells
- **WHEN** a mage who has not taken the Ice Barrier talent evaluates it
- **THEN** it is not kept because of a rotation list

#### Scenario: Every spell is considered
- **WHEN** a bundled class table lists a spell family
- **THEN** the class rule data places it somewhere, and a check fails if one is missing

### Requirement: Rank skips need evidence
The system SHALL flag higher ranks of a spell as skippable only where the game's data shows they add nothing the player needs, and SHALL NOT flag ranks that lengthen duration, raise healing or strengthen a debuff. The supported skips are Psychic Scream ranks 2 to 4, Gouge ranks 2 to 5, Kick ranks 2 to 4 and Shield Bash ranks 2 to 3.

#### Scenario: Rank 1 is kept
- **WHEN** a rogue evaluates Gouge rank 1
- **THEN** it is not flagged

#### Scenario: Higher rank skipped
- **WHEN** a rogue evaluates Gouge rank 3
- **THEN** the verdict is defer with a reason that it is only a small upgrade

#### Scenario: Duration grows with rank
- **WHEN** a warlock evaluates Fear rank 2
- **THEN** it is not flagged as a skippable rank

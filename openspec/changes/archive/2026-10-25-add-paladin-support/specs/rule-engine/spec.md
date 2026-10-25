## ADDED Requirements

### Requirement: Paladin rules
The system SHALL support Paladins with the same verdict tiers as other classes, with a spec for each of Holy, Protection and Retribution. It SHALL keep Seals, Judgement, Holy Light, Flash of Light and Blessing of Might for every Paladin spec, keep Seal of Command only while its talent is active, and defer utility, PvP and group spells until the player no longer needs to save for a mount.

#### Scenario: Core Paladin spells
- **WHEN** a Paladin evaluates Seal of Righteousness, Judgement, Holy Light, Flash of Light or Blessing of Might
- **THEN** the verdict is "keep"

#### Scenario: Utility and group spells
- **WHEN** a Paladin evaluates Lay on Hands or a resistance aura
- **THEN** the verdict is a defer tier with a plain-language reason

#### Scenario: Turn Undead
- **WHEN** a Paladin evaluates Turn Undead
- **THEN** the verdict is defer-low-value

#### Scenario: Talent spell
- **WHEN** a Paladin who has not taken the Seal of Command talent evaluates it
- **THEN** it is not kept because of a rotation list

#### Scenario: Unreviewed rotations
- **WHEN** a Paladin spec's rotation has not been reviewed against a source
- **THEN** the rotation is flagged "needs review" wherever the rules are shown

#### Scenario: Every Paladin spell is considered
- **WHEN** the bundled Paladin spell table lists a spell family
- **THEN** the Paladin rule data places it in a rotation, a tag, an override, or a reviewed-and-kept list, and a check fails if one is missing

#### Scenario: Protection talent spells
- **WHEN** a Protection Paladin has taken the Holy Shield talent and evaluates it
- **THEN** it is kept as part of the Protection rotation

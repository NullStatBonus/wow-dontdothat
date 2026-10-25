## MODIFIED Requirements

### Requirement: Rotation-derived verdicts
The system SHALL treat an ability in a core list of any relevant spec's rotation as keep, an ability in a situational list as informational, and an ability in no relevant spec's lists as eligible for tag-based tiers. An ability that the rule data marks as requiring a talent SHALL count as being in a rotation list only while that talent is active; otherwise it SHALL be evaluated as if it were in no rotation list.

#### Scenario: Core ability
- **WHEN** Serpent Sting is in the core list of a relevant spec
- **THEN** the verdict is "keep"

#### Scenario: Ability used only by another spec
- **WHEN** an ability appears only in the rotation of a spec that is not among the player's relevant specs
- **THEN** it is evaluated by its tags instead of being kept

#### Scenario: Talent spell without its talent
- **WHEN** a Marksmanship Hunter has not taken the talent that grants Aimed Shot and Aimed Shot is in the core list of a relevant spec
- **THEN** it is not kept because of that list and is evaluated by its tags and later rules instead

#### Scenario: Talent spell with its talent
- **WHEN** the same Hunter has taken the talent
- **THEN** Aimed Shot is kept because of the core list

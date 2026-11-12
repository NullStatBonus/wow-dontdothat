## MODIFIED Requirements

### Requirement: Mount acquisition detection
The system SHALL detect that a milestone is complete when the player has learned the milestone's riding skill, and SHALL allow the player to set the state manually if detection fails. A manual state SHALL apply to the character it was set on only.

#### Scenario: Riding learned
- **WHEN** the player learns Apprentice Riding
- **THEN** the level 40 milestone is marked complete

#### Scenario: Manual override
- **WHEN** the player marks a milestone complete in settings
- **THEN** the state changes accordingly regardless of detection, and the status on the Milestones page updates at once

#### Scenario: Override is per character
- **WHEN** the player marks the level 40 mount as bought on one character
- **THEN** another character's milestones are unchanged

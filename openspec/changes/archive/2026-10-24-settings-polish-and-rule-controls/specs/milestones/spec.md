## RENAMED Requirements

- FROM: `### Requirement: Continuous deferral until the level 60 mount`
- TO: `### Requirement: Continuous deferral until the chosen mount`

## MODIFIED Requirements

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

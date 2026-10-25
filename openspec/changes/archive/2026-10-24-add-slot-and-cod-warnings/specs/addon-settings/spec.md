## ADDED Requirements

### Requirement: Slot and COD switches
The system SHALL provide three switches on the Items page, one each for bank slots, stable slots, and COD mail, all on by default, taking effect without a reload.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all three switches are on

#### Scenario: Turning one off
- **WHEN** the player turns off COD mail warnings
- **THEN** the next COD payment uses the game's own dialog and the other two kinds are unaffected

#### Scenario: Back to defaults
- **WHEN** the player presses the Items page reset control
- **THEN** the three switches return to on

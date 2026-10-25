## MODIFIED Requirements

### Requirement: Alert on attempt, not on hover
The system SHALL play the alert sound and show the banner when the player attempts a flagged action whose tier the player chose to be warned about (only defer by default), and SHALL NOT do so on mouseover alone.

#### Scenario: Hover is silent
- **WHEN** the player hovers a flagged trainer row
- **THEN** no loud sound or banner is produced

#### Scenario: Attempt triggers alert
- **WHEN** the player clicks to buy a flagged spell
- **THEN** the sound plays, and the confirmation dialog or, when there is none, the banner appears

#### Scenario: Chosen extra tier
- **WHEN** the player has chosen defer-low-value and attempts to buy such a spell
- **THEN** the sound plays

#### Scenario: Tier not chosen
- **WHEN** a tier is not chosen
- **THEN** attempting to buy it produces no sound or banner

## ADDED Requirements

### Requirement: Sound channel
The system SHALL play the warning sound on the channel the player picked, defaulting to Master, and SHALL fall back to Master if the saved channel is not one the game offers.

#### Scenario: Chosen channel
- **WHEN** the player picked the Dialog channel
- **THEN** the warning sound plays on Dialog

#### Scenario: Unknown channel
- **WHEN** the saved channel is not a valid game channel
- **THEN** the sound plays on Master

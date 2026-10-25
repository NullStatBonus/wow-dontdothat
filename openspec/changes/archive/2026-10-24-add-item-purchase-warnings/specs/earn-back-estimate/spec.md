## Purpose
Turns a gold cost into an estimate of grinding time so each prompt shows what the spend means in play time.

## ADDED Requirements

### Requirement: Earn-back line on every prompt
The system SHALL add a line to every confirmation prompt the addon shows, covering trainer purchases, talent and pet resets, and item purchases, stating roughly how long grinding mobs at the player's level takes to earn the cost back.

#### Scenario: Trainer prompt
- **WHEN** the player is asked to confirm a trainer purchase costing 3 gold 20 silver at level 24
- **THEN** the prompt includes a line such as "At level 24, that's about 1 hour 40 minutes of grinding to earn back."

#### Scenario: Reset prompt
- **WHEN** the talent reset question is shown
- **THEN** it includes the earn-back line for the reset's price

#### Scenario: Cost unknown
- **WHEN** a prompt has no known cost
- **THEN** the earn-back line is left out and the rest of the prompt is unchanged

### Requirement: Estimate from level-based rates
The system SHALL compute the estimate as the cost divided by a gold-per-hour rate for the player's level, taken from a data table of level bands covering levels 1 to 60, based on moderate-pace mob grinding without the auction house or professions.

#### Scenario: Level inside a band
- **WHEN** the player is level 24
- **THEN** the rate for the 20–29 band is used

#### Scenario: Level above the table
- **WHEN** the player is above level 60
- **THEN** the level 60 rate is used

### Requirement: Readable time
The system SHALL show the estimate as rounded, approximate text: "under a minute", whole minutes below 2 hours, and hours with the leftover minutes rounded to 5 above that.

#### Scenario: Tiny cost
- **WHEN** the estimate is under 1 minute
- **THEN** the line says "under a minute"

#### Scenario: Several hours
- **WHEN** the estimate is 3 hours 12 minutes
- **THEN** the line says "about 3 hours 10 minutes"

### Requirement: Estimates are labeled as estimates
The system SHALL word the line as approximate and SHALL mark every rate band in its data as needing review until verified.

#### Scenario: Wording
- **WHEN** the line is shown
- **THEN** it uses "about" and does not present the time as exact

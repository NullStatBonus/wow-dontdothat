## MODIFIED Requirements

### Requirement: Options category with subpages
The system SHALL register a "Don't Do That" category under the game's Options > AddOns list with subpages for General, Alerts, Items, Rules, Milestones, Tally, Debug, and About.

#### Scenario: Opening settings
- **WHEN** the player opens Options > AddOns
- **THEN** the addon appears with all eight subpages

## ADDED Requirements

### Requirement: Items page
The system SHALL provide an Items page with one dropdown per item category offering Off, Vendor, AH, and Both, and a minimum price control made of gold, silver, and copper boxes labeled with their coin icons.

#### Scenario: Every category listed
- **WHEN** the player opens Items
- **THEN** all thirteen categories appear, including those that default to Off

#### Scenario: Changing a mode
- **WHEN** the player changes a category's dropdown
- **THEN** the next matching purchase follows the new mode without a reload

#### Scenario: Entering the minimum
- **WHEN** the player enters 10 in the silver box
- **THEN** the minimum price is 10 silver

#### Scenario: Overflowing a box
- **WHEN** the player enters 150 in the copper box
- **THEN** the boxes show 1 silver 50 copper

#### Scenario: Invalid entry
- **WHEN** the player enters something that is not a whole number of zero or more
- **THEN** the previous value is kept

#### Scenario: Default minimum
- **WHEN** the addon runs for the first time
- **THEN** the boxes show 0 gold, 10 silver, 0 copper

#### Scenario: Reset to defaults
- **WHEN** the player presses the page's reset control
- **THEN** all category modes and the minimum return to their defaults

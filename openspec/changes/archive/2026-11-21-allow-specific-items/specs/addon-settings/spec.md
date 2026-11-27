## MODIFIED Requirements

### Requirement: Purchases page
The system SHALL provide a Shopping area on the What to watch page with a minimum price control made of gold, silver, and copper boxes labeled with their coin icons, and a collapsed "Choose categories" section with one dropdown per item category offering Off, Vendor, AH, and Both, followed by a list of the items allowed on this character, each with its icon, name and a Remove button.

#### Scenario: Every category listed
- **WHEN** the player opens Choose categories
- **THEN** all thirteen categories appear, including those that default to Off

#### Scenario: Collapsed by default
- **WHEN** the player opens What to watch
- **THEN** the category dropdowns are not shown until Choose categories is opened

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
- **THEN** the boxes show 0 gold, 1 silver, 0 copper

#### Scenario: Reset to defaults
- **WHEN** the player confirms Reset all settings on Home
- **THEN** all category modes and the minimum price return to their defaults

#### Scenario: Allowed items listed
- **WHEN** the player chose Always Allow for Mageweave Bag and opens What to watch
- **THEN** the Shopping area lists Mageweave Bag with a Remove button

#### Scenario: Removing an allowed item
- **WHEN** the player clicks Remove next to an allowed item and then buys that item
- **THEN** the item is gone from the list and the purchase is warned about as before

#### Scenario: No allowed items
- **WHEN** the character has no allowed items
- **THEN** the Shopping area says how to allow an item from the question

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other full or per-feature settings reset. Appearance’s position-only Reset position is the sole exception and SHALL NOT reset any non-position value. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete), and SHALL turn debug recording off. It SHALL also clear the items allowed on the current character, and SHALL NOT change other characters' allowed items. The defaults SHALL take effect at once, without a reload.

#### Scenario: Resetting
- **WHEN** the player has changed settings on several pages and confirms Reset all settings
- **THEN** every setting returns to its default and Home shows Ask me first

#### Scenario: Warnings right after a reset
- **WHEN** the player confirms Reset all settings and then, without reloading, buys armor for more than 1 silver at a vendor
- **THEN** the purchase is warned about as with the default settings, and What to watch shows each category with its default choice

#### Scenario: Classes page after a reset
- **WHEN** the player picked an older skip revision, confirms Reset all settings and opens Classes
- **THEN** Classes lists the skips of the default (newest) revision

#### Scenario: Declining
- **WHEN** the player declines the confirmation
- **THEN** no setting changes

#### Scenario: Kept
- **WHEN** the player resets all settings
- **THEN** the tally, the professions already asked about and any milestone marked complete are unchanged

#### Scenario: No other reset controls
- **WHEN** the player looks through Tuning, What to watch and Classes
- **THEN** none has a settings-reset control; Appearance may reset position only

#### Scenario: Allowed items after a reset
- **WHEN** the player allowed an item on this character, confirms Reset all settings and buys that item
- **THEN** the purchase is warned about and the Shopping list is empty

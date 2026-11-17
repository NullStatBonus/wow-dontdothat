## MODIFIED Requirements

### Requirement: Tuning section
The system SHALL provide a Tuning section on Advanced with the marks and questions switches, the rule kind switches (skipped ranks and off-spec leaning) and a choice of which tiers ask for confirmation and play the warning sound, where any combination of tiers may be chosen. The stop-after-mount choice (level 40 mount or level 60 mount) SHALL be on Home. Defaults are the current behavior: level 60 mount, and only "Save your gold".

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** Tuning shows only "Save your gold" ticked, and Home shows the level 60 mount

#### Scenario: Picking several tiers
- **WHEN** the player ticks both "Save your gold" and "Not worth buying yet"
- **THEN** both tiers ask and sound on a purchase attempt

#### Scenario: No tiers
- **WHEN** the player ticks no tier
- **THEN** nothing asks or sounds, and badges and tooltips continue

#### Scenario: Reset
- **WHEN** the player confirms Reset all settings on Home
- **THEN** the prompt tiers return to their defaults

### Requirement: What to watch areas
The system SHALL provide a What to watch page with four areas, Spells, Professions, Shopping and Other, all on by default. Spells, Professions and Shopping SHALL each have an on/off control; turning one off SHALL stop its marks, questions and sounds without changing the settings inside it. Spells covers class and pet trainers and the Recommended filter, Professions covers the first-time warning when learning a profession, and Shopping covers vendor and auction house purchases. Other has no control of its own: it holds the bank slot, COD mail and talent reset switches, and for Hunters also the stable slot and pet skill reset switches.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all four areas are on

#### Scenario: Turning an area off
- **WHEN** the player turns Shopping off
- **THEN** vendor and auction purchases are no longer marked or asked about, and the category modes and minimum price keep their values

#### Scenario: Turning it back on
- **WHEN** the player turns Shopping on again
- **THEN** the category modes and minimum price are as they were

#### Scenario: Profession settings together
- **WHEN** the player opens the Professions area
- **THEN** it holds the warning switch and a note that it asks once, the first time the player learns a profession other than Fishing, Herbalism, Mining or Skinning

### Requirement: Purchases page
The system SHALL provide a Shopping area on the What to watch page with a minimum price control made of gold, silver, and copper boxes labeled with their coin icons, and a collapsed "Choose categories" section with one dropdown per item category offering Off, Vendor, AH, and Both.

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

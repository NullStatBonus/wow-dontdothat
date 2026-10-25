## ADDED Requirements

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other settings reset. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete), and SHALL turn debug recording off.

#### Scenario: Resetting
- **WHEN** the player has changed settings on several pages and confirms Reset all settings
- **THEN** every setting returns to its default and Home shows Ask me first

#### Scenario: Declining
- **WHEN** the player declines the confirmation
- **THEN** no setting changes

#### Scenario: Kept
- **WHEN** the player resets all settings
- **THEN** the tally, the professions already asked about and any milestone marked complete are unchanged

#### Scenario: No other reset controls
- **WHEN** the player looks through Tuning, What to watch and Rules
- **THEN** none of them has a reset control

## MODIFIED Requirements

### Requirement: Home page and nudge level
The system SHALL provide a Home page with the overall on/off control, a choice of how firmly the addon nudges the player, and the "stop warning me after" mount choice. The nudge choice SHALL offer Just mark things (marks only, never asks), Ask me first (marks, asks before buying what the player should wait on) and Ask about everything (also asks about low-value and informational items). Ask me first SHALL be the default. Each option SHALL carry its own one-line explanation. The choice SHALL be read from the saved marks, "Ask before buying" and prompt-tier settings rather than stored on its own, and SHALL show Custom as selected when those settings match none of the three, with a line that says what is set (whether marks are on, whether it asks, and which kinds of spell it asks about) and that choosing a level resets them or that they can be fine-tuned under Advanced > Tuning. Choosing a nudge level SHALL set those settings, and choosing Custom SHALL change nothing.

#### Scenario: Default
- **WHEN** the addon runs for the first time
- **THEN** Home shows Ask me first selected

#### Scenario: Choosing a level
- **WHEN** the player chooses Ask about everything
- **THEN** marks stay on, "Ask before buying" is on, and all three tiers ask

#### Scenario: Custom
- **WHEN** the player changes the prompt tiers in Advanced so that they match none of the three levels
- **THEN** Home shows Custom selected, and says that marks are on and which kinds of spell it asks about

#### Scenario: Sound does not affect the level
- **WHEN** the player turns the warning sound off in Advanced
- **THEN** Home still shows the same nudge level

#### Scenario: Heading and stop choice
- **WHEN** the player opens Home
- **THEN** the levels sit under "When you're about to buy something that can wait", and the stop choice sits under "When to stop warning me" and reads "After my level 60 mount" or "After my level 40 mount"

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
- **THEN** the boxes show 0 gold, 10 silver, 0 copper

#### Scenario: Reset to defaults
- **WHEN** the player confirms Reset all settings on Home
- **THEN** all category modes and the minimum price return to their defaults

### Requirement: Slot and COD switches
The system SHALL provide three switches in the Other area of the What to watch page, one each for bank slots, stable slots, and COD mail, all on by default, taking effect without a reload.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all three switches are on

#### Scenario: Turning one off
- **WHEN** the player turns off COD mail warnings
- **THEN** the next COD payment uses the game's own dialog and the other two kinds are unaffected

#### Scenario: Back to defaults
- **WHEN** the player confirms Reset all settings on Home
- **THEN** the three switches return to on

### Requirement: Tuning section
The system SHALL provide a Tuning section on Advanced with the rank supersession window in levels, the profession near-cap margin in skill points, and a choice of which tiers ask for confirmation and play the warning sound, where any combination of tiers may be chosen. The stop-after-mount choice (level 40 mount or level 60 mount) SHALL be on Home. Defaults are the current behavior: 4 levels, 25 points, level 60 mount, and only "Save your gold".

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** Tuning shows 4 levels, 25 points, and only "Save your gold" ticked, and Home shows the level 60 mount

#### Scenario: Picking several tiers
- **WHEN** the player ticks both "Save your gold" and "Not worth buying yet"
- **THEN** both tiers ask and sound on a purchase attempt

#### Scenario: No tiers
- **WHEN** the player ticks no tier
- **THEN** nothing asks or sounds, and badges and tooltips continue

#### Scenario: Reset
- **WHEN** the player confirms Reset all settings on Home
- **THEN** the rank window, profession margin and prompt tiers return to their defaults

### Requirement: Consistent page layout
The system SHALL give every settings page the same structure and look: a title and one-line introduction, then sections each with a heading, using one type scale and one muted note color throughout, with the same small gap between lines that would otherwise run together (read-only lists, the mounts, and the kept amounts).

#### Scenario: Same look on every page
- **WHEN** the player opens each of the five pages in turn
- **THEN** titles, section headings, body text and notes appear in the same sizes and colors on all of them

#### Scenario: Cooldown default
- **WHEN** the addon runs for the first time
- **THEN** the Advanced cooldown slider shows the default of 3 seconds

#### Scenario: Headings appear once
- **WHEN** the player opens Progress
- **THEN** Milestones and Tally each show their heading once

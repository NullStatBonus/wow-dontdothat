## ADDED Requirements

### Requirement: Home page and nudge level
The system SHALL provide a Home page with the overall on/off control, a choice of how firmly the addon nudges the player, and the "stop warning me after" mount choice. The nudge choice SHALL offer Just mark things (marks only, never asks), Ask me first (marks, asks before buying what the player should wait on) and Ask about everything (also asks about low-value and informational items). Ask me first SHALL be the default. The choice SHALL be read from the saved marks, "Ask before buying" and prompt-tier settings rather than stored on its own, and SHALL show Custom as selected when those settings match none of the three. Choosing a nudge level SHALL set those settings, and choosing Custom SHALL change nothing.

#### Scenario: Default
- **WHEN** the addon runs for the first time
- **THEN** Home shows Ask me first selected

#### Scenario: Choosing a level
- **WHEN** the player chooses Ask about everything
- **THEN** marks stay on, "Ask before buying" is on, and all three tiers ask

#### Scenario: Custom
- **WHEN** the player changes the prompt tiers in Advanced so that they match none of the three levels
- **THEN** Home shows Custom selected with a line saying it was changed in Advanced

#### Scenario: Sound does not affect the level
- **WHEN** the player turns the warning sound off in Advanced
- **THEN** Home still shows the same nudge level

### Requirement: What to watch areas
The system SHALL provide a What to watch page with four areas, Spells, Professions, Shopping and Other, all on by default. Spells, Professions and Shopping SHALL each have an on/off control; turning one off SHALL stop its marks, questions and sounds without changing the settings inside it. Spells covers class and pet trainers and the Recommended filter, Professions covers profession ranks and the first-time warning when learning a profession, and Shopping covers vendor and auction house purchases. Other has no control of its own: it holds the bank slot, stable slot and COD mail switches.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all four areas are on

#### Scenario: Turning an area off
- **WHEN** the player turns Shopping off
- **THEN** vendor and auction purchases are no longer marked or asked about, and the category modes and minimum price keep their values

#### Scenario: Turning it back on
- **WHEN** the player turns Shopping on again
- **THEN** the category modes and minimum price are as they were

### Requirement: Advanced section
The system SHALL keep the deeper controls on an Advanced page and out of the way of the other pages: Sound & messages (sound, volume channel, cooldown and the on-screen message), Tuning, the Rules review, and Debug. Nothing on Advanced SHALL be needed to use the addon with its defaults.

#### Scenario: Reaching the deep controls
- **WHEN** the player opens Advanced
- **THEN** the sound controls, Tuning, Rules and Debug are each one step away

#### Scenario: Plain defaults
- **WHEN** the player never opens Advanced
- **THEN** the addon behaves with its default tuning, sound and rule switches

## MODIFIED Requirements

### Requirement: Options category with subpages
The system SHALL register a "Don't Do That" category under the game's Options > AddOns list with subpages for Home, What to watch, Progress, Advanced, and About.

#### Scenario: Opening settings
- **WHEN** the player opens Options > AddOns
- **THEN** the addon appears with all five subpages

### Requirement: Milestones and help content
The system SHALL show milestone targets and status on the Progress page, and explain the signals, tiers, and verified versus projected savings on the About page.

#### Scenario: About page
- **WHEN** the player opens About
- **THEN** it explains badge, tooltip, prompt, and alert and shows the addon version

### Requirement: Tally view
The system SHALL show verified savings, projected savings, spent-against-rules, and respec counts on the Progress page, with a reset control.

#### Scenario: Tally display
- **WHEN** the player opens Progress
- **THEN** verified and projected totals are shown separately

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
- **WHEN** the player presses the What to watch reset control
- **THEN** all category modes and the minimum return to their defaults

### Requirement: Slot and COD switches
The system SHALL provide three switches in the Other area of the What to watch page, one each for bank slots, stable slots, and COD mail, all on by default, taking effect without a reload.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all three switches are on

#### Scenario: Turning one off
- **WHEN** the player turns off COD mail warnings
- **THEN** the next COD payment uses the game's own dialog and the other two kinds are unaffected

#### Scenario: Back to defaults
- **WHEN** the player presses the What to watch reset control
- **THEN** the three switches return to on

### Requirement: Consistent page layout
The system SHALL give every settings page the same structure and look: a title and one-line introduction, then sections each with a heading, using one type scale and one muted note color throughout, with the same small gap between lines that would otherwise run together (read-only lists, the mounts, and the kept amounts).

#### Scenario: Same look on every page
- **WHEN** the player opens each of the five pages in turn
- **THEN** titles, section headings, body text and notes appear in the same sizes and colors on all of them

#### Scenario: Cooldown default
- **WHEN** the addon runs for the first time
- **THEN** the Advanced cooldown slider shows the default of 3 seconds

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
- **WHEN** the player presses the Tuning reset control
- **THEN** the rank window, profession margin and prompt tiers return to their defaults

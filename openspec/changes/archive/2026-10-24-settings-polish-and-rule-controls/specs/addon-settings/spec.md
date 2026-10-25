## RENAMED Requirements

- FROM: `### Requirement: Read-only rules review`
- TO: `### Requirement: Rules review and controls`

- FROM: `### Requirement: Items page`
- TO: `### Requirement: Purchases page`

## MODIFIED Requirements

### Requirement: Options category with subpages
The system SHALL register a "Don't Do That" category under the game's Options > AddOns list with subpages for General, Alerts, Purchases, Rules, Milestones, Tally, Debug, and About.

#### Scenario: Opening settings
- **WHEN** the player opens Options > AddOns
- **THEN** the addon appears with all eight subpages

### Requirement: Purchases page
The system SHALL provide a Purchases page with one dropdown per item category offering Off, Vendor, AH, and Both, and a minimum price control made of gold, silver, and copper boxes labeled with their coin icons.

#### Scenario: Every category listed
- **WHEN** the player opens Purchases
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

### Requirement: Slot and COD switches
The system SHALL provide three switches on the Purchases page, one each for bank slots, stable slots, and COD mail, all on by default, taking effect without a reload.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all three switches are on

#### Scenario: Turning one off
- **WHEN** the player turns off COD mail warnings
- **THEN** the next COD payment uses the game's own dialog and the other two kinds are unaffected

#### Scenario: Back to defaults
- **WHEN** the player presses the Purchases page reset control
- **THEN** the three switches return to on

### Requirement: Rules review and controls
The system SHALL display the active rule set organized by class and profession and by what the player is told, with each ability's reason. It SHALL let the player switch off any single ability, switch off any tag for a class, switch off any rule kind (skipped ranks, rank supersession, off-spec leaning, profession skill caps), and choose a spec per class from Automatic or that class's specs. All switches are on and every class is Automatic by default, and changes apply without a reload.

#### Scenario: Browse Hunter rules
- **WHEN** the player opens the Rules page and selects Hunter
- **THEN** each ability is listed with its icon and reason, each with a switch, along with the tag switches and the My spec dropdown

#### Scenario: Switching off an ability
- **WHEN** the player switches off Arcane Shot
- **THEN** the next trainer view shows no mark on it and a purchase of it is not asked about

#### Scenario: Switching off a tag
- **WHEN** the player switches off the PvP tag for Hunter
- **THEN** abilities that were flagged only because of that tag are no longer flagged

#### Scenario: Switching off a rule kind
- **WHEN** the player switches off skipped ranks
- **THEN** ranks are no longer flagged for being a small upgrade

#### Scenario: Choosing a spec
- **WHEN** the player picks Marksmanship for Hunter
- **THEN** warnings treat Marksmanship as the player's only spec, whatever the talents say

#### Scenario: Spec options follow the class data
- **WHEN** a class's rules list its specs
- **THEN** the dropdown offers Automatic and exactly those specs

## ADDED Requirements

### Requirement: Consistent page layout
The system SHALL give every settings page the same structure and look: a title and one-line introduction, then sections each with a heading, using one type scale and one muted note color throughout, with the same small gap between lines that would otherwise run together (read-only lists, the mounts, and the kept amounts).

#### Scenario: Same look on every page
- **WHEN** the player opens each of the eight pages in turn
- **THEN** titles, section headings, body text and notes appear in the same sizes and colors on all of them

#### Scenario: Cooldown default
- **WHEN** the addon runs for the first time
- **THEN** the Alerts cooldown slider shows the default of 3 seconds

### Requirement: Tuning section
The system SHALL provide a Tuning section on General with the rank supersession window in levels, the profession near-cap margin in skill points, a stop-after-mount choice (level 40 mount or level 60 mount), and a choice of which tiers ask for confirmation and play the warning sound, where any combination of tiers may be chosen. Defaults are the current behavior: 4 levels, 25 points, level 60 mount, and only "Save your gold".

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** Tuning shows 4 levels, 25 points, the level 60 mount, and only "Save your gold" ticked

#### Scenario: Picking several tiers
- **WHEN** the player ticks both "Save your gold" and "Not worth buying yet"
- **THEN** both tiers ask and sound on a purchase attempt

#### Scenario: No tiers
- **WHEN** the player ticks no tier
- **THEN** nothing asks or sounds, and badges and tooltips continue

#### Scenario: Reset
- **WHEN** the player presses the Tuning reset control
- **THEN** all four values return to their defaults

### Requirement: Alert channel control
The system SHALL let the player pick the sound channel used for the warning sound from Master, Sound effects, Music, Ambience and Dialog, defaulting to Master.

#### Scenario: Picking a channel
- **WHEN** the player picks Dialog
- **THEN** the next warning sound plays on that channel

## MODIFIED Requirements

### Requirement: Options category with subpages
The system SHALL register Don’t Do That in Options > AddOns with real Home controls on the root and What to watch, Progress, Appearance, Advanced and About listed beneath it in order. Standalone AceConfig SHALL expose the same six landmarks. Root entry SHALL NOT be an empty placeholder. Registration failure SHALL leave standalone settings available.

#### Scenario: Opening settings
- **WHEN** the root Don’t Do That entry is selected
- **THEN** top-level Home controls are immediately usable

#### Scenario: Child entry
- **WHEN** Appearance is selected under the addon
- **THEN** the same effective controls and saved values as standalone Appearance are shown

### Requirement: Slash commands
The system SHALL provide `/ddt` and `/dontdothat` to open Home and run the common and legacy commands in slash-interface. `/ddt log` SHALL be the primary diagnostic report command and export SHALL remain its alias.

#### Scenario: Open settings
- **WHEN** the player enters `/ddt`
- **THEN** the addon's settings open

### Requirement: Consistent page layout
The system SHALL give every settings page the same structure and look: a title and one-line introduction, then sections each with a heading and a blank line above it, using one type scale and one muted note color throughout, with the same blank line between lines that would otherwise run together (read-only lists, the mounts, and the kept and projected amounts). Amounts SHALL be shown as bulleted lines of a colored label followed by the amount, never in columns, and a page SHALL NOT have two blank lines in a row.

#### Scenario: Same look on every page
- **WHEN** the player opens each of the six pages in turn
- **THEN** titles, section headings, body text and notes appear in the same sizes and colors on all of them

#### Scenario: Cooldown default
- **WHEN** the addon runs for the first time
- **THEN** the Appearance > Sound cooldown slider shows the default of 3 seconds

#### Scenario: Headings appear once
- **WHEN** the player opens Progress
- **THEN** Milestones and Tally each show their heading once

#### Scenario: Amounts read the same everywhere
- **WHEN** the player compares the Tally, the projected savings and a class overview
- **THEN** each amount is a bulleted colored label followed by the amount, with a blank line between lines

### Requirement: Advanced section
The system SHALL keep the deeper controls on an Advanced page and out of the way of the other pages: Tuning, Classes (the per-class rule review), Debug and scope information. Appearance SHALL own Warnings, Explanations and Sound (sound, channel and cooldown); only its on-screen message enable toggle remains on Home. Nothing on Advanced SHALL be needed to use the addon with its defaults.

#### Scenario: Reaching the deep controls
- **WHEN** the player opens Advanced
- **THEN** Tuning, Classes, Debug and scope guidance are reachable; sound is on Appearance > Sound

#### Scenario: Plain defaults
- **WHEN** the player never opens Advanced
- **THEN** the addon behaves with its default tuning, sound and rule switches

### Requirement: Home page and nudge level
The system SHALL provide a Home page with the overall on/off control, a choice of how firmly the addon nudges the player, and the "stop warning me after" mount choice, plus the on-screen message enable toggle backed by the existing alert.banner value. The root game-options entry SHALL expose these same controls. The nudge choice SHALL offer Just mark things (marks only, never asks), Ask me first (marks, asks before buying what the player should wait on) and Ask about everything (also asks about low-value and informational items). Ask me first SHALL be the default. Each option SHALL carry its own one-line explanation. The choice SHALL be read from the saved marks, "Ask before buying" and prompt-tier settings rather than stored on its own, and SHALL show Custom as selected when those settings match none of the three, with a line that says what is set (whether marks are on, whether it asks, and which kinds of spell it asks about) and that choosing a level resets them or that they can be fine-tuned under Advanced > Tuning. Choosing a nudge level SHALL set those settings, and choosing Custom SHALL change nothing.

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
- **WHEN** the player turns the warning sound off in Appearance > Sound
- **THEN** Home still shows the same nudge level

#### Scenario: Heading and stop choice
- **WHEN** the player opens Home
- **THEN** the levels sit under "When you're about to buy something that can wait", and the stop choice sits under "When to stop warning me" and reads "After my level 60 mount" or "After my level 40 mount"

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other full or per-feature settings reset. Appearance’s position-only Reset position is the sole exception and SHALL NOT reset any non-position value. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete), and SHALL turn debug recording off.

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
- **WHEN** the player looks through Tuning, What to watch and Classes
- **THEN** none has a settings-reset control; Appearance may reset position only

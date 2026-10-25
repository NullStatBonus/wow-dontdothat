# Spec Delta

## Purpose

Gives players a standard place in the game's options to control the addon and to review how it works, using familiar patterns found in other addons.

## ADDED Requirements

### Requirement: Options category with subpages
The system SHALL register a "Don't Do That" category under the game's Options > AddOns list with subpages for General, Alerts, Rules, Milestones, Tally, Debug, and About.

#### Scenario: Opening settings
- **WHEN** the player opens Options > AddOns
- **THEN** the addon appears with all seven subpages

### Requirement: Master and per-feature toggles
The system SHALL provide an overall enable control and independent controls for blocking confirmations, badges and tooltips, alerts, and the Recommended trainer filter, all on by default. The Recommended switch SHALL control whether the filter is offered in the trainer's Filter menu at all, and the menu's own checkbox SHALL remember separately whether the filter is applied.

#### Scenario: First install
- **WHEN** the addon runs for the first time
- **THEN** every toggle is on

#### Scenario: Filter toggle
- **WHEN** the player turns off the Recommended filter setting
- **THEN** supported trainers show all rows and the Filter menu no longer has the Recommended entry

#### Scenario: Addon turned off
- **WHEN** the player turns off the addon while a trainer is open
- **THEN** all rows return at once and the Filter menu no longer has the Recommended entry

#### Scenario: Unticking in the menu
- **WHEN** the player unticks Recommended in the trainer's Filter menu
- **THEN** all rows return, and the entry stays available so it can be ticked again

#### Scenario: Master off
- **WHEN** the overall enable is turned off
- **THEN** no warnings, prompts, or alerts occur

### Requirement: Read-only rules review
The system SHALL display the active rule set read-only, organized by class, spec or profession, and rule, including each rule's tier, reason, tags, and review status.

#### Scenario: Browse Hunter rules
- **WHEN** the player opens the Rules page and selects Hunter
- **THEN** rotations, tags, overrides, and tiers are listed without editing controls

### Requirement: Milestones and help content
The system SHALL show milestone targets and status on the Milestones page, and explain the signals, tiers, and verified versus projected savings on the About page.

#### Scenario: About page
- **WHEN** the player opens About
- **THEN** it explains badge, tooltip, prompt, and alert and shows the addon version

### Requirement: Tally view
The system SHALL show verified savings, projected savings, spent-against-rules, and respec counts on the Tally page, with a reset control.

#### Scenario: Tally display
- **WHEN** the player opens Tally
- **THEN** verified and projected totals are shown separately

### Requirement: Settings persistence
The system SHALL persist settings across sessions and apply changes immediately without a reload.

#### Scenario: Toggle takes effect
- **WHEN** the player turns off alerts
- **THEN** the next flagged attempt produces no sound

### Requirement: Slash commands
The system SHALL provide `/ddt` and `/dontdothat` to open settings and run debug commands.

#### Scenario: Open settings
- **WHEN** the player enters `/ddt`
- **THEN** the addon's settings open

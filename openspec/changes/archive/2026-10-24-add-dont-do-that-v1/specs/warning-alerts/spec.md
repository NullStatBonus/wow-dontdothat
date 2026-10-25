# Spec Delta

## Purpose

Gets the player's attention with a loud sound and a prominent on-screen banner when they attempt a flagged action, without becoming noise during ordinary browsing.

## ADDED Requirements

### Requirement: Alert on attempt, not on hover
The system SHALL play the alert sound and show the banner when the player attempts a flagged defer-tier action, and SHALL NOT do so on mouseover alone.

#### Scenario: Hover is silent
- **WHEN** the player hovers a flagged trainer row
- **THEN** no loud sound or banner is produced

#### Scenario: Attempt triggers alert
- **WHEN** the player clicks to buy a flagged spell
- **THEN** the sound plays, and the confirmation dialog or, when there is none, the banner appears

### Requirement: On-screen banner
The system SHALL show a prominent, centered, fading banner naming the item, its cost, and the reason, in the style of existing raid-warning messages, and SHALL NOT show it together with a confirmation dialog for the same attempt, since the dialog carries the same message.

#### Scenario: Banner content
- **WHEN** an alert is shown without a confirmation dialog
- **THEN** the banner includes the item name, cost, and a short reason

#### Scenario: Dialog replaces the banner
- **WHEN** an attempt to buy a deferred item opens a confirmation dialog
- **THEN** the warning sound plays and no banner is shown

#### Scenario: Alerts without prompts
- **WHEN** confirmations are turned off and the player buys a deferred item
- **THEN** the sound and banner appear and the purchase goes ahead

### Requirement: Selectable sound registry
The system SHALL offer a short list of common game sounds defined in data, then any sounds registered with LibSharedMedia when an addon provides it, then every other sound the game names, and SHALL let the player play the selected sound.

#### Scenario: Test a sound
- **WHEN** the player presses Play sound
- **THEN** the selected sound plays once

#### Scenario: Common sounds first
- **WHEN** the player opens the sound picker
- **THEN** the common sounds (such as Raid warning and Ready check) are at the top, and any sound this client does not have is left out

#### Scenario: Sound packs
- **WHEN** another addon has registered sounds with LibSharedMedia
- **THEN** those sounds appear in the picker under the names their pack gave them, and play through their file

#### Scenario: Every game sound
- **WHEN** the player scrolls to the end of the picker
- **THEN** every other sound the game names is listed, with a readable name

### Requirement: Audible when effects are muted
The system SHALL play alerts on a channel that is audible when sound effects are muted, and SHALL NOT change the player's volume settings.

#### Scenario: Effects muted
- **WHEN** the sound effects channel is muted
- **THEN** the alert is still audible if alerts are enabled

### Requirement: Cooldown
The system SHALL apply a per-action cooldown so repeated attempts at the same action do not repeatedly trigger the alert.

#### Scenario: Rapid repeat
- **WHEN** the player attempts the same flagged action twice within the cooldown
- **THEN** the second attempt does not replay the sound

### Requirement: Alerts toggle
The system SHALL let the player turn the sound and banner off, independently of confirmations and badges.

#### Scenario: Alerts off
- **WHEN** alerts are disabled
- **THEN** neither sound nor banner appears while confirmations may still show

### Requirement: Missing sound handling
The system SHALL fall back to a default sound if the selected sound cannot be played, without error.

#### Scenario: Invalid sound ID
- **WHEN** the selected sound entry is invalid on the current client
- **THEN** the default sound plays

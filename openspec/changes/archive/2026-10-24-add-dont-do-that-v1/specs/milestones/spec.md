# Spec Delta

## Purpose

Defines the level 40 and level 60 mount milestones, their gold targets, and when warnings are active, so the addon only discourages spending while the player is still saving for a mount.

## ADDED Requirements

### Requirement: Mount milestones
The system SHALL define a level 40 milestone and a level 60 milestone, each with a riding skill cost and a mount cost expressed as editable data.

#### Scenario: Default targets
- **WHEN** the addon loads with default data
- **THEN** the level 40 milestone shows a 100 gold riding and first-mount cost and the level 60 milestone shows a 1,000 gold riding cost plus 200 gold per Epic mount

### Requirement: Continuous deferral until the level 60 mount
The system SHALL keep warnings active continuously, with no pause between milestones, and SHALL finish only after the level 60 mount is acquired. The current milestone is the next unbought mount, level 40 and then level 60.

#### Scenario: Before any mount
- **WHEN** the player has acquired no mount
- **THEN** warnings are active and the current milestone is the level 40 mount

#### Scenario: After the first mount
- **WHEN** the player acquires the level 40 mount
- **THEN** warnings stay active and the current milestone becomes the level 60 mount

#### Scenario: After the final mount
- **WHEN** the player acquires the level 60 mount
- **THEN** the addon stops producing warnings

### Requirement: Mount acquisition detection
The system SHALL detect that a milestone is complete when the player has learned the milestone's riding skill, and SHALL allow the player to set the state manually if detection fails.

#### Scenario: Riding learned
- **WHEN** the player learns Apprentice Riding
- **THEN** the level 40 milestone is marked complete

#### Scenario: Manual override
- **WHEN** the player marks a milestone complete in settings
- **THEN** the state changes accordingly regardless of detection

### Requirement: Milestone progress display
The system SHALL show the player each milestone's target cost, its status, and the player's current gold relative to the target.

#### Scenario: Under target
- **WHEN** the player has less gold than the active milestone's cost
- **THEN** the Milestones view shows the shortfall

### Requirement: Discounts are data
The system SHALL treat reputation and talent discounts to mount costs as data and SHALL NOT assume a fixed price in logic.

#### Scenario: Price data changes
- **WHEN** a milestone's cost data is edited in a data file
- **THEN** displays and savings use the new value

## MODIFIED Requirements

### Requirement: Mount milestones
The system SHALL define a level 40 milestone and a level 60 milestone, each with a riding cost and a mount cost expressed as editable data, with separate default values for Classic Era and WoW Forever.

#### Scenario: Default targets
- **WHEN** the addon loads with default data on WoW Forever
- **THEN** the level 40 milestone is 100 gold (riding training, first mount included) and the level 60 milestone is 1,000 gold riding training plus a 200 gold epic mount

#### Scenario: Default targets on Classic Era
- **WHEN** the addon loads with default data on Classic Era
- **THEN** the level 40 milestone is 20 gold riding plus an 80 gold mount, and the level 60 milestone is a 1,000 gold epic mount with no riding cost

### Requirement: Discounts are data
The system SHALL treat reputation and PvP rank discounts to mount costs as data and SHALL NOT assume a fixed price in logic. It SHALL lower a milestone's default target by each discount the player qualifies for: 10% at Honored or better with the home race's faction on both clients, and on Classic Era another 10% at PvP rank 3 or higher. Discounts SHALL add, and SHALL NOT apply to a class's own milestone target.

#### Scenario: Price data changes
- **WHEN** a milestone's cost data is edited in a data file
- **THEN** displays and savings use the new value

#### Scenario: Honored on Era
- **WHEN** a Classic Era player is Honored with their home faction and below PvP rank 3
- **THEN** the level 60 target is 900 gold and Progress says a discount applies

#### Scenario: Honored and PvP rank 3 on Era
- **WHEN** a Classic Era player is Honored with their home faction and PvP rank 3
- **THEN** the level 60 target is 800 gold

#### Scenario: Honored on Forever
- **WHEN** a WoW Forever player is Honored with their home faction
- **THEN** the level 60 target is 1,080 gold

#### Scenario: Class target not discounted
- **WHEN** a Paladin who is Honored opens Progress
- **THEN** the level 40 class target is unchanged

#### Scenario: Standing unknown
- **WHEN** the faction standing or PvP rank cannot be read
- **THEN** that discount is not applied

### Requirement: Mount acquisition detection
The system SHALL detect that a milestone is complete when the player has learned the milestone's riding skill or class mount, and on Classic Era SHALL detect the level 60 milestone from an epic mount item in the bags or bank, since Era has no epic riding lesson. It SHALL allow the player to set the state manually if detection fails.

#### Scenario: Riding learned
- **WHEN** the player learns Apprentice Riding
- **THEN** the level 40 milestone is marked complete

#### Scenario: Era epic mount bought
- **WHEN** a Classic Era player has a level 60 epic mount item in the bags or bank
- **THEN** the level 60 milestone is marked complete

#### Scenario: Manual override
- **WHEN** the player marks a milestone complete in settings
- **THEN** the state changes accordingly regardless of detection

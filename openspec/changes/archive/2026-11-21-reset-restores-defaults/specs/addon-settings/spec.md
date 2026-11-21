## MODIFIED Requirements

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other full or per-feature settings reset. Appearance’s position-only Reset position is the sole exception and SHALL NOT reset any non-position value. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete), and SHALL turn debug recording off. The defaults SHALL take effect at once, without a reload.

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

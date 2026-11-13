## MODIFIED Requirements

### Requirement: Respects existing switches
The system SHALL apply the overall enable, "Ask before buying", badges and tooltips, and alerts settings to item warnings in the same way it applies them to trainer warnings.

#### Scenario: Master off
- **WHEN** the overall enable is off
- **THEN** no item warnings, prompts, or alerts occur

#### Scenario: Ask before buying off
- **WHEN** "Ask before buying" is off and the player buys a flagged item
- **THEN** the warning sound and banner play and the purchase goes ahead

#### Scenario: Sound channel
- **WHEN** the player has picked a sound channel other than Master and buys a flagged item
- **THEN** the warning sound plays on the picked channel

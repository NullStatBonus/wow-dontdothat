## MODIFIED Requirements

### Requirement: Confirmation before proceeding
The system SHALL show a confirmation prompt before a purchase proceeds when its verdict tier is one the player chose to be asked about (only defer by default), and SHALL complete the action only if the player confirms.

#### Scenario: Player cancels
- **WHEN** the player declines the prompt
- **THEN** the purchase is not made

#### Scenario: Player confirms
- **WHEN** the player confirms the prompt
- **THEN** the purchase proceeds and is recorded as spent against the rules

#### Scenario: Extra tier chosen
- **WHEN** the player has chosen to be asked about defer-low-value and tries to buy such a spell
- **THEN** the prompt appears

#### Scenario: Tier not chosen
- **WHEN** a tier is not chosen
- **THEN** a purchase of that tier proceeds with no prompt, and its badge and tooltip still show

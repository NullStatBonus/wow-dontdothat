## MODIFIED Requirements

### Requirement: On-screen banner
The system SHALL show exactly one fading alert visual in the selected Toast or Warning style, naming the action/item, cost and reason and existing earn-back context. It SHALL NOT show it together with a confirmation dialog for the same attempt, including the game's own dialog once the addon's note is on it. Warning SHALL retain the existing prominent centered raid-warning presentation; Toast SHALL follow warning-presentation.

#### Scenario: Banner content
- **WHEN** an alert is shown without a confirmation dialog
- **THEN** the selected visual includes the item name, cost, and a short reason

#### Scenario: Dialog replaces the banner
- **WHEN** an attempt to buy a deferred item opens a confirmation dialog
- **THEN** the warning sound plays and no alert visual is shown

#### Scenario: Note on the game's dialog
- **WHEN** the game's own dialog for a talent reset, pet reset, COD or slot purchase stays up with the addon's note added
- **THEN** the warning sound plays and no toast or banner is shown

#### Scenario: Note cannot be added
- **WHEN** the game's dialog cannot take the note
- **THEN** the toast or banner is shown with the sound

#### Scenario: Alerts without prompts
- **WHEN** confirmations are turned off and the player buys a deferred item
- **THEN** the sound and selected visual appear and the purchase goes ahead

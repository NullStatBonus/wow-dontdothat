## MODIFIED Requirements

### Requirement: Vendor purchase prompt
The system SHALL, when the player buys a flagged item from a vendor, play the warning sound and show an Accept / Always Allow / Cancel question naming the item, its total price, the reason, and the earn-back estimate, and SHALL complete the purchase only if the player accepts or chooses Always Allow, and only if the vendor's row still holds the item and price the question named.

#### Scenario: Player declines
- **WHEN** the player cancels the question
- **THEN** the item is not bought and the declined price is recorded as avoided

#### Scenario: Player accepts
- **WHEN** the player accepts the question
- **THEN** the purchase goes through exactly as without the addon and is recorded as spent against the rules

#### Scenario: Player chooses Always Allow
- **WHEN** the player chooses Always Allow
- **THEN** the purchase goes through exactly as without the addon and the item becomes allowed on this character

#### Scenario: Quantity purchases
- **WHEN** the player buys a stack or several units at once
- **THEN** one question covers the whole quantity and its total price

#### Scenario: The vendor changed while the question was open
- **WHEN** the player accepts after the vendor's list changed, the price changed, or the vendor window closed
- **THEN** nothing is bought, the debug log records `items: vendor row <n> changed while the question was open, purchase dropped`, and the question's choice is not applied to another item

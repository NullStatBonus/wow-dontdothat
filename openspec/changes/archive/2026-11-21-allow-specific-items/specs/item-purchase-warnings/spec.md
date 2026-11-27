## MODIFIED Requirements

### Requirement: Vendor purchase prompt
The system SHALL, when the player buys a flagged item from a vendor, play the warning sound and show an Accept / Always Allow / Cancel question naming the item, its total price, the reason, and the earn-back estimate, and SHALL complete the purchase only if the player accepts or chooses Always Allow.

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

## ADDED Requirements

### Requirement: Always Allowed items
The system SHALL never warn about an item the player allowed on this character: no question, sound, banner or tooltip line at vendors or the auction house, whatever its category, class item family or price. It SHALL recognise the item by its item ID, not its name. Other items SHALL be warned about as before.

#### Scenario: Allowed item bought again
- **WHEN** the player chose Always Allow for Mageweave Bag and later buys another one at the auction house
- **THEN** no question, sound or banner appears and the purchase goes through

#### Scenario: Same category
- **WHEN** the player allowed Mageweave Bag and buys a different bag at the auction house
- **THEN** that bag is warned about as before

#### Scenario: No tooltip line
- **WHEN** a vendor sells an allowed item
- **THEN** its tooltip has no warning line

#### Scenario: Another character
- **WHEN** the player allowed an item on one character and buys it on another
- **THEN** the other character is warned about it as before

#### Scenario: Class item family
- **WHEN** a warlock chooses Always Allow for a flagged grimoire and later buys it again
- **THEN** no question is shown

#### Scenario: Any client language
- **WHEN** the game shows an allowed item under a name in another language
- **THEN** it is still allowed

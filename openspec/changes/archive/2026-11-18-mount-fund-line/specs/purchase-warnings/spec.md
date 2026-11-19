## ADDED Requirements

### Requirement: Mount fund line in the purchase question
The system SHALL add one line to the "Buy anyway?" question, after the earn-back line, when the player's gold minus the price is below the current mount milestone's target. The line SHALL give the gold left, the target and the milestone level. It SHALL be left out when the player would still meet the target or when the price, gold, target or active milestone is unknown.

#### Scenario: Still short after buying
- **WHEN** a player saving for the level 40 mount (target 100g) with 73g is asked about a 12g purchase
- **THEN** the question includes "After this you'll have 61g of the 100g for your level 40 mount."

#### Scenario: Purchase takes the player below the target
- **WHEN** the player has 105g, the target is 100g, and the purchase costs 12g
- **THEN** the question includes "After this you'll have 93g of the 100g for your level 40 mount."

#### Scenario: Still enough after buying
- **WHEN** the player has 150g, the target is 100g, and the purchase costs 12g
- **THEN** the question has no mount fund line

#### Scenario: Price unknown
- **WHEN** the question is shown for a purchase with no known price
- **THEN** the question has no mount fund line

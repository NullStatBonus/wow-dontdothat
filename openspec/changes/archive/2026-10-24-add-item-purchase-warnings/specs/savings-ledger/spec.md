## ADDED Requirements

### Requirement: Avoided purchases
The system SHALL count each declined item purchase, with its total price, as avoided cost, kept separate from verified and projected savings and shown on the Tally page.

#### Scenario: Item purchase declined
- **WHEN** the player cancels the question for an item costing 2 gold
- **THEN** the avoided count increases by one and the avoided total by 2 gold

#### Scenario: Item purchase confirmed
- **WHEN** the player accepts the question
- **THEN** nothing is added to avoided, and the price is added to the spent-against total

#### Scenario: Separate from savings
- **WHEN** the player views Tally
- **THEN** avoided purchases are shown as their own figure and are not added to verified or projected totals

#### Scenario: Reset
- **WHEN** the player resets the tally
- **THEN** the avoided count and total return to zero

## ADDED Requirements

### Requirement: Report lists allowed items
The debug report SHALL list the items allowed on the current character, each by item ID and name, and SHALL say when there are none. The record of a purchase let through because its item was allowed SHALL say so.

#### Scenario: Allowed items in the report
- **WHEN** the player allowed Mageweave Bag and opens the debug report
- **THEN** the report lists Mageweave Bag with its item ID

#### Scenario: Allowed purchase recorded
- **WHEN** "Record item purchases" is on and the player buys an allowed item
- **THEN** the report's recent purchases show that it passed because it was allowed

## MODIFIED Requirements

### Requirement: Respec tracking
The system SHALL track respecs explicitly, counting respecs avoided and respecs performed against the rules, and SHALL count each respec at the price quoted by the client when one is known, else at the estimate from an editable escalating-cost table with a cap.

#### Scenario: Respec declined
- **WHEN** the player cancels a respec prompt
- **THEN** the avoided counter increases and the estimated cost counts as projected savings

#### Scenario: Respec declined with a quoted price
- **WHEN** the game quoted 10 gold for the respec and the player cancels it
- **THEN** 10 gold counts as projected savings, whatever the table estimate is

#### Scenario: Respec performed
- **WHEN** the player completes a respec while warnings are active
- **THEN** the performed counter increases and the cost is recorded as spent against the rules

### Requirement: Pet training reset tracking
The system SHALL track pet training resets (the Pet Trainer's untrain option) explicitly, separately from talent respecs, counting resets avoided and performed, and SHALL estimate each reset's cost from an editable escalating-cost table with a cap, preferring a price quoted by the client, both for resets performed and for resets declined.

#### Scenario: Pet reset declined
- **WHEN** the player cancels a pet reset prompt
- **THEN** the avoided counter increases and the estimated cost counts as projected savings

#### Scenario: Pet reset declined with a quoted price
- **WHEN** the game quoted a price for the pet reset and the player cancels it
- **THEN** that quoted price counts as projected savings

#### Scenario: Pet reset performed
- **WHEN** the player completes a pet reset while warnings are active
- **THEN** the performed counter increases and the cost is recorded as spent against the rules, separately from talent respecs

### Requirement: Persistence and reset
The system SHALL persist the ledger across sessions and allow the player to reset it from the Tally view. A reset SHALL clear what the addon has recorded: trainer prices seen, declined and completed purchases, and reset counts. Spell totals that are worked out from the spellbook SHALL be recalculated, not zeroed, and the reset control SHALL say so before the player confirms.

#### Scenario: Reset
- **WHEN** the player resets the tally
- **THEN** declined purchases, reset counts, recorded spending and trainer prices return to zero

#### Scenario: Spell totals after a reset
- **WHEN** the player has learned a rank the addon marked and then resets the tally
- **THEN** that rank still counts as spent, because it is read from the spellbook, and the reset control's text said this would happen

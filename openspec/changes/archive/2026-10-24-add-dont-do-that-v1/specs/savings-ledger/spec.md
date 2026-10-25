# Spec Delta

## Purpose

Quantifies gold the player avoided spending by comparing character state against the rules, separating provably saved gold from projected savings, and tracking respecs explicitly.

## ADDED Requirements

### Requirement: Savings derived from character state
The system SHALL compute savings from what the character has and has not learned, not from whether a prompt was dismissed.

#### Scenario: Deferred spell not learned
- **WHEN** a flagged spell is available to the player at their level and is not learned
- **THEN** its cost counts toward projected savings

#### Scenario: Prompt dismissed but spell bought elsewhere
- **WHEN** the player dismisses a prompt but the spell is learned anyway
- **THEN** no savings are counted for it

#### Scenario: Service hidden by the Recommended filter
- **WHEN** a flagged service is hidden from the trainer by the Recommended filter
- **THEN** it still counts toward savings

### Requirement: Verified versus projected
The system SHALL count a skipped spell rank as verified savings when a higher rank of the same spell is learned, and as projected savings when no higher rank has been learned.

#### Scenario: Higher rank learned
- **WHEN** rank 3 was never learned and rank 4 has been learned
- **THEN** rank 3's cost is verified savings

#### Scenario: No higher rank yet
- **WHEN** rank 3 is unlearned and no higher rank is learned
- **THEN** rank 3's cost is projected savings

### Requirement: Only available actions count
The system SHALL count an action only once it has become available to the player and SHALL NOT count actions above the player's level.

#### Scenario: Not yet available
- **WHEN** a flagged spell requires a level the player has not reached
- **THEN** it contributes nothing to savings

### Requirement: Observed cost cache
The system SHALL record the actual cost of each trainer service when the player views it and use that value in preference to an estimate.

#### Scenario: Trainer viewed
- **WHEN** the player opens a trainer showing a service's cost
- **THEN** the cost is stored and used for future savings calculations

#### Scenario: Never seen
- **WHEN** a service has no observed cost
- **THEN** the data file's estimate is used and marked as an estimate

### Requirement: Respec tracking
The system SHALL track respecs explicitly, counting respecs avoided and respecs performed against the rules, and SHALL estimate respec cost from an editable escalating-cost table with a cap.

#### Scenario: Respec declined
- **WHEN** the player cancels a respec prompt
- **THEN** the avoided counter increases and the estimated cost counts as projected savings

#### Scenario: Respec performed
- **WHEN** the player completes a respec while warnings are active
- **THEN** the performed counter increases and the cost is recorded as spent against the rules

### Requirement: Pet training reset tracking
The system SHALL track pet training resets (the Pet Trainer's untrain option) explicitly, separately from talent respecs, counting resets avoided and performed, and SHALL estimate each reset's cost from an editable escalating-cost table with a cap, preferring a price quoted by the client.

#### Scenario: Pet reset declined
- **WHEN** the player cancels a pet reset prompt
- **THEN** the avoided counter increases and the estimated cost counts as projected savings

#### Scenario: Pet reset performed
- **WHEN** the player completes a pet reset while warnings are active
- **THEN** the performed counter increases and the cost is recorded as spent against the rules, separately from talent respecs

### Requirement: Spent against the rules
The system SHALL track gold spent on flagged actions the player went ahead with, shown separately from savings.

#### Scenario: Player buys a deferred spell
- **WHEN** the player learns a spell the rules marked as deferred
- **THEN** its cost is added to the spent-against total

### Requirement: Persistence and reset
The system SHALL persist the ledger across sessions and allow the player to reset it from the Tally view.

#### Scenario: Reset
- **WHEN** the player resets the tally
- **THEN** all ledger totals return to zero

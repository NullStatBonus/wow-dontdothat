## ADDED Requirements

### Requirement: Tally counts only spells the character can buy
The Tally SHALL leave out spells the character can never buy from a trainer (other races' racials, spell effects and first ranks a talent grants), and SHALL treat a spell the spellbook reports as not learned as not learned. Tally and Projected savings SHALL use the same tiers.

#### Scenario: Other race's racial
- **WHEN** a Human priest opens Progress
- **THEN** no other race's racial spell counts in Kept so far

#### Scenario: Talent first rank
- **WHEN** a priest has the Lightwell talent
- **THEN** Lightwell rank 1 does not count as kept or spent

### Requirement: Amounts survive the mount goal
Finishing the last mount goal SHALL NOT remove amounts already shown in Tally.

#### Scenario: Final mount bought
- **WHEN** the player marks the last mount as bought
- **THEN** Tally shows the same kept and spent amounts as before

### Requirement: Spent anyway counts real purchases
The system SHALL count gold as spent on a marked purchase only when the player's money drops after the purchase, and SHALL NOT count auction bids.

#### Scenario: Purchase fails
- **WHEN** the player accepts a flagged vendor purchase and it fails because the bags are full
- **THEN** nothing counts as spent

#### Scenario: Bid
- **WHEN** the player bids on a flagged auction without buying it out
- **THEN** nothing counts as spent

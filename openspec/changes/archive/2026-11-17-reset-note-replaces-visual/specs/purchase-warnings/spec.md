## MODIFIED Requirements

### Requirement: Covered surfaces
The system SHALL annotate class trainer services, talent selection, talent respec, pet or beast training services, profession trainer services for supported classes and professions, vendor purchases of flagged item categories, and auction house bids and buyouts of flagged item categories.

#### Scenario: Respec dialog
- **WHEN** the game opens its talent reset dialog while warnings are active
- **THEN** the warning sound plays and the game's own dialog stays up with the addon's note added; accepting resets the talents and cancelling leaves them alone

#### Scenario: Pet training reset
- **WHEN** the game opens its pet skill reset dialog while warnings are active
- **THEN** the warning sound plays and the game's own dialog stays up with the addon's note added

#### Scenario: Flagged vendor item
- **WHEN** the player buys an item from a vendor in a category whose mode includes Vendor, at or above the minimum price
- **THEN** the warning sound plays and an Accept / Cancel question is shown before the purchase

#### Scenario: Flagged auction
- **WHEN** the player bids on or buys out an auction in a category whose mode includes AH, at or above the minimum price
- **THEN** the warning sound plays and an Accept / Cancel question is shown before it is placed

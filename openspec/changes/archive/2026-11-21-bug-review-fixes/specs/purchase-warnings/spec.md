## ADDED Requirements

### Requirement: The confirmed purchase is the one the question named
When the player accepts a question, the system SHALL buy only the trainer service, auction or vendor item the question was about, and SHALL drop the purchase when that target is no longer the same.

#### Scenario: Trainer selection changes while the question is open
- **WHEN** the question for spell A is open on Era, the player selects spell B and accepts
- **THEN** spell A is bought and spell B is not

#### Scenario: Auction list changes while the question is open
- **WHEN** the player sorts or searches the auction house while the question is open and then accepts
- **THEN** no auction is bought, and the log records that the auction changed

#### Scenario: Buyout from the Bids tab
- **WHEN** the player buys out a flagged auction from the Bids tab
- **THEN** the question shows as for a buyout from the Browse tab

#### Scenario: Vendor bundle
- **WHEN** the player right-clicks a vendor bundle of 5 that costs 5 silver
- **THEN** the purchase is checked at 5 silver

### Requirement: A question that cannot be shown is not a decline
When the game has no free dialog for a question, the system SHALL NOT count the purchase as declined.

#### Scenario: No free dialog
- **WHEN** every dialog slot is in use and a flagged purchase is attempted
- **THEN** no avoided purchase is recorded and the existing fallback applies

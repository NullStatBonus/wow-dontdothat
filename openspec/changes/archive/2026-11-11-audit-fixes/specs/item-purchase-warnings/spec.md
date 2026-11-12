## MODIFIED Requirements

### Requirement: Auction house purchase prompt
The system SHALL, when the player places a bid or buyout on a flagged auction, show the same kind of question with the bid or buyout amount, and SHALL place it only if the player accepts. Where the game can replace its auction purchase functions after login, the system SHALL check them each time the auction window opens and put its guard back if the game replaced one.

#### Scenario: Buyout declined
- **WHEN** the player cancels the question for a buyout
- **THEN** no buyout is placed and the amount is recorded as avoided

#### Scenario: Bid accepted
- **WHEN** the player accepts the question for a bid
- **THEN** the bid is placed as without the addon

#### Scenario: Game replaces the purchase function
- **WHEN** the game replaces its bid function after login and the player opens the auction window
- **THEN** the next flagged bid or buyout is asked about again

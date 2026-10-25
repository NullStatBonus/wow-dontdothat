## ADDED Requirements

### Requirement: Alerts for item purchases
The system SHALL play the alert sound and, when no question is shown, the banner for a flagged item purchase, using the same sound, channel, cooldown, and alerts toggle as other alerts, and SHALL include the earn-back line in the banner.

#### Scenario: Banner without a question
- **WHEN** "Ask before buying" is off and the player buys a flagged item
- **THEN** the sound plays and the banner names the item, price, reason, and earn-back line

#### Scenario: Question replaces the banner
- **WHEN** a question is shown for a flagged item
- **THEN** the sound plays and no banner is shown

#### Scenario: Cooldown
- **WHEN** the player makes several flagged purchases within the cooldown
- **THEN** only the first plays the sound

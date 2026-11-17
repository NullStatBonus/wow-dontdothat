## MODIFIED Requirements

### Requirement: Alert on attempt, not on hover
The system SHALL play the alert sound and show the selected alert visual when the player attempts a flagged action whose tier the player chose to be warned about (only defer by default), and SHALL NOT do so on mouseover alone.

#### Scenario: Hover is silent
- **WHEN** the player hovers a flagged trainer row
- **THEN** no loud sound or alert visual is produced

#### Scenario: Attempt triggers alert
- **WHEN** the player clicks to buy a flagged spell
- **THEN** the sound plays, and the question or, when there is none, the selected alert style appears

#### Scenario: Chosen extra tier
- **WHEN** the player has chosen defer-low-value and attempts to buy such a spell
- **THEN** the sound plays

#### Scenario: Tier not chosen
- **WHEN** a tier is not chosen
- **THEN** attempting to buy it produces no sound or alert visual

### Requirement: On-screen banner
The system SHALL show exactly one fading alert visual in the selected Toast or Warning style, naming the action/item, cost and reason and existing earn-back context. It SHALL NOT show it together with a confirmation dialog for the same attempt. Warning SHALL retain the existing prominent centered raid-warning presentation; Toast SHALL follow warning-presentation.

#### Scenario: Banner content
- **WHEN** an alert is shown without a confirmation dialog
- **THEN** the selected visual includes the item name, cost, and a short reason

#### Scenario: Dialog replaces the banner
- **WHEN** an attempt to buy a deferred item opens a confirmation dialog
- **THEN** the warning sound plays and no alert visual is shown

#### Scenario: Alerts without prompts
- **WHEN** confirmations are turned off and the player buys a deferred item
- **THEN** the sound and selected visual appear and the purchase goes ahead

### Requirement: Alerts toggle
The system SHALL let the player turn the sound and alert visual off, independently of questions, badges and the chat record.

#### Scenario: Alerts off
- **WHEN** alerts are disabled
- **THEN** neither sound nor alert visual appears while questions and the chat line may still show

### Requirement: Alerts for item purchases
The system SHALL play the alert sound and, when no question is shown, the selected alert visual for a flagged item purchase, using the same sound, channel, cooldown, and alerts toggle as other alerts, and SHALL include the earn-back line in the selected visual.

#### Scenario: Banner without a question
- **WHEN** "Ask before buying" is off and the player buys a flagged item
- **THEN** the sound plays and the selected visual names the item, price, reason, and earn-back line

#### Scenario: Question replaces the banner
- **WHEN** a question is shown for a flagged item
- **THEN** the sound plays and no alert visual is shown

#### Scenario: Cooldown
- **WHEN** the player makes several flagged purchases within the cooldown
- **THEN** only the first plays the sound

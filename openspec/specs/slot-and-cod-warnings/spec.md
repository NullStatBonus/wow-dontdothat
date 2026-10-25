# slot-and-cod-warnings Specification

## Purpose
Warns the player before they pay for a bank slot, a hunter stable slot, or a cash-on-delivery mail, using the same question, sound, and tally treatment as other guarded purchases.

## Requirements

### Requirement: Guarded purchases
The system SHALL, when the game opens its confirmation for buying a bank slot, buying a stable slot, or paying a COD mail, play the warning sound and show an Accept / Cancel question stating the price and the earn-back line, and SHALL complete the purchase only if the player accepts.

#### Scenario: Bank slot declined
- **WHEN** the player cancels the question for a bank slot
- **THEN** no slot is bought and the game's own dialog is gone

#### Scenario: Stable slot accepted
- **WHEN** the player accepts the question for a stable slot
- **THEN** the slot is bought exactly as the game's own Accept would buy it

#### Scenario: COD accepted
- **WHEN** the player accepts the question for a COD mail
- **THEN** the mail's item is taken and the COD amount is paid as the game's own Accept would

#### Scenario: Price shown
- **WHEN** the question is shown
- **THEN** it states the price the game's dialog was showing

### Requirement: No minimum price
The system SHALL warn about every bank slot, stable slot, and COD payment regardless of the minimum price setting.

#### Scenario: Cheap COD
- **WHEN** a COD mail costs 5 copper and the minimum price is 10 silver
- **THEN** the question is still shown

### Requirement: Tally treatment
The system SHALL count a declined purchase of this kind in the avoided purchases total with its price, and an accepted one as spent against the rules.

#### Scenario: Declined
- **WHEN** the player cancels the question for a 20 silver bank slot
- **THEN** avoided purchases rise by one and its total by 20 silver

#### Scenario: Accepted
- **WHEN** the player accepts it
- **THEN** 20 silver is added to the spent-against total and avoided purchases do not change

#### Scenario: Closed without answering
- **WHEN** the game's own dialog closes without the player accepting
- **THEN** it counts as declined

### Requirement: Per-kind switches
The system SHALL let each of the three kinds be turned off independently, all on by default. A kind that is off shows the game's own dialog untouched and records nothing.

#### Scenario: Stable slots off
- **WHEN** stable slot warnings are off and the player buys a stable slot
- **THEN** the game's own dialog is used with no sound, question, or tally entry

### Requirement: Respects existing switches
The system SHALL apply the overall enable and "Ask before buying" settings to these purchases as it does to other guarded purchases.

#### Scenario: Ask before buying off
- **WHEN** "Ask before buying" is off and the game opens a bank slot confirmation
- **THEN** the warning sound plays and the game's own dialog is left in place with a note added

#### Scenario: Master off
- **WHEN** the overall enable is off
- **THEN** no sound, question, or tally entry occurs

### Requirement: Fallback when the question cannot be used
The system SHALL leave the game's own dialog in place with a note added if the addon's question cannot be shown or the client refuses its confirmation, and SHALL NOT make the purchase impossible.

#### Scenario: Client refuses
- **WHEN** the client refuses the addon's confirmation of a bank slot purchase
- **THEN** the addon's question switches off for the session and the game's own dialog is used with a note added

### Requirement: Other dialogs untouched
The system SHALL NOT alter any other game dialog, and SHALL NOT interfere with taking mail attachments that have no COD amount.

#### Scenario: Ordinary mail
- **WHEN** the player takes an attachment from a mail with no COD
- **THEN** nothing is shown and nothing is recorded

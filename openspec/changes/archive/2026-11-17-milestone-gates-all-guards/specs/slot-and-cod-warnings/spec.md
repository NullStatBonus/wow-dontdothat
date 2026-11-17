## MODIFIED Requirements

### Requirement: Per-kind switches
The system SHALL let each guarded one-click purchase be turned off independently: bank slots, stable slots, COD mail, talent resets and pet skill resets, all on by default. A kind that is off shows the game's own dialog untouched and records nothing. The stable slot and pet skill reset switches SHALL be shown only to Hunters.

#### Scenario: Stable slots off
- **WHEN** stable slot warnings are off and the player buys a stable slot
- **THEN** the game's own dialog is used with no sound, question, or tally entry

#### Scenario: Talent resets off
- **WHEN** talent reset warnings are off and the player resets talents
- **THEN** the game's own dialog is used with no sound, note, or tally entry

#### Scenario: Hunter-only switches
- **WHEN** a player who is not a Hunter opens What to watch
- **THEN** Other shows the bank slot, COD mail and talent reset switches only

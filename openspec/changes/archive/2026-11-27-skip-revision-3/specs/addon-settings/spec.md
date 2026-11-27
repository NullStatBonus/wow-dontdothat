## MODIFIED Requirements

### Requirement: Skip revision choice
The system SHALL provide a choice of skip revision on the Tuning section, listing each revision with a one-line description and marking the newest as the default. Choosing one SHALL take effect at once for later purchases, and the choice SHALL be saved. Players who never choose SHALL be on the newest revision.

#### Scenario: Default shown
- **WHEN** a player who never chose opens Tuning
- **THEN** revision 3 is selected and marked as the default

#### Scenario: Go back
- **WHEN** the player selects revision 1
- **THEN** the Rules page and the trainer window use revision 1 from then on

#### Scenario: Description
- **WHEN** the player reads the choice
- **THEN** revision 1 is described as "Original using Expert Advice", revision 2 as "Revised with Rules + Expert Advice" and revision 3 as "Updated with WoW Forever Expert Advice"

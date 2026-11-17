## ADDED Requirements

### Requirement: Profession question is once per character
The system SHALL remember which professions it has asked about separately for each character. Answers saved before the update SHALL NOT be copied to characters, so each character may be asked once about a profession.

#### Scenario: Alt learns a profession the main was asked about
- **WHEN** the player was asked about Tailoring on one character and later trains Tailoring on another character
- **THEN** the other character is asked once

#### Scenario: Same character
- **WHEN** a character was asked about Tailoring and trains it again later
- **THEN** no question is shown

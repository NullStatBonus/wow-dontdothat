## ADDED Requirements

### Requirement: One-time warning when learning a non-gathering profession
The system SHALL, when the player trains a profession other than Skinning, Herbalism, or Mining at a profession trainer before the level 60 mount has been acquired, play the warning sound and show an Accept / Cancel question that names the profession, its cost when known, and a reason specific to that profession, and SHALL complete the training only if the player accepts. It SHALL ask at most once per profession: after the player has been asked about a profession, in either answer, later trainings of that profession SHALL NOT trigger the question again.

#### Scenario: First time learning a crafting profession
- **WHEN** a player who has not been asked about Leatherworking trains it
- **THEN** the warning sound plays and a question names Leatherworking, its cost, and why it is not advised yet
- **THEN** accepting trains the profession and cancelling leaves it untrained

#### Scenario: Asked once only
- **WHEN** the player cancelled the question for Engineering earlier and later tries to train it again
- **THEN** no question is shown and the training proceeds

#### Scenario: Gathering professions
- **WHEN** the player trains Skinning, Herbalism, or Mining
- **THEN** no question is shown

#### Scenario: Question not safe
- **WHEN** a question cannot be shown safely on the profession trainer
- **THEN** the system falls back to a badge and tooltip and does not block the training

#### Scenario: Respects existing switches
- **WHEN** the player has turned off blocking confirmations or the addon is off
- **THEN** no question is shown, and the profession is not recorded as asked about

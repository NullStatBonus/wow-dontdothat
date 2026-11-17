## MODIFIED Requirements

### Requirement: Inactive when not applicable
The system SHALL show no warnings for unsupported classes or professions, or once the mount milestone the player chose to stop at is finished (the level 60 mount by default, or the level 40 mount if chosen, whether detected or marked complete in settings). This SHALL apply to every warning surface: trainer marks, questions and the Recommended filter, vendor and auction house purchases, bank slots, stable slots, COD mail, talent resets and pet resets. Warnings SHALL resume on every surface if the milestone becomes active again.

#### Scenario: Unsupported class
- **WHEN** the player is a class with no rule data
- **THEN** no warnings are shown

#### Scenario: Stopped after the level 40 mount
- **WHEN** the player chose to stop after the level 40 mount and has bought it
- **THEN** a flagged vendor or auction house purchase completes with no question, sound or message
- **AND** buying a bank or stable slot, paying a COD, or resetting talents or pet skills shows only the game's own dialog

#### Scenario: Milestone active again
- **WHEN** the milestone was finished and the player clears its "mark done" checkbox or moves the stop point to the level 60 mount before buying it
- **THEN** shopping and gold-sink warnings ask again

### Requirement: One-time warning when learning a non-gathering profession
The system SHALL, when the player trains a profession other than Fishing, Skinning, Herbalism, or Mining at a profession trainer while warnings are active, play the warning sound and show an Accept / Cancel question that names the profession and says why leveling it costs gold, and SHALL complete the training only if the player accepts. The question SHALL NOT show the lesson's price or an earn-back time: the cost that matters is leveling the profession, not the first lesson. It SHALL ask at most once per profession: after the player has been asked about a profession, in either answer, later trainings of that profession SHALL NOT trigger the question again.

#### Scenario: First time learning a crafting profession
- **WHEN** a player who has not been asked about Leatherworking trains it
- **THEN** the warning sound plays and a question names Leatherworking and why it is not advised yet, with no price or earn-back line
- **THEN** accepting trains the profession and cancelling leaves it untrained

#### Scenario: Asked once only
- **WHEN** the player cancelled the question for Engineering earlier and later tries to train it again
- **THEN** no question is shown and the training proceeds

#### Scenario: Gathering professions
- **WHEN** the player trains Fishing, Skinning, Herbalism, or Mining
- **THEN** no question is shown

#### Scenario: Question not safe
- **WHEN** a question cannot be shown safely on the profession trainer
- **THEN** the system falls back to a badge and tooltip and does not block the training

#### Scenario: Respects existing switches
- **WHEN** the player has turned off blocking confirmations or the addon is off
- **THEN** no question is shown, and the profession is not recorded as asked about

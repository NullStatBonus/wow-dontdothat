## MODIFIED Requirements

### Requirement: Settings persistence
The system SHALL persist settings across sessions and apply changes immediately without a reload. What a character has done (the professions it was asked about and the mounts marked as bought) SHALL be saved for that character only, so one character's answers do not change another's. The first time a character logs in after this was introduced, the system SHALL copy the values that were saved for all characters into that character, so no one loses what they had.

#### Scenario: Toggle takes effect
- **WHEN** the player turns off alerts
- **THEN** the next flagged attempt produces no sound

#### Scenario: Answers are per character
- **WHEN** the player marks the level 40 mount as bought on one character and logs in another
- **THEN** the other character does not have it marked and is still warned

#### Scenario: Existing answers carried over
- **WHEN** a character with answers saved before this change logs in for the first time afterwards
- **THEN** it keeps those answers, and a later change on one character does not change the other

### Requirement: Alert channel control
The system SHALL let the player pick the sound channel used for the warning sound from Master, Sound effects, Music, Ambience and Dialog, defaulting to Master, and SHALL use it for every warning sound: trainer, vendor and auction house.

#### Scenario: Picking a channel
- **WHEN** the player picks Dialog
- **THEN** the next warning sound plays on that channel

#### Scenario: Items use the channel
- **WHEN** the player picks Dialog and a flagged item is bought at a vendor or the auction house
- **THEN** its warning sound plays on Dialog

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other settings reset. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete, saved per character), and SHALL turn debug recording off.

#### Scenario: Resetting
- **WHEN** the player has changed settings on several pages and confirms Reset all settings
- **THEN** every setting returns to its default and Home shows Ask me first

#### Scenario: Declining
- **WHEN** the player declines the confirmation
- **THEN** no setting changes

#### Scenario: Kept
- **WHEN** the player resets all settings
- **THEN** the tally, the professions already asked about and any milestone marked complete are unchanged

#### Scenario: No other reset controls
- **WHEN** the player looks through Tuning, What to watch and Classes
- **THEN** none of them has a reset control

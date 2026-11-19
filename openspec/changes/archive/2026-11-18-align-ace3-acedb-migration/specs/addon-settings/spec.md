# Spec Delta

## ADDED Requirements

### Requirement: Character data survives a character-key change
When the settings library files this character under a different key than the `Name - Realm` key older versions used, the system SHALL move the character's saved data (savings ledger, observed prices, mount marks, profession answers) and profile choice to the new key at login, before anything reads them. It SHALL act at most once per character, SHALL NOT overwrite data already saved under the new key, and SHALL change nothing when the two keys are equal.

#### Scenario: WoW Forever character after the library update
- **WHEN** a WoW Forever character with savings and a chosen profile saved under `Name - Realm` logs in and the loaded library uses `Name Surname`
- **THEN** Progress shows the same savings and observed prices, and the character uses the same profile as before

#### Scenario: Later logins
- **WHEN** the same character logs in again after the move
- **THEN** nothing is moved or changed

#### Scenario: Profile changed after the move
- **WHEN** the player picks another profile after the move and then logs in again
- **THEN** the character keeps the profile the player picked

#### Scenario: Classic Era
- **WHEN** a Classic Era character logs in and both keys are the same
- **THEN** the saved data and profile choice are not touched

#### Scenario: Data already under the new key
- **WHEN** the character already has saved data under the new key
- **THEN** that data stays as it is and the data under the old key is not copied over it

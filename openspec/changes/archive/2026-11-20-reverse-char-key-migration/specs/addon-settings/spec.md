## MODIFIED Requirements

### Requirement: Character data survives a character-key change
When the settings library files this character under a different key than one used before (`Name - Realm`, or on WoW Forever `Name Surname`), the system SHALL move the character's saved data (savings ledger, observed prices, mount marks, profession answers) and profile choice to the key in use at login, before anything reads them. It SHALL act at most once per key change, SHALL NOT overwrite data saved under the key in use, and SHALL change nothing when the keys are equal.

#### Scenario: WoW Forever character after the library update
- **WHEN** a WoW Forever character with savings and a chosen profile saved under `Name - Realm` logs in and the loaded library uses `Name Surname`
- **THEN** Progress shows the same savings and observed prices, and the character uses the same profile as before

#### Scenario: Back to the older library
- **WHEN** a WoW Forever character with savings and a chosen profile saved under `Name Surname` logs in and the loaded library uses `Name - Realm` again
- **THEN** Progress shows the same savings and observed prices, and the character uses the same profile as before

#### Scenario: Forward again
- **WHEN** the same character later logs in with a library that uses `Name Surname` again
- **THEN** the data and profile choice move back, and nothing is left under `Name - Realm`

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

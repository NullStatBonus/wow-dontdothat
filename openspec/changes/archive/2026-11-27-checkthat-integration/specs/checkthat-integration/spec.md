## ADDED Requirements

### Requirement: CheckThat is optional
The system SHALL reach CheckThat only through the adapter, check that each function exists and call it in `pcall`. A missing, old or failing CheckThat SHALL NOT change any addon behavior, and a CheckThat error SHALL turn the integration off for the session and be logged.

#### Scenario: CheckThat not installed
- **WHEN** the addon loads without CheckThat
- **THEN** every command and setting works as before and no error appears

#### Scenario: CheckThat raises an error
- **WHEN** a CheckThat call raises an error
- **THEN** the integration stops for the session and the debug log records `checkthat: FAILED: <why>`

### Requirement: Entries report addon state
The system SHALL register the CheckThat entries `version`, `testsettings` and `setting` at login. An entry call SHALL read state only and SHALL NOT change any setting or write a log line.

#### Scenario: Version entry
- **WHEN** CheckThat calls the `version` entry on build 0.15.0
- **THEN** it returns 1500

#### Scenario: Version entry on 1.0.0
- **WHEN** the TOC version is 1.0.0
- **THEN** the entry returns 10000; an unreadable version returns nothing

#### Scenario: Setting entry
- **WHEN** CheckThat calls the `setting` entry with a known setting key
- **THEN** it returns the value `/ddt get` prints for that key; an unknown key returns nothing

#### Scenario: Character state
- **WHEN** CheckThat calls the `setting` entry with `marks` or `allowed`
- **THEN** it returns the mount marks of the character or the count of its allowed items

### Requirement: Test settings use a temporary profile
The system SHALL provide a test-settings mode that switches the character to a temporary AceDB profile reset to the defaults, and that records the character's own profile name in `db.char.testSettings`. Turning the mode off SHALL switch back to that profile and delete the temporary one. The mode SHALL NOT change another character's profile or any `db.char` data other than the record itself.

#### Scenario: Turn on
- **WHEN** test settings turn on
- **THEN** the character uses a profile with default settings, its own profile is untouched, chat names the profile in use as temporary and the player's own profile as put aside, and the debug log records `test settings: on (own settings put aside)`

#### Scenario: Turn on while on
- **WHEN** test settings turn on while they are already on
- **THEN** the temporary profile resets to the defaults, the record keeps the original profile name, and the log records `test settings: reset to defaults`

#### Scenario: Turn off
- **WHEN** test settings turn off
- **THEN** the character's own profile is active with its values unchanged, the temporary profile is gone, and the log records `test settings: off (own settings restored)`

#### Scenario: Other characters
- **WHEN** one character turns test settings on
- **THEN** another character on the same profile keeps its settings

#### Scenario: Debug stays on
- **WHEN** debug logging is on and test settings turn on or off
- **THEN** debug logging stays on

### Requirement: Test settings never strand the player
The system SHALL never write the temporary profile's name to the saved profile key: at logout the character's own profile name is written back. The system SHALL leave test settings at the first login with no open CheckThat run, whenever CheckThat is missing, too old to report a run, or reports none. An open run SHALL keep test settings across `/reload`.

#### Scenario: Logout while on
- **WHEN** the game saves while test settings are on
- **THEN** the saved profile key names the character's own profile

#### Scenario: Login with no open run
- **WHEN** a character logs in with test settings on and no run open
- **THEN** its own profile is active, debug is off as at any login, and chat says test settings were restored

#### Scenario: CheckThat removed while on
- **WHEN** a character logs in with test settings on and CheckThat is not loaded
- **THEN** its own profile is restored

#### Scenario: Reload during a run
- **WHEN** the player types `/reload` while a run is open and test settings are on
- **THEN** test settings and debug are still on after login, and the log records `test settings: on at login`

#### Scenario: No record, temporary profile active
- **WHEN** a character logs in on the temporary profile and no record exists
- **THEN** the default profile becomes active and the temporary profile is deleted

#### Scenario: Off while not on
- **WHEN** the player turns test settings off and they are not on
- **THEN** nothing changes and chat says so

#### Scenario: Reset all settings
- **WHEN** the player uses Reset all settings while test settings are on
- **THEN** the player's own Always Allow list is not emptied

#### Scenario: Next load after a swap
- **WHEN** the addon loads after test settings ran
- **THEN** no skip-list notice appears and the alert style of the player's profile is unchanged

### Requirement: Chat names the profile in use
The system SHALL print one chat line naming the profile in use at every login, and one at every profile switch, whatever the cause: the Profiles page, `/ddt testsettings`, a run start or end, or a login restore. The line SHALL say whether the profile is the player's own or temporary. The system SHALL show a persistent banner on every settings page while test settings are on, with a button that turns them off.

#### Scenario: Login
- **WHEN** a character logs in on its own profile
- **THEN** chat says `Profile in use: <name> (your own).`

#### Scenario: Login with a run open
- **WHEN** a character logs in with test settings on and a run open
- **THEN** chat says test settings are still on and `Profile in use: DDT test (temporary).`

#### Scenario: Switch from the Profiles page
- **WHEN** the player selects another profile
- **THEN** chat says `Profile changed. Profile in use: <name> (your own).`

#### Scenario: Test settings on
- **WHEN** test settings turn on
- **THEN** chat says `Profile in use: DDT test (temporary)` and names the player's own profile as put aside

#### Scenario: Test settings off
- **WHEN** test settings turn off
- **THEN** chat says `Profile in use: <own> (your own)`

#### Scenario: One line for one switch
- **WHEN** one action switches the profile
- **THEN** chat shows one profile line, not one for each setting or callback

#### Scenario: Banner
- **WHEN** a settings page opens while test settings are on
- **THEN** a banner at the top says the player is on a temporary profile, names their own profile as safe, and offers Restore my settings

### Requirement: The run owns test settings
The system SHALL register the CheckThat run hook at login. A run start SHALL turn test settings on, a run end SHALL turn them off, and a start for the run already seen SHALL change nothing. A hook error SHALL be logged and SHALL NOT stop the addon.

#### Scenario: Run start and end
- **WHEN** a run of the DontDoThat plan starts and later ends
- **THEN** test settings are on during the run and off after it

#### Scenario: Start repeated after reload
- **WHEN** CheckThat repeats the start of the run that is already open
- **THEN** the log records `test settings: run already seen` and nothing else changes

#### Scenario: New run while on
- **WHEN** a start arrives with a new run id while test settings are on
- **THEN** the temporary profile resets to the defaults and the log records `test settings: another run started`

#### Scenario: Start without an id
- **WHEN** a start arrives with no run id
- **THEN** the log records `test settings: run start without an id` and nothing changes

#### Scenario: End while off
- **WHEN** a run ends and test settings are off
- **THEN** the log records `test settings: run ended: <reason>` and nothing changes

#### Scenario: Run hook unavailable
- **WHEN** CheckThat has no `OnRun`
- **THEN** the log records `checkthat: run hook not available` and the manual command still works

### Requirement: Integration lines in the debug log
The system SHALL write `checkthat: entries registered: <n>`, `checkthat: run hook registered`, `checkthat: run hook not available` and `checkthat: run hook refused` at login while debug is on, and no line for an entry call.

#### Scenario: Login with CheckThat
- **WHEN** the addon loads with a current CheckThat and debug on
- **THEN** the log has the entries line and the run hook line

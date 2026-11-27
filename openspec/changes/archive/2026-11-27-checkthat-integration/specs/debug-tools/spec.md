## ADDED Requirements

### Requirement: Debug switch is logged
The system SHALL write `debug log turned on` to the log when debug turns on, and `debug log turned off` before it turns off, whether the player used `/ddt debug` or the settings page.

#### Scenario: Turn debug on
- **WHEN** the player enters `/ddt debug on`
- **THEN** the next log line is `debug log turned on`

#### Scenario: Reset all settings
- **WHEN** Reset all settings turns the log off
- **THEN** the log records `debug log turned off` first

#### Scenario: Turn debug off
- **WHEN** the player enters `/ddt debug off`
- **THEN** the log ends with `debug log turned off` and recording stops

### Requirement: Report shows test settings
The system SHALL show in the debug report whether test settings are on, the active profile name and the CheckThat integration status (`working`, `not detected`, `too old` or `failed: <why>`).

#### Scenario: Report with test settings on
- **WHEN** the player exports while test settings are on
- **THEN** the report says test settings are on and names the temporary profile

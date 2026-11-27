## ADDED Requirements

### Requirement: Test settings command
The system SHALL accept `/ddt testsettings on` and `/ddt testsettings off`, list them in the help, and answer any other argument with a usage line. The command SHALL be marked in the help as for testing.

#### Scenario: Valid use
- **WHEN** the player enters `/ddt testsettings on`
- **THEN** test settings turn on and chat says that the player's own settings are put aside and how to bring them back

#### Scenario: Bad argument
- **WHEN** the player enters `/ddt testsettings maybe`
- **THEN** chat shows `Use /ddt testsettings on or /ddt testsettings off.` and nothing changes

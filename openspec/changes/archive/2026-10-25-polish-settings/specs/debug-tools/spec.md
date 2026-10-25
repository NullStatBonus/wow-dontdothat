## MODIFIED Requirements

### Requirement: Debug off by default
The system SHALL leave debug logging off by default and make no extra chat output unless debugging is on, and SHALL turn debug logging and item recording off at every login so a previous session never leaves them on.

#### Scenario: Normal play
- **WHEN** debug logging is off
- **THEN** the addon prints nothing to chat during normal use

#### Scenario: Left on last session
- **WHEN** the player turned debug logging on and logs in again
- **THEN** debug logging is off


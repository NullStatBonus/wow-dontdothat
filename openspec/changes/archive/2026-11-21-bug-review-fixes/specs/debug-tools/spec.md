## ADDED Requirements

### Requirement: Report lists every setting
The debug report SHALL list the value of every setting, with defaults applied, including those never changed.

#### Scenario: Default settings
- **WHEN** the player has changed no setting and opens the debug report
- **THEN** the report shows the nudge level, areas, stop point, skip revision, item modes and minimum price

### Requirement: Rejected events are stored once
The system SHALL store each event the client rejects once, however often it logs in.

#### Scenario: Several logins
- **WHEN** the client rejects the same event at each of three logins
- **THEN** the saved data and the report list that event once

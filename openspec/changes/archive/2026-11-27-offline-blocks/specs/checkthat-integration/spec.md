## ADDED Requirements

### Requirement: Trainer entry
The system SHALL register the CheckThat entry `trainer`, which reads the open trainer window through the adapter and returns `rows=<n>`, where n counts the services that are not category headers, or returns nothing when no trainer window is open. An entry call SHALL read state only and write no log line.

#### Scenario: Trainer open
- **WHEN** CheckThat calls the `trainer` entry while a trainer window with nine service rows is open
- **THEN** it returns `rows=9`

#### Scenario: No trainer
- **WHEN** CheckThat calls the `trainer` entry while no trainer window is open
- **THEN** it returns nothing

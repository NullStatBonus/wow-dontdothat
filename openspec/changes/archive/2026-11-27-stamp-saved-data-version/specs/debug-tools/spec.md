## ADDED Requirements

### Requirement: Report shows the saved-data version
The system SHALL record the running addon version in the saved data at each load, keep the version it replaced, and show both in the debug report as `saved data version: <current> (earlier: <previous>)`, or the current one alone when there is no earlier one, or `unknown` when the version cannot be read. An unreadable version SHALL NOT overwrite a recorded one.

#### Scenario: Upgrade
- **WHEN** the addon loads at 1.0.0 over data last written by 0.14.0
- **THEN** the report says `saved data version: 1.0.0 (earlier: 0.14.0)`

#### Scenario: Same version
- **WHEN** the addon loads again at the same version
- **THEN** the recorded versions do not change

#### Scenario: Downgrade
- **WHEN** an older build without this record loads the data
- **THEN** it ignores the record and reads its profile as before

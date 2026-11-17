## MODIFIED Requirements

### Requirement: Copyable export
The system SHALL expose `/ddt log` as the primary command and `/ddt export` as its exact compatibility alias, and show the same report in a text window whose contents can be selected and copied, and SHALL include settings, ledger, recent log, and library versions.

#### Scenario: Export
- **WHEN** the player enters `/ddt log` or `/ddt export`
- **THEN** a window opens with the full report selected for copying

## ADDED Requirements

### Requirement: Presentation report context
The report SHALL list active profile/scope, warning style, message enabled state, appearance values, saved position, sound/channel/cooldown and active sample/Move state. Samples SHALL be distinguishable from real recorded decisions. Diagnostic recording and item traces SHALL still turn off at each login as required by existing specs.

#### Scenario: Current report
- **WHEN** log runs after changing a presentation value
- **THEN** the report includes the new effective value and accurate scope without recording a fake purchase

#### Scenario: Debug login safety
- **WHEN** recording was enabled before relog
- **THEN** it is off again and presentation migration has not re-enabled it

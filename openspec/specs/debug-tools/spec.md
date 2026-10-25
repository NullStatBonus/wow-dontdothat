# debug-tools Specification

## Purpose
Lets the developer gather in-game facts about the client, trainers, talents, and costs from a real player's session, and return them as text, so the addon's assumptions can be verified and tuned.

## Requirements

### Requirement: API probe
The system SHALL provide a probe command that reports the client build and Interface number, which relevant trainer, talent, and respec functions exist, and the results of calling safe read-only ones.

#### Scenario: Run probe
- **WHEN** the player enters `/ddt probe`
- **THEN** a report lists the build, Interface number, and availability of each probed function

### Requirement: Failure-tolerant data collection
The system SHALL record an error or restricted-value result for any probed call that fails instead of aborting the report.

#### Scenario: Restricted call
- **WHEN** a probed call errors or returns a restricted value
- **THEN** the report notes that and continues

### Requirement: Trainer and talent snapshot
The system SHALL include in the export the visible trainer services with levels, costs, and ranks, and the player's talent points per tree.

#### Scenario: Trainer open during export
- **WHEN** the player exports while a trainer window is open
- **THEN** the report lists each service with its level, cost, and rank

### Requirement: Rank-purchase observation
The system SHALL record whether higher ranks of a spell were purchasable without lower ranks learned, as observed at trainers.

#### Scenario: Higher rank available
- **WHEN** a trainer shows rank 4 purchasable while rank 3 is unlearned
- **THEN** the export notes that rank skipping is possible for that spell

### Requirement: Observed quotes
The system SHALL record respec price quotes shown by the client and the interception outcomes observed for each surface.

#### Scenario: Respec quote seen
- **WHEN** the client displays a respec price
- **THEN** it is stored with the respec count and time

### Requirement: Copyable export
The system SHALL show the export in a text window whose contents can be selected and copied, and SHALL include settings, ledger, recent log, and library versions.

#### Scenario: Export
- **WHEN** the player enters `/ddt export`
- **THEN** a window opens with the full report selected for copying

### Requirement: Debug log
The system SHALL keep a bounded in-memory and saved log of interception events when debug logging is on, and allow clearing it.

#### Scenario: Log bounded
- **WHEN** the log exceeds its maximum size
- **THEN** the oldest entries are dropped

#### Scenario: Clear
- **WHEN** the player enters `/ddt clear`
- **THEN** the log is emptied

### Requirement: Debug off by default
The system SHALL leave debug logging off by default and make no extra chat output unless debugging is on, and SHALL turn debug logging and item recording off at every login so a previous session never leaves them on.

#### Scenario: Normal play
- **WHEN** debug logging is off
- **THEN** the addon prints nothing to chat during normal use

#### Scenario: Left on last session
- **WHEN** the player turned debug logging on and logs in again
- **THEN** debug logging is off

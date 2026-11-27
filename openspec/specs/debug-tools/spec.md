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
The system SHALL expose `/ddt log` as the primary command and `/ddt export` as its exact compatibility alias, and show the same report in a text window whose contents can be selected and copied, and SHALL include settings, ledger, recent log, and library versions.

#### Scenario: Export
- **WHEN** the player enters `/ddt log` or `/ddt export`
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

### Requirement: Presentation report context
The report SHALL list active profile/scope, warning style, message enabled state, appearance values, saved position, sound/channel/cooldown and active sample/Move state. Samples SHALL be distinguishable from real recorded decisions. Diagnostic recording and item traces SHALL still turn off at each login as required by existing specs.

#### Scenario: Current report
- **WHEN** log runs after changing a presentation value
- **THEN** the report includes the new effective value and accurate scope without recording a fake purchase

#### Scenario: Debug login safety
- **WHEN** recording was enabled before relog
- **THEN** it is off again and presentation migration has not re-enabled it

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

### Requirement: Report lists allowed items
The debug report SHALL list the items allowed on the current character, each by item ID and name, and SHALL say when there are none. The record of a purchase let through because its item was allowed SHALL say so.

#### Scenario: Allowed items in the report
- **WHEN** the player allowed Mageweave Bag and opens the debug report
- **THEN** the report lists Mageweave Bag with its item ID

#### Scenario: Allowed purchase recorded
- **WHEN** "Record item purchases" is on and the player buys an allowed item
- **THEN** the report's recent purchases show that it passed because it was allowed

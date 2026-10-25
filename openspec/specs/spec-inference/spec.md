# spec-inference Specification

## Purpose
Determines which spec or specs a character is plausibly playing from its talent point distribution, so rules can judge abilities against the right rotations and roles.

## Requirements

### Requirement: Infer plausible specs from talent points
The system SHALL compute the player's plausible specs from the points spent in each talent tree and make them available to rule evaluation.

#### Scenario: Clear specialization
- **WHEN** a Hunter has 21 points in Beast Mastery and none elsewhere
- **THEN** Beast Mastery is the only plausible spec

### Requirement: Conservative handling of ambiguity
The system SHALL treat every spec as plausible when no tree leads by the configured margin, including when no talent points are spent, and SHALL warn about an ability only if no plausible spec uses it.

#### Scenario: No talent points yet
- **WHEN** a character has not yet spent any talent points
- **THEN** all specs of its class are plausible

#### Scenario: Near-even split
- **WHEN** a character has 8 points in one tree and 7 in another, below the lead margin
- **THEN** both trees' specs remain plausible

### Requirement: Stability against flip-flopping
The system SHALL require a tree to lead by a configurable margin before narrowing the plausible specs, so that small point changes do not alternately include and exclude a spec.

#### Scenario: Lead below margin
- **WHEN** one tree gains a single point and its lead is still below the margin
- **THEN** the set of plausible specs does not change

### Requirement: Dual specialization
The system SHALL include the plausible specs of every talent set the player has when dual specialization is available, so that an ability is kept if either set uses it.

#### Scenario: Two different specs
- **WHEN** a player's two talent sets favor different trees
- **THEN** both trees' specs are plausible

### Requirement: Role-aware depth criteria
The system SHALL expose talent depth per tree and an inferred role (for example tank, healer, damage) so that rules for any class can use them as conditions.

#### Scenario: Rule using tree depth
- **WHEN** a rule requires at least a given number of points in a tree
- **THEN** it applies only if the player's points in that tree meet or exceed that number

### Requirement: Re-evaluation on talent change
The system SHALL recompute plausible specs whenever the player's talent points change.

#### Scenario: Player spends a point
- **WHEN** the player spends or refunds a talent point
- **THEN** verdicts shown afterward reflect the updated plausible specs

# Spec Delta

## Purpose

Decides whether a proposed gold-spending action is advisable before the player's active mount milestone, and explains why. It turns rule data and player state into a verdict that every other capability consumes.

## ADDED Requirements

### Requirement: Verdict for a proposed action
The system SHALL evaluate a proposed action against the player's profile and return a verdict containing a tier, an estimated cost in copper, a reason, and the milestone the saving applies to.

#### Scenario: Flagged action
- **WHEN** a Hunter below level 40 evaluates training a spell that the rules mark as deferred
- **THEN** the verdict has a non-"keep" tier, a cost, a reason, and the level 40 milestone

#### Scenario: Unknown action
- **WHEN** an action matches no rule, tag, or supersession condition
- **THEN** the verdict is "keep" and no warning is produced

### Requirement: Tiers
The system SHALL support four tiers: keep (no warning), informational (badge and tooltip), defer-low-value (badge and tooltip, never a confirmation prompt), and defer (badge, tooltip, and a confirmation prompt where interception is possible).

#### Scenario: Defer-low-value never prompts
- **WHEN** an action is evaluated as defer-low-value
- **THEN** the verdict does not request a confirmation prompt

### Requirement: Evaluation precedence
The system SHALL resolve a verdict in this order: explicit rank skip, explicit per-action override, spec-aware rotation membership, ability tags, rank supersession, then keep. The first rule that applies SHALL decide the verdict.

#### Scenario: Override beats tag
- **WHEN** an ability is tagged PvP but has an explicit "keep" override
- **THEN** the verdict is "keep"

#### Scenario: Tag beats supersession
- **WHEN** an ability is tagged PvP and also qualifies for rank supersession
- **THEN** the verdict is the tag's tier

### Requirement: Rotation-derived verdicts
The system SHALL treat an ability in a core list of any relevant spec's rotation as keep, an ability in a situational list as informational, and an ability in no relevant spec's lists as eligible for tag-based tiers.

#### Scenario: Core ability
- **WHEN** Serpent Sting is in the core list of a relevant spec
- **THEN** the verdict is "keep"

#### Scenario: Ability used only by another spec
- **WHEN** an ability appears only in the rotation of a spec that is not among the player's relevant specs
- **THEN** it is evaluated by its tags instead of being kept

### Requirement: Tag defaults
The system SHALL map ability tags to default tiers, with PvP-tagged abilities defaulting to defer-low-value and raid or group-utility-tagged abilities defaulting to defer.

#### Scenario: PvP default
- **WHEN** an ability tagged PvP has no override and is in no relevant rotation
- **THEN** the verdict is defer-low-value

### Requirement: Rank supersession
The system SHALL flag a spell rank as skippable when the next rank of the same spell unlocks within 4 levels of the rank's unlock level, unless a higher-precedence rule applies. The window SHALL be a configurable data value.

#### Scenario: Next rank two levels later
- **WHEN** rank 8 unlocks at level 58 and rank 9 at level 60
- **THEN** rank 8 is flagged skippable

#### Scenario: Next rank far away
- **WHEN** the next rank unlocks 8 levels after the current one
- **THEN** supersession does not flag the current rank

### Requirement: Rule data is separate from engine logic
The system SHALL load all class, spec, profession, tag, override, and cost rules from data files, so that adding a class or profession requires adding data without changing engine logic.

#### Scenario: Adding a class
- **WHEN** a new class data file is added with rotations and tags
- **THEN** the engine evaluates that class's actions without code changes

### Requirement: Human-readable reasons
The system SHALL provide for every non-keep verdict a reason that names the cause, such as the spec or tag involved or the rank that supersedes it.

#### Scenario: Spec-specific reason
- **WHEN** a Survival melee ability is flagged for a Beast Mastery player
- **THEN** the reason states it is a Survival ability and the player's tree split

### Requirement: Rotation data review status
The system SHALL allow rotation data to be marked "needs review" and SHALL display that status wherever the rules are shown.

#### Scenario: Unreviewed rotation
- **WHEN** a spec's rotation is flagged "needs review"
- **THEN** the Rules page labels it as such

### Requirement: Explicit rank skips
The system SHALL let rule data name individual spell ranks to skip, SHALL defer a named rank even when its spell is otherwise kept, and SHALL NOT change the verdict of the spell's other ranks.

#### Scenario: Skipped rank of a kept spell
- **WHEN** a spell is kept by an override and rank 7 is listed as skipped
- **THEN** rank 7 is deferred and every other rank keeps its normal verdict

#### Scenario: Plain reason
- **WHEN** a skipped rank is shown to the player
- **THEN** the reason says it is only a small upgrade over the rank before it, without internal terms

## ADDED Requirements

### Requirement: Player rule switches
The system SHALL let player settings switch off a single ability, a tag for a class, or a rule kind (skipped ranks, rank supersession, off-spec leaning, profession skill caps). Everything is on by default, so with no settings changed every verdict is unchanged.

#### Scenario: Switch stored
- **WHEN** the player switches off an ability and reloads the game
- **THEN** the ability is still switched off

### Requirement: Switch precedence
A switched-off ability SHALL get a keep verdict before any other rule is considered. A switched-off tag SHALL be evaluated as if the ability did not carry it. A switched-off rule kind SHALL be skipped, and evaluation continues to the next rule.

#### Scenario: Ability off
- **WHEN** an ability is switched off and it would otherwise be flagged by any rule
- **THEN** the verdict is "keep"

#### Scenario: Tag off
- **WHEN** an ability is flagged only by a PvP tag and the PvP tag is switched off
- **THEN** evaluation continues past the tag rule and, if nothing else applies, the verdict is "keep"

#### Scenario: Tag off, another rule applies
- **WHEN** the PvP tag is off and the ability also qualifies for rank supersession
- **THEN** the verdict is the supersession tier

#### Scenario: Rule kind off
- **WHEN** rank supersession is switched off
- **THEN** a rank whose next rank is two levels away is not flagged by that rule


### Requirement: Switch defaults
The system SHALL leave every verdict unchanged while no switch has been touched.

#### Scenario: Defaults unchanged
- **WHEN** no switch has been touched
- **THEN** every verdict equals the verdict before this change

### Requirement: Tunable thresholds
The system SHALL take the rank supersession window and the profession near-cap margin from player settings when set, and from rule data otherwise. Values SHALL be whole numbers of zero or more; anything else is ignored and the rule data value is used.

#### Scenario: Wider window
- **WHEN** the player sets the window to 6 and the next rank unlocks 5 levels later
- **THEN** the rank is flagged as skippable

#### Scenario: Tighter margin
- **WHEN** the player sets the near-cap margin to 10 and the skill is 15 below the cap
- **THEN** the profession tier is flagged

#### Scenario: Invalid value
- **WHEN** a setting holds a negative or non-numeric value
- **THEN** the rule data value is used

### Requirement: Spec override
The system SHALL use a spec the player picked for a class as that class's only plausible spec, in place of inference from talents. A pick that is not one of the class's specs SHALL be ignored.

#### Scenario: Override replaces inference
- **WHEN** the player picks Beast Mastery and the talents lean Marksmanship
- **THEN** only Beast Mastery counts as the player's spec

#### Scenario: Automatic
- **WHEN** no spec is picked for the class
- **THEN** the spec is inferred from talents as before

#### Scenario: Unknown pick
- **WHEN** the saved pick names a spec the class data does not have
- **THEN** the spec is inferred from talents

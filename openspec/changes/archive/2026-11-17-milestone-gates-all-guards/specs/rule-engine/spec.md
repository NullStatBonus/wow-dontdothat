## MODIFIED Requirements

### Requirement: Player rule switches
The system SHALL let player settings switch off a single ability, a tag for a class, or a rule kind (skipped ranks, off-spec leaning). Everything is on by default, so with no switch changed every verdict is that of the chosen skip revision.

#### Scenario: Switch stored
- **WHEN** the player switches off an ability and reloads the game
- **THEN** the ability is still switched off

#### Scenario: Switch under a later revision
- **WHEN** an ability was switched off before skip revisions existed
- **THEN** it is still switched off under every revision

## REMOVED Requirements

### Requirement: Profession margin setting
**Reason**: The profession rank-tier rule it tuned was removed in 0.x (commit 688bae9). The addon no longer marks profession ranks, so there is no margin to set.
**Migration**: None. A leftover `nearCapMargin` value in saved settings is ignored.

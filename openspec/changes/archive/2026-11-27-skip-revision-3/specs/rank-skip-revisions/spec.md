## ADDED Requirements

### Requirement: Revision 3 follows the WoW Forever leveling guides
The system SHALL decide each skip of revision 3 from a statement in a WoW Forever leveling guide for that class and spec, and SHALL keep revision 2's decision for any spell and spec no statement covers. Where a guide for a spec says to train every rank of a spell, revision 3 SHALL NOT skip a rank of it for that spec, whatever revision 2 said. Where a guide calls a spell optional, revision 3 SHALL skip its ranks above the first for that spec, unless the spell is in that spec's core rotation. Where a guide lists the levels to train a spell at, revision 3 SHALL use the list only when every level in it is a level at which a rank of the spell unlocks. Rank 1 of a spell SHALL never be skipped.

#### Scenario: One spell, two specs
- **WHEN** the Shadow Priest guide says Holy school spells can be skipped and the Discipline guide trains every rank of Smite
- **THEN** Smite rank 2 is skipped for Shadow and bought for Discipline

#### Scenario: Guide says train every rank
- **WHEN** the Forever Protection Warrior guide trains Revenge ranks 1 to 6 and revision 2 skipped Revenge ranks 2 to 6
- **THEN** no Revenge rank is skipped for Protection in revision 3

#### Scenario: Optional spell in the core rotation
- **WHEN** a guide lists a spell as optional but the spec's rules list it as core rotation
- **THEN** revision 3 skips none of its ranks for that spec

#### Scenario: Guide levels do not match the game
- **WHEN** a guide lists levels that are not the levels at which the spell's ranks unlock
- **THEN** the list is not used and revision 2's decision stays

#### Scenario: Spell no guide covers
- **WHEN** no Forever guide has a statement for a spell and spec
- **THEN** revision 3 skips exactly the ranks revision 2 skipped

#### Scenario: Spell loses value at a level
- **WHEN** the Method guide says a spell loses almost all its value after level 10
- **THEN** ranks of that spell that unlock after level 10 are skipped and the reason names level 10

## MODIFIED Requirements

### Requirement: Numbered skip revisions
The system SHALL keep the rank-skip data as numbered revisions. Revision 1 SHALL be the skip list that shipped before revisions existed, unchanged. Revision 2 SHALL be the list produced by the review of the Forever spell data and the Wowhead Classic leveling guides. Revision 3 SHALL build on revision 2 and apply the WoW Forever leveling guides of Wowhead and Method.

#### Scenario: Revision 1 unchanged
- **WHEN** the player has chosen revision 1
- **THEN** exactly the ranks skipped before revisions existed are skipped, for every class and spec

#### Scenario: Revision 2 differs
- **WHEN** the player is on revision 2
- **THEN** the ranks the review added are skipped and the ranks the review removed are not

#### Scenario: Revision 3 differs
- **WHEN** the player is on revision 3
- **THEN** the ranks the Forever guides say to skip are skipped for the specs they name, and the ranks they say to buy are not

### Requirement: Revision choice and default
The system SHALL use the newest revision unless the player has picked an earlier one. A player who has never chosen SHALL get the newest revision, and a pick SHALL be remembered across reloads.

#### Scenario: Never chosen
- **WHEN** the player has never chosen a revision
- **THEN** revision 3 is used

#### Scenario: Earlier revision picked
- **WHEN** the player picks revision 1 and reloads the game
- **THEN** revision 1 is still used

#### Scenario: Unknown revision saved
- **WHEN** the saved revision is not one the addon has
- **THEN** the newest revision is used

### Requirement: Load notice
The system SHALL print a notice in the chat window the first time the addon loads after the newest revision becomes available to a profile, and on a new install. The notice SHALL state which revision is in use, say that the newest revision updates the skip list from the newest WoW Forever leveling guides (some ranks are now skipped, some are not, each with its reason), and say how to change the revision. It SHALL NOT repeat on later loads once shown.

#### Scenario: First load on revision 2
- **WHEN** a player who used the addon before revisions existed loads the game with the update installed
- **THEN** the chat shows which revision is in use, that the newest revision updates the skip list from the newest guides, and how to go back to an earlier one

#### Scenario: First load on revision 3
- **WHEN** a player who was told about revision 2 loads the game with the update installed
- **THEN** the chat shows that revision 3 is in use, that it updates the skip list from the Forever guides, and how to go back to an earlier revision

#### Scenario: New install
- **WHEN** the addon loads for a profile that has never run it
- **THEN** the same notice is shown

#### Scenario: Notice shown once
- **WHEN** the same profile loads the game again
- **THEN** the notice is not printed again

#### Scenario: Player on an earlier revision
- **WHEN** a profile that picked revision 1 loads after revision 3 ships
- **THEN** the notice says revision 1 is in use, that revision 3 exists and how to switch to it

### Requirement: Every skip has a source and a true reason
The system SHALL record for every skipped rank where the decision came from (a Wowhead Classic leveling guide, a Wowhead WoW Forever leveling guide, a Method WoW Forever leveling guide, a computed review of the game data, or an earlier revision) and the actual cause, and SHALL show the player a reason that states that cause. The reason SHALL NOT claim a cause the data does not record.

#### Scenario: Guide skip
- **WHEN** a Wowhead guide says to buy only rank 1 of Overpower and rank 3 is skipped
- **THEN** the reason says the guide advises buying only the first rank

#### Scenario: Computed skip
- **WHEN** a rank is skipped because it is only a small step up for a spell the player only uses now and then
- **THEN** the reason says how much stronger it is and that the spell is only used now and then, not that a guide says to skip it

#### Scenario: Forever guide skip
- **WHEN** the Wowhead Forever guide for Shadow Priest says Holy school spells can be skipped and Smite rank 2 is skipped
- **THEN** the reason says the guide says the spell is not worth buying while leveling, and the Rules page names the Wowhead WoW Forever leveling guide

#### Scenario: Inherited skip
- **WHEN** a rank is skipped because an earlier revision skipped it and no later review scored it
- **THEN** the reason says only what that earlier revision recorded

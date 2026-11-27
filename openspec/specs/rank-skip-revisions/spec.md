# rank-skip-revisions Specification

## Purpose
Lets the list of spell ranks the addon advises skipping come in numbered revisions, so a better list can become the default while players keep the option of an earlier one, keep every switch they have already set, and are told clearly which revision is in use and how to change it.

## Requirements

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

### Requirement: Changing the revision
The system SHALL let the player see and change the revision with a slash command and on the Tuning page. The slash command with no argument SHALL print the revision in use and the revisions available, and with a revision number SHALL switch to it and say so. A number that is not a revision SHALL change nothing and say which are valid.

#### Scenario: Show
- **WHEN** the player types /ddt revision
- **THEN** the chat shows the revision in use and the revisions available

#### Scenario: Switch
- **WHEN** the player types /ddt revision 1
- **THEN** revision 1 is used from then on and the chat says so

#### Scenario: Invalid number
- **WHEN** the player types /ddt revision 9
- **THEN** nothing changes and the chat lists the valid revisions

### Requirement: Existing switches keep working
The system SHALL apply the player's saved switches under every revision: an ability switched off is never flagged, and the skipped-ranks kind switched off flags no skipped rank. Switches are identified by spell, so a switch set before revisions existed SHALL mean the same spell afterwards.

#### Scenario: Ability switched off
- **WHEN** the player had switched off warnings for Rend before upgrading and Rend rank 5 is skipped in the chosen revision
- **THEN** Rend rank 5 is not flagged

#### Scenario: Skipped ranks switched off
- **WHEN** the skipped-ranks switch is off
- **THEN** no rank is flagged for being skipped, whatever the revision

### Requirement: Skips are per spec
The system SHALL let a revision skip a rank for some specs of a class only. A rank SHALL be skipped for a player only when every spec still plausible for that player skips it. When no spec is known to be implausible, that means every spec of the class.

#### Scenario: Skipped by every plausible spec
- **WHEN** a revision skips a rank for Frost and Fire and the player's talents rule out Arcane
- **THEN** the rank is skipped

#### Scenario: Bought by one plausible spec
- **WHEN** a revision skips a rank for Arms but not for Fury, and both specs are plausible
- **THEN** the rank is not skipped

#### Scenario: Spec picked by the player
- **WHEN** the player picks Arms as their spec
- **THEN** the rank is skipped

### Requirement: Revisions can build on an earlier one
The system SHALL let a revision list only what it changes from an earlier revision. A rank the later revision names SHALL replace the earlier revision's entry for that rank, and a rank it does not name SHALL keep the earlier revision's entry.

#### Scenario: Rank not named
- **WHEN** revision 2 builds on revision 1 and does not name Disengage rank 2
- **THEN** Disengage rank 2 is skipped as in revision 1

#### Scenario: Skip removed
- **WHEN** revision 2 names a rank as not skipped that revision 1 skipped
- **THEN** the rank is not skipped in revision 2

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

### Requirement: Wowhead decides where it has a view
The system SHALL treat a Wowhead leveling guide's advice for a spec, spell and rank as the decision for that spec, spell and rank. Where no guide has advice, the computed review SHALL decide. Rank 1 of a spell SHALL never be skipped.

#### Scenario: Guide says buy, computation says skip
- **WHEN** a Wowhead guide trains Moonfire rank 3 for Balance and the computed review would skip it
- **THEN** the rank is not skipped for Balance

#### Scenario: Guide says skip, computation says buy
- **WHEN** a Wowhead guide advises only rank 1 of Thunder Clap and the computed review would buy rank 3
- **THEN** rank 3 is skipped for Arms, Fury and Protection

#### Scenario: Rank 1
- **WHEN** a rank is the first rank of its spell
- **THEN** it is never skipped

### Requirement: Level 60 ranks
The system SHALL train the first rank of any spell that unlocks at level 60, whatever kind of spell it is. A later rank that unlocks at level 60 of an offensive or defensive spell SHALL be trained at 60. Any other later rank that unlocks at level 60 SHALL be skipped until the player has bought their level 60 mount, by the same rule that ends every skip when the mount is bought, unless a Wowhead guide trains it at 60.

#### Scenario: First rank at 60
- **WHEN** a spell's first rank unlocks at level 60
- **THEN** it is not skipped

#### Scenario: Damage rank at 60
- **WHEN** a later rank of a damage or healing spell unlocks at level 60 and no guide says otherwise
- **THEN** it is not skipped

#### Scenario: Utility rank at 60
- **WHEN** a later rank of a utility spell unlocks at level 60 and no guide trains it
- **THEN** it is skipped and the reason says to wait for the level 60 mount

#### Scenario: Mount bought
- **WHEN** the player has bought the level 60 mount
- **THEN** no rank is skipped any more

### Requirement: Rank numbers follow the game
The system SHALL identify a skipped rank by the spell and its rank number as the game's tables list them for WoW: Forever, so a rank unlocked at a different level than in Classic Era is judged by its own level and rank number.

#### Scenario: Reworked spell
- **WHEN** a spell has a rank in Forever that Classic Era does not
- **THEN** its skips are those recorded for the Forever rank numbers

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

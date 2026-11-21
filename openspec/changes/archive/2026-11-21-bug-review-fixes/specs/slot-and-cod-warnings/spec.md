## ADDED Requirements

### Requirement: Reused dialogs and repeated resets
A guard on a game dialog SHALL follow the kind of dialog it shows now, and each pet reset SHALL record the price quoted for that reset.

#### Scenario: Talent reset then COD in the same dialog
- **WHEN** the player cancels a talent reset and later cancels a COD shown in the same dialog frame
- **THEN** the COD warning still shows next time, and an ordinary mail take records nothing as spent

#### Scenario: Second Forever pet reset
- **WHEN** the player resets the pet twice on WoW Forever at rising prices
- **THEN** each reset is recorded at its own price

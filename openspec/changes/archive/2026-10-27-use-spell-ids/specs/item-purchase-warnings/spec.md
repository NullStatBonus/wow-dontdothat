## MODIFIED Requirements

### Requirement: Class item families
The system SHALL let a class's rule data name item families that are warned about at vendors, recognising each item by its item ID and not by its name, with a list of families that are kept, a plain-language reason, and no change to the item categories. The warning SHALL follow the Shopping switch, the minimum price and the ask-before-buying setting like any other item warning.

#### Scenario: Warlock grimoire
- **WHEN** a warlock buys a secondary demon grimoire, such as Grimoire of Soothing Kiss (Rank 2), from a demon trainer for more than the minimum price
- **THEN** the warning sound plays and an Accept / Cancel question says secondary demon abilities can wait, and the purchase completes only if accepted

#### Scenario: Any client language
- **WHEN** the game shows the grimoire under a name in another language
- **THEN** it is warned about exactly as on an English client

#### Scenario: Kept grimoires
- **WHEN** a warlock buys a grimoire the expert guides recommend, such as Grimoire of Firebolt (Rank 3), Grimoire of Torment (Rank 2), Grimoire of Blood Pact (Rank 2) or Grimoire of Spell Lock (Rank 1)
- **THEN** no question is shown

#### Scenario: Other classes
- **WHEN** a mage buys a grimoire
- **THEN** it is judged by its item category only

#### Scenario: A name is not enough
- **WHEN** an item that is not a grimoire has a grimoire's name
- **THEN** it is judged by its item category only

#### Scenario: Shopping off
- **WHEN** the Shopping area is turned off
- **THEN** grimoire purchases are not asked about

#### Scenario: Below the minimum price
- **WHEN** a grimoire costs less than the minimum price
- **THEN** no question is shown

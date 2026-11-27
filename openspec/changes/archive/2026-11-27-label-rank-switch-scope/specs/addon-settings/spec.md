## ADDED Requirements

### Requirement: Ability switch scope
The system SHALL save the switch of an ability on a class page for the whole spell, so it applies to every rank, and SHALL say so on the page: each list that has switches (Save your gold, Not worth buying yet, Ranks to skip) shows one line above its rows stating that each switch covers every rank of the spell, not only the ranks listed there. Read-only lists and lists with no rows SHALL NOT show the line.

#### Scenario: Switch a spell that lists some ranks
- **WHEN** the player turns off a spell in Ranks to skip, whose row names only some of its ranks
- **THEN** the addon stops marking every rank of that spell, and the list's note says each switch covers every rank

#### Scenario: Read-only list
- **WHEN** the player opens Worth buying or Optional
- **THEN** the lists have no switches and show no scope note

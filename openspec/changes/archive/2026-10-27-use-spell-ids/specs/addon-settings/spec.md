## ADDED Requirements

### Requirement: Spell switches are saved by spell
The system SHALL save the player's per-spell on/off choices against the spell's identity, so the choices survive a change of client language.

#### Scenario: Language change
- **WHEN** a player turns off warnings for a spell and later starts the game in another language
- **THEN** that spell is still switched off

## ADDED Requirements

### Requirement: Save gold as a Warlock or Paladin
The system SHALL treat the spells in the expert guides' recommended lists (Icy Veins' "Recommended Skills to Upgrade" and Wowhead's spec guides) as worth buying for Warlocks and Paladins, and SHALL list the spells those guides do not mention as not worth buying yet, even though both classes get a free level 40 mount, because the aim is still to save gold. It SHALL keep a Warlock demon's grimoire unflagged when the guides recommend it, and flag the other grimoires.

#### Scenario: Recommended Paladin spell
- **WHEN** a Paladin of any spec evaluates Lay on Hands, Blessing of Protection, Blessing of Freedom or Divine Intervention
- **THEN** it is kept

#### Scenario: Unrecommended Paladin spell
- **WHEN** a Paladin evaluates Exorcism, Holy Wrath or Blessing of Kings
- **THEN** the verdict is defer-low-value

#### Scenario: Optional by the guides' own words
- **WHEN** a Paladin evaluates Devotion Aura
- **THEN** it is listed as optional, since the guide says it can be skipped to save gold

#### Scenario: Recommended Warlock spell
- **WHEN** a Warlock evaluates Ritual of Summoning, Unending Breath, Howl of Terror, Death Coil or Inferno
- **THEN** it is kept

#### Scenario: Unrecommended Warlock spell
- **WHEN** a Warlock evaluates Searing Pain, Soul Fire, Banish or Create Firestone
- **THEN** the verdict is defer-low-value

#### Scenario: Hammer of Justice ranks
- **WHEN** a Paladin evaluates Hammer of Justice rank 2
- **THEN** the verdict is defer, because Icy Veins says to take just rank 1

### Requirement: Resurrections and interrupts are worth buying
The system SHALL treat every single-target resurrection spell and every interrupt as worth buying for every spec of its class, whatever the player's talents lean toward, and SHALL NOT list one as optional, low value or waiting. Where an interrupt comes from a talent, it counts only while the talent is active.

#### Scenario: Resurrection
- **WHEN** a druid, priest, paladin or shaman of any spec evaluates their single-target resurrection
- **THEN** it is kept

#### Scenario: Interrupt
- **WHEN** a mage, rogue, warrior or Shadow priest evaluates Counterspell, Kick, Pummel, Shield Bash or Silence
- **THEN** it is kept (Silence once its talent is active)

### Requirement: Unverified spells are optional
The system SHALL list a spell that the game data shows is not learned the ordinary way, or that has not been confirmed at a real trainer, as optional rather than worth buying until it is confirmed, except for interrupts and resurrections.

#### Scenario: Forever-only spell
- **WHEN** a druid evaluates Savage Roar
- **THEN** it is listed as optional

### Requirement: Leveling-based spell assessment
The system SHALL judge every class's spells by how they are used in common leveling builds: a spell a leveling spec relies on is kept for that spec, a spell only other specs use is judged as mostly used by them, a spell nobody levels with is defer-low-value, and group, raid, PvP and level 60 spells wait. A spell the brief calls skippable SHALL still be kept for the specs that use it.

#### Scenario: Smite for a Holy priest
- **WHEN** a Holy priest evaluates Smite
- **THEN** it is kept

#### Scenario: Smite for a Shadow priest
- **WHEN** a Shadow priest evaluates Smite
- **THEN** it is judged as mostly used by other specs

#### Scenario: Thunder Clap for an Arms warrior
- **WHEN** an Arms warrior evaluates Thunder Clap
- **THEN** it is kept

#### Scenario: Undecided talents
- **WHEN** a player has spent no talent points
- **THEN** every spell any spec keeps is kept

### Requirement: Rank skips come from expert guides
The system SHALL flag a spell rank as skippable only where the class rule data lists it, and the class rule data SHALL list a rank only on the guidance of expert leveling guides (Wowhead's "Spells to Buy" guides and Icy Veins' level-by-level walkthroughs): a rank that a guide states to skip, or that no guide buys. A rank that any guide buys SHALL NOT be listed. The system SHALL NOT work out skippable ranks from rank power, level gaps or any other computation, SHALL NOT skip rank 1, and SHALL show every listed rank to the player with the plain reason that it is only a small upgrade.

#### Scenario: Rank 1 is kept
- **WHEN** a rogue evaluates Gouge rank 1
- **THEN** it is not flagged

#### Scenario: Listed rank skipped
- **WHEN** a rogue evaluates a rank the class data lists as skipped
- **THEN** the verdict is defer with a reason that it is only a small upgrade

#### Scenario: Unlisted rank
- **WHEN** a rank is not in the class data's skip list
- **THEN** it is not flagged for being a small upgrade, whatever its level or price

#### Scenario: Guides disagree
- **WHEN** one guide skips a rank that another guide buys
- **THEN** the rank is not listed as skipped

#### Scenario: No guidance
- **WHEN** the expert guides give no rank advice for a class
- **THEN** that class has no skipped ranks

### Requirement: Evaluation order
The system SHALL resolve a verdict in this order: explicit rank skip, explicit per-action override, spec-aware rotation membership, ability tags, then keep. The first rule that applies SHALL decide the verdict.

#### Scenario: Override beats tag
- **WHEN** an ability is tagged PvP but has an explicit "keep" override
- **THEN** the verdict is "keep"

#### Scenario: Skipped rank beats the rotation
- **WHEN** a rank of a core spell is in the skip list
- **THEN** that rank is deferred and the spell's other ranks keep their verdict

### Requirement: Switch order
A switched-off ability SHALL get a keep verdict before any other rule is considered. A switched-off tag SHALL be evaluated as if the ability did not carry it. A switched-off rule kind SHALL be skipped, and evaluation continues to the next rule.

#### Scenario: Ability off
- **WHEN** an ability is switched off and it would otherwise be flagged by any rule
- **THEN** the verdict is "keep"

#### Scenario: Tag off
- **WHEN** an ability is flagged only by a PvP tag and the PvP tag is switched off
- **THEN** evaluation continues past the tag rule and, if nothing else applies, the verdict is "keep"

#### Scenario: Rule kind off
- **WHEN** skipped ranks are switched off
- **THEN** a rank in the skip list is not flagged

### Requirement: Profession margin setting
The system SHALL take the profession near-cap margin from player settings when set, and from rule data otherwise. Values SHALL be whole numbers of zero or more; anything else is ignored and the rule data value is used.

#### Scenario: Tighter margin
- **WHEN** the player sets the near-cap margin to 10 and the skill is 15 below the cap
- **THEN** the profession tier is flagged

#### Scenario: Invalid value
- **WHEN** a setting holds a negative or non-numeric value
- **THEN** the rule data value is used

## MODIFIED Requirements

### Requirement: Verdict for a proposed action
The system SHALL evaluate a proposed action against the player's profile and return a verdict containing a tier, an estimated cost in copper, a reason, and the milestone the saving applies to.

#### Scenario: Flagged action
- **WHEN** a Hunter below level 40 evaluates training a spell that the rules mark as deferred
- **THEN** the verdict has a non-"keep" tier, a cost, a reason, and the level 40 milestone

#### Scenario: Unknown action
- **WHEN** an action matches no rule or tag
- **THEN** the verdict is "keep" and no warning is produced

### Requirement: Player rule switches
The system SHALL let player settings switch off a single ability, a tag for a class, or a rule kind (skipped ranks, off-spec leaning, profession skill caps). Everything is on by default, so with no settings changed every verdict is unchanged.

#### Scenario: Switch stored
- **WHEN** the player switches off an ability and reloads the game
- **THEN** the ability is still switched off

## REMOVED Requirements

### Requirement: Rank supersession
**Reason**: Skipped ranks come from expert guidance written into the class data, not from a level-gap rule.
**Migration**: None; the Tuning window setting and the supersession switch are removed with it.

### Requirement: Rank skips need evidence
**Reason**: Replaced by "Rank skips come from expert guides"; a computed power rule was dropped.
**Migration**: The class data lists the ranks the guides say to skip.

### Requirement: Evaluation precedence
**Reason**: Replaced by "Evaluation order", which no longer has the rank supersession step.
**Migration**: None.

### Requirement: Switch precedence
**Reason**: Replaced by "Switch order", without the supersession scenarios.
**Migration**: None.

### Requirement: Tunable thresholds
**Reason**: Replaced by "Profession margin setting"; the rank window setting is removed.
**Migration**: None.

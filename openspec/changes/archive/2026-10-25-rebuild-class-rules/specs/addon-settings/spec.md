## MODIFIED Requirements

### Requirement: Rules review and controls
The system SHALL display the active rule set organized by class and by what the player is told: Worth buying, Optional, Save your gold, Not worth buying yet, and Ranks to skip. Every list SHALL be divided into titled groups: Worth buying, Optional and Ranks to skip by spec (All specs first, then each spec), Save your gold and Not worth buying yet by why they wait (for example spells for groups and raids, or for level 60), and any skill a Pet Trainer teaches the player's pet in a Pet group that comes last. Skills that come with a class and are never trained, such as a Hunter's Auto Shot, SHALL NOT be listed; trained skills such as Dual Wield and armor proficiencies SHALL be. Every other spell family in a class's rule data and bundled table SHALL appear in at least one list, each with its reason, unless the class's rule data records it as reviewed (a passive, effect or talent grant that is not a purchase), in which case the page SHALL NOT show it. Selecting a class SHALL show an overview above its lists: what each of its specs could keep by following every rule, up to the level 40 mount and up to the level 60 mount side by side, whatever the player has switched off, and how many spells each list holds. Every switch that changes what is flagged (the rule kinds on Tuning, each kind of spell on a class page and each spell in a list) SHALL show beneath it what it is worth in gold: the projected savings with it on minus the savings with it off, with the player's other settings, up to the stop-after mount, and a spell switched off SHALL still show its value. It SHALL let the player switch off any single ability, switch off any tag for a class, switch off any rule kind (skipped ranks, off-spec leaning) from Tuning, and choose a spec per class from Automatic or that class's specs. All switches are on and every class is Automatic by default, and changes apply without a reload.

#### Scenario: Browse Hunter rules
- **WHEN** the player opens the Rules page and selects Hunter
- **THEN** each ability is listed with its icon and reason, each with a switch, along with the tag switches and the My spec dropdown

#### Scenario: Class overview
- **WHEN** the player selects Mage under Advanced > Classes
- **THEN** under "Savings by spec: level 40 / level 60" the page lists Arcane, Fire and Frost, each with its level 40 and level 60 savings, and the number of spells in each list, whatever rules the player has switched off

#### Scenario: Gold on a switch
- **WHEN** the player looks at the skip-ranks switch on Tuning
- **THEN** a muted line under it says what it is worth, such as "Worth about 101g by your level 60 mount", and a switch that changes nothing says it is worth nothing for their spec

#### Scenario: Pet spells
- **WHEN** a Hunter opens Worth buying
- **THEN** Growl, Great Stamina and Natural Armor are in a Pet group after the spec groups

#### Scenario: Waiting spells by reason
- **WHEN** a Hunter opens Save your gold
- **THEN** Distracting Shot is under the group and raid spells and Wyvern Sting under the level 60 spells

#### Scenario: Built-in skills
- **WHEN** a Hunter opens any list
- **THEN** Auto Shot is not shown, while Dual Wield and Mail are

#### Scenario: Switching off an ability
- **WHEN** the player switches off Arcane Shot
- **THEN** the next trainer view shows no mark on it and a purchase of it is not asked about

#### Scenario: Switching off a tag
- **WHEN** the player switches off the PvP tag for Hunter
- **THEN** abilities that were flagged only because of that tag are no longer flagged

#### Scenario: Switching off a rule kind
- **WHEN** the player switches off skipped ranks
- **THEN** ranks are no longer flagged for being a small upgrade

#### Scenario: Choosing a spec
- **WHEN** the player picks Marksmanship for Hunter
- **THEN** warnings treat Marksmanship as the player's only spec, whatever the talents say

#### Scenario: Spec options follow the class data
- **WHEN** a class's rules list its specs
- **THEN** the dropdown offers Automatic and exactly those specs

#### Scenario: Worth buying lists the core spells by spec
- **WHEN** the player opens Mage
- **THEN** Worth buying has an All specs group and a group each for Arcane, Fire and Frost, and Frostbolt is under Frost

#### Scenario: Optional lists the situational spells
- **WHEN** the player opens Rogue
- **THEN** Optional lists the situational spells such as Rupture, grouped by spec

#### Scenario: Every spell is somewhere
- **WHEN** a class's bundled spell table lists a spell family
- **THEN** that family appears in one of the lists, or is on the class's reviewed list of passives, effects and talent grants, which the page does not show

#### Scenario: Ranks to skip for every class
- **WHEN** the player opens Priest
- **THEN** Ranks to skip lists spells with the ranks to skip, such as Psychic Scream ranks 2, 3 and 4

### Requirement: Tuning section
The system SHALL provide a Tuning section on Advanced with the marks and questions switches, the rule kind switches (skipped ranks and off-spec leaning) and a choice of which tiers ask for confirmation and play the warning sound, where any combination of tiers may be chosen. The stop-after-mount choice (level 40 mount or level 60 mount) SHALL be on Home, and the profession near-cap margin and its on/off switch SHALL be in the Professions area of What to watch. Defaults are the current behavior: 25 points, level 60 mount, and only "Save your gold".

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** Tuning shows only "Save your gold" ticked, What to watch shows 25 points, and Home shows the level 60 mount

#### Scenario: Picking several tiers
- **WHEN** the player ticks both "Save your gold" and "Not worth buying yet"
- **THEN** both tiers ask and sound on a purchase attempt

#### Scenario: No tiers
- **WHEN** the player ticks no tier
- **THEN** nothing asks or sounds, and badges and tooltips continue

#### Scenario: Reset
- **WHEN** the player confirms Reset all settings on Home
- **THEN** the profession margin and prompt tiers return to their defaults

### Requirement: Consistent page layout
The system SHALL give every settings page the same structure and look: a title and one-line introduction, then sections each with a heading and a blank line above it, using one type scale and one muted note color throughout, with the same blank line between lines that would otherwise run together (read-only lists, the mounts, and the kept and projected amounts). Amounts SHALL be shown as bulleted lines of a colored label followed by the amount, never in columns, and a page SHALL NOT have two blank lines in a row.

#### Scenario: Same look on every page
- **WHEN** the player opens each of the five pages in turn
- **THEN** titles, section headings, body text and notes appear in the same sizes and colors on all of them

#### Scenario: Cooldown default
- **WHEN** the addon runs for the first time
- **THEN** the Advanced cooldown slider shows the default of 3 seconds

#### Scenario: Headings appear once
- **WHEN** the player opens Progress
- **THEN** Milestones and Tally each show their heading once

#### Scenario: Amounts read the same everywhere
- **WHEN** the player compares the Tally, the projected savings and a class overview
- **THEN** each amount is a bulleted colored label followed by the amount, with a blank line between lines

### Requirement: Advanced section
The system SHALL keep the deeper controls on an Advanced page and out of the way of the other pages: Sound & messages (sound, volume channel, cooldown and the on-screen message), Tuning, Classes (the per-class rule review), and Debug. Nothing on Advanced SHALL be needed to use the addon with its defaults.

#### Scenario: Reaching the deep controls
- **WHEN** the player opens Advanced
- **THEN** the sound controls, Tuning, Classes and Debug are each one step away

#### Scenario: Plain defaults
- **WHEN** the player never opens Advanced
- **THEN** the addon behaves with its default tuning, sound and rule switches

### Requirement: What to watch areas
The system SHALL provide a What to watch page with four areas, Spells, Professions, Shopping and Other, all on by default. Spells, Professions and Shopping SHALL each have an on/off control; turning one off SHALL stop its marks, questions and sounds without changing the settings inside it. Spells covers class and pet trainers and the Recommended filter, Professions covers profession ranks, the first-time warning when learning a profession, the switch for marking ranks you can't use yet and the skill margin, and Shopping covers vendor and auction house purchases. Other has no control of its own: it holds the bank slot, stable slot and COD mail switches.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all four areas are on

#### Scenario: Turning an area off
- **WHEN** the player turns Shopping off
- **THEN** vendor and auction purchases are no longer marked or asked about, and the category modes and minimum price keep their values

#### Scenario: Turning it back on
- **WHEN** the player turns Shopping on again
- **THEN** the category modes and minimum price are as they were

#### Scenario: Profession settings together
- **WHEN** the player opens the Professions area
- **THEN** the warning switch, the switch for ranks they can't use yet and the skill margin are all there

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other settings reset. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete), and SHALL turn debug recording off.

#### Scenario: Resetting
- **WHEN** the player has changed settings on several pages and confirms Reset all settings
- **THEN** every setting returns to its default and Home shows Ask me first

#### Scenario: Declining
- **WHEN** the player declines the confirmation
- **THEN** no setting changes

#### Scenario: Kept
- **WHEN** the player resets all settings
- **THEN** the tally, the professions already asked about and any milestone marked complete are unchanged

#### Scenario: No other reset controls
- **WHEN** the player looks through Tuning, What to watch and Classes
- **THEN** none of them has a reset control

## ADDED Requirements

### Requirement: Projected savings
The system SHALL show on the Progress page the projected savings for the player's character: the trainer gold kept by following the addon's advice up to the level of the mount the player is saving for (the stop-after setting), using the character's spec (detected or chosen) and every current setting, split into Save your gold, Not worth buying yet and Ranks to skip. It SHALL count every purchasable class and pet rank up to that level that the rules would warn about, SHALL NOT count Worth buying or Optional spells or the first rank of a talent, and SHALL price each rank with the price seen at the player's trainer, else the trainer price listed by Wowhead, else an estimate for the rank's level, saying which kinds of price it used.

#### Scenario: Following the plan
- **WHEN** a Frost mage who is saving for the level 40 mount opens Progress
- **THEN** the projected savings add up the prices of the ranks up to level 40 that the rules mark as waiting, low value or skipped

#### Scenario: Settings change the number
- **WHEN** the player switches off the PvP tag
- **THEN** the projected savings drop by the price of the spells that only that tag flagged

#### Scenario: Price from the trainer
- **WHEN** the player has seen a rank's price at a trainer
- **THEN** that price is used in place of the listed one

#### Scenario: Not logged in
- **WHEN** the character cannot be read
- **THEN** the page says to log in on a supported character


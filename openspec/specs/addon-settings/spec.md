# addon-settings Specification

## Purpose
Gives players a standard place in the game's options to control the addon and to review how it works, using familiar patterns found in other addons.

## Requirements

### Requirement: Options category with subpages
The system SHALL register Don’t Do That in Options > AddOns with real Home controls on the root and What to watch, Progress, Appearance, Advanced and About listed beneath it in order. Standalone AceConfig SHALL expose the same six landmarks. Root entry SHALL NOT be an empty placeholder. Registration failure SHALL leave standalone settings available.

#### Scenario: Opening settings
- **WHEN** the root Don’t Do That entry is selected
- **THEN** top-level Home controls are immediately usable

#### Scenario: Child entry
- **WHEN** Appearance is selected under the addon
- **THEN** the same effective controls and saved values as standalone Appearance are shown

### Requirement: Master and per-feature toggles
The system SHALL provide an overall enable control and independent controls for blocking confirmations, badges and tooltips, alerts, and the Recommended trainer filter, all on by default. The Recommended switch SHALL control whether the filter is offered in the trainer's Filter menu at all, and the menu's own checkbox SHALL remember separately whether the filter is applied.

#### Scenario: First install
- **WHEN** the addon runs for the first time
- **THEN** every toggle is on

#### Scenario: Filter toggle
- **WHEN** the player turns off the Recommended filter setting
- **THEN** supported trainers show all rows and the Filter menu no longer has the Recommended entry

#### Scenario: Addon turned off
- **WHEN** the player turns off the addon while a trainer is open
- **THEN** all rows return at once and the Filter menu no longer has the Recommended entry

#### Scenario: Unticking in the menu
- **WHEN** the player unticks Recommended in the trainer's Filter menu
- **THEN** all rows return, and the entry stays available so it can be ticked again

#### Scenario: Master off
- **WHEN** the overall enable is turned off
- **THEN** no warnings, prompts, or alerts occur

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

### Requirement: Milestones and help content
The system SHALL show milestone targets and status on the Progress page, and explain the signals, tiers, and verified versus projected savings on the About page.

#### Scenario: About page
- **WHEN** the player opens About
- **THEN** it explains badge, tooltip, prompt, and alert and shows the addon version

### Requirement: Tally view
The system SHALL show verified savings, projected savings, spent-against-rules, and respec counts on the Progress page, with a reset control.

#### Scenario: Tally display
- **WHEN** the player opens Progress
- **THEN** verified and projected totals are shown separately

### Requirement: Settings persistence
The system SHALL persist settings across sessions and apply changes immediately without a reload.

#### Scenario: Toggle takes effect
- **WHEN** the player turns off alerts
- **THEN** the next flagged attempt produces no sound

### Requirement: Slash commands
The system SHALL provide `/ddt` and `/dontdothat` to open Home and run the common and legacy commands in slash-interface. `/ddt log` SHALL be the primary diagnostic report command and export SHALL remain its alias.

#### Scenario: Open settings
- **WHEN** the player enters `/ddt`
- **THEN** the addon's settings open

### Requirement: Purchases page
The system SHALL provide a Shopping area on the What to watch page with a minimum price control made of gold, silver, and copper boxes labeled with their coin icons, and a collapsed "Choose categories" section with one dropdown per item category offering Off, Vendor, AH, and Both, followed by a list of the items allowed on this character, each with its icon, name and a Remove button.

#### Scenario: Every category listed
- **WHEN** the player opens Choose categories
- **THEN** all thirteen categories appear, including those that default to Off

#### Scenario: Collapsed by default
- **WHEN** the player opens What to watch
- **THEN** the category dropdowns are not shown until Choose categories is opened

#### Scenario: Changing a mode
- **WHEN** the player changes a category's dropdown
- **THEN** the next matching purchase follows the new mode without a reload

#### Scenario: Entering the minimum
- **WHEN** the player enters 10 in the silver box
- **THEN** the minimum price is 10 silver

#### Scenario: Overflowing a box
- **WHEN** the player enters 150 in the copper box
- **THEN** the boxes show 1 silver 50 copper

#### Scenario: Invalid entry
- **WHEN** the player enters something that is not a whole number of zero or more
- **THEN** the previous value is kept

#### Scenario: Default minimum
- **WHEN** the addon runs for the first time
- **THEN** the boxes show 0 gold, 1 silver, 0 copper

#### Scenario: Reset to defaults
- **WHEN** the player confirms Reset all settings on Home
- **THEN** all category modes and the minimum price return to their defaults

#### Scenario: Allowed items listed
- **WHEN** the player chose Always Allow for Mageweave Bag and opens What to watch
- **THEN** the Shopping area lists Mageweave Bag with a Remove button

#### Scenario: Removing an allowed item
- **WHEN** the player clicks Remove next to an allowed item and then buys that item
- **THEN** the item is gone from the list and the purchase is warned about as before

#### Scenario: No allowed items
- **WHEN** the character has no allowed items
- **THEN** the Shopping area says how to allow an item from the question

### Requirement: Slot and COD switches
The system SHALL provide three switches in the Other area of the What to watch page, one each for bank slots, stable slots, and COD mail, all on by default, taking effect without a reload.

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** all three switches are on

#### Scenario: Turning one off
- **WHEN** the player turns off COD mail warnings
- **THEN** the next COD payment uses the game's own dialog and the other two kinds are unaffected

#### Scenario: Back to defaults
- **WHEN** the player confirms Reset all settings on Home
- **THEN** the three switches return to on

### Requirement: Consistent page layout
The system SHALL give every settings page the same structure and look: a title and one-line introduction, then sections each with a heading and a blank line above it, using one type scale and one muted note color throughout, with the same blank line between lines that would otherwise run together (read-only lists, the mounts, and the kept and projected amounts). Amounts SHALL be shown as bulleted lines of a colored label followed by the amount, never in columns, and a page SHALL NOT have two blank lines in a row.

#### Scenario: Same look on every page
- **WHEN** the player opens each of the six pages in turn
- **THEN** titles, section headings, body text and notes appear in the same sizes and colors on all of them

#### Scenario: Cooldown default
- **WHEN** the addon runs for the first time
- **THEN** the Appearance > Sound cooldown slider shows the default of 3 seconds

#### Scenario: Headings appear once
- **WHEN** the player opens Progress
- **THEN** Milestones and Tally each show their heading once

#### Scenario: Amounts read the same everywhere
- **WHEN** the player compares the Tally, the projected savings and a class overview
- **THEN** each amount is a bulleted colored label followed by the amount, with a blank line between lines

### Requirement: Tuning section
The system SHALL provide a Tuning section on Advanced with the marks and questions switches, the rule kind switches (skipped ranks and off-spec leaning) and a choice of which tiers ask for confirmation and play the warning sound, where any combination of tiers may be chosen. The stop-after-mount choice (level 40 mount or level 60 mount) SHALL be on Home. Defaults are the current behavior: level 60 mount, and only "Save your gold".

#### Scenario: Defaults
- **WHEN** the addon runs for the first time
- **THEN** Tuning shows only "Save your gold" ticked, and Home shows the level 60 mount

#### Scenario: Picking several tiers
- **WHEN** the player ticks both "Save your gold" and "Not worth buying yet"
- **THEN** both tiers ask and sound on a purchase attempt

#### Scenario: No tiers
- **WHEN** the player ticks no tier
- **THEN** nothing asks or sounds, and badges and tooltips continue

#### Scenario: Reset
- **WHEN** the player confirms Reset all settings on Home
- **THEN** the prompt tiers return to their defaults

### Requirement: Alert channel control
The system SHALL let the player pick the sound channel used for the warning sound from Master, Sound effects, Music, Ambience and Dialog, defaulting to Master.

#### Scenario: Picking a channel
- **WHEN** the player picks Dialog
- **THEN** the next warning sound plays on that channel

### Requirement: Home page and nudge level
The system SHALL provide a Home page with the overall on/off control, a choice of how firmly the addon nudges the player, and the "stop warning me after" mount choice, plus the on-screen message enable toggle backed by the existing alert.banner value. The root game-options entry SHALL expose these same controls. The nudge choice SHALL offer Just mark things (marks only, never asks), Ask me first (marks, asks before buying what the player should wait on) and Ask about everything (also asks about low-value and informational items). Ask me first SHALL be the default. Each option SHALL carry its own one-line explanation. The choice SHALL be read from the saved marks, "Ask before buying" and prompt-tier settings rather than stored on its own, and SHALL show Custom as selected when those settings match none of the three, with a line that says what is set (whether marks are on, whether it asks, and which kinds of spell it asks about) and that choosing a level resets them or that they can be fine-tuned under Advanced > Tuning. Choosing a nudge level SHALL set those settings, and choosing Custom SHALL change nothing.

#### Scenario: Default
- **WHEN** the addon runs for the first time
- **THEN** Home shows Ask me first selected

#### Scenario: Choosing a level
- **WHEN** the player chooses Ask about everything
- **THEN** marks stay on, "Ask before buying" is on, and all three tiers ask

#### Scenario: Custom
- **WHEN** the player changes the prompt tiers in Advanced so that they match none of the three levels
- **THEN** Home shows Custom selected, and says that marks are on and which kinds of spell it asks about

#### Scenario: Sound does not affect the level
- **WHEN** the player turns the warning sound off in Appearance > Sound
- **THEN** Home still shows the same nudge level

#### Scenario: Heading and stop choice
- **WHEN** the player opens Home
- **THEN** the levels sit under "When you're about to buy something that can wait", and the stop choice sits under "When to stop warning me" and reads "After my level 60 mount" or "After my level 40 mount"

### Requirement: What to watch areas
The system SHALL provide a What to watch page with four areas, Spells, Professions, Shopping and Other, all on by default. Spells, Professions and Shopping SHALL each have an on/off control; turning one off SHALL stop its marks, questions and sounds without changing the settings inside it. Spells covers class and pet trainers and the Recommended filter, Professions covers the first-time warning when learning a profession, and Shopping covers vendor and auction house purchases. Other has no control of its own: it holds the bank slot, COD mail and talent reset switches, and for Hunters also the stable slot and pet skill reset switches.

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
- **THEN** it holds the warning switch and a note that it asks once, the first time the player learns a profession other than Fishing, Herbalism, Mining or Skinning

### Requirement: Advanced section
The system SHALL keep the deeper controls on an Advanced page and out of the way of the other pages: Tuning, Classes (the per-class rule review), Debug and scope information. Appearance SHALL own Warnings, Explanations and Sound (sound, channel and cooldown); only its on-screen message enable toggle remains on Home. Nothing on Advanced SHALL be needed to use the addon with its defaults.

#### Scenario: Reaching the deep controls
- **WHEN** the player opens Advanced
- **THEN** Tuning, Classes, Debug and scope guidance are reachable; sound is on Appearance > Sound

#### Scenario: Plain defaults
- **WHEN** the player never opens Advanced
- **THEN** the addon behaves with its default tuning, sound and rule switches

### Requirement: Reset all settings
The system SHALL provide one control, on Home, that puts every setting back to its default after the player confirms, and SHALL NOT provide any other full or per-feature settings reset. Appearance’s position-only Reset position is the sole exception and SHALL NOT reset any non-position value. It SHALL keep the tally and what the addon already knows the player has done (professions asked about and milestones marked complete), and SHALL turn debug recording off. It SHALL also clear the items allowed on the current character, and SHALL NOT change other characters' allowed items. The defaults SHALL take effect at once, without a reload.

#### Scenario: Resetting
- **WHEN** the player has changed settings on several pages and confirms Reset all settings
- **THEN** every setting returns to its default and Home shows Ask me first

#### Scenario: Warnings right after a reset
- **WHEN** the player confirms Reset all settings and then, without reloading, buys armor for more than 1 silver at a vendor
- **THEN** the purchase is warned about as with the default settings, and What to watch shows each category with its default choice

#### Scenario: Classes page after a reset
- **WHEN** the player picked an older skip revision, confirms Reset all settings and opens Classes
- **THEN** Classes lists the skips of the default (newest) revision

#### Scenario: Declining
- **WHEN** the player declines the confirmation
- **THEN** no setting changes

#### Scenario: Kept
- **WHEN** the player resets all settings
- **THEN** the tally, the professions already asked about and any milestone marked complete are unchanged

#### Scenario: No other reset controls
- **WHEN** the player looks through Tuning, What to watch and Classes
- **THEN** none has a settings-reset control; Appearance may reset position only

#### Scenario: Allowed items after a reset
- **WHEN** the player allowed an item on this character, confirms Reset all settings and buys that item
- **THEN** the purchase is warned about and the Shopping list is empty

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

### Requirement: Spell switches are saved by spell
The system SHALL save the player's per-spell on/off choices against the spell's identity, so the choices survive a change of client language.

#### Scenario: Language change
- **WHEN** a player turns off warnings for a spell and later starts the game in another language
- **THEN** that spell is still switched off

### Requirement: Skip revision choice
The system SHALL provide a choice of skip revision on the Tuning section, listing each revision with a one-line description and marking the newest as the default. Choosing one SHALL take effect at once for later purchases, and the choice SHALL be saved. Players who never choose SHALL be on the newest revision.

#### Scenario: Default shown
- **WHEN** a player who never chose opens Tuning
- **THEN** revision 3 is selected and marked as the default

#### Scenario: Go back
- **WHEN** the player selects revision 1
- **THEN** the Rules page and the trainer window use revision 1 from then on

#### Scenario: Description
- **WHEN** the player reads the choice
- **THEN** revision 1 is described as "Original using Expert Advice", revision 2 as "Revised with Rules + Expert Advice" and revision 3 as "Updated with WoW Forever Expert Advice"

### Requirement: Rules page shows the revision, source and reason
The system SHALL show on the Rules page the revision in use and, for every rank in Ranks to skip, the reason it is skipped. For skips whose decision was computed, the page SHALL also say that it was computed, and for skips that came from a Wowhead guide it SHALL say so. The list SHALL follow the chosen revision.

#### Scenario: Revision named
- **WHEN** the player opens the Rules page
- **THEN** the page names the revision in use

#### Scenario: Computed skip
- **WHEN** a rank is skipped by a computed decision
- **THEN** the Rules page lists its reason and says the decision was computed from the game data

#### Scenario: Guide skip
- **WHEN** a rank is skipped on a Wowhead guide's advice
- **THEN** the Rules page lists its reason and says it comes from the Wowhead guide

#### Scenario: Revision switched
- **WHEN** the player switches to revision 1
- **THEN** Ranks to skip lists revision 1's ranks with the reason revision 1 records for each

### Requirement: Character data survives a character-key change
When the settings library files this character under a different key than one used before (`Name - Realm`, where the realm part is empty on a client that gives no realm name, or on WoW Forever `Name Surname`), the system SHALL move the character's saved data (savings ledger, observed prices, mount marks, profession answers) and profile choice to the key in use at login, before anything reads them. It SHALL act at most once per key change, SHALL NOT overwrite data saved under the key in use, and SHALL change nothing when the keys are equal.

#### Scenario: WoW Forever character after the library update
- **WHEN** a WoW Forever character with savings and a chosen profile saved under `Name - Realm` logs in and the loaded library uses `Name Surname`
- **THEN** Progress shows the same savings and observed prices, and the character uses the same profile as before

#### Scenario: WoW Forever with no realm name
- **WHEN** a WoW Forever client gives an empty realm name, the character's savings and chosen profile are saved under `Name - ` (the name, a dash and nothing after it), and the loaded library uses `Name Surname`
- **THEN** Progress shows the same savings and observed prices, and the character uses the same profile as before

#### Scenario: Back to the older library
- **WHEN** a WoW Forever character with savings and a chosen profile saved under `Name Surname` logs in and the loaded library uses `Name - Realm` again
- **THEN** Progress shows the same savings and observed prices, and the character uses the same profile as before

#### Scenario: Forward again
- **WHEN** the same character later logs in with a library that uses `Name Surname` again
- **THEN** the data and profile choice move back, and nothing is left under `Name - Realm`

#### Scenario: Later logins
- **WHEN** the same character logs in again after the move
- **THEN** nothing is moved or changed

#### Scenario: Profile changed after the move
- **WHEN** the player picks another profile after the move and then logs in again
- **THEN** the character keeps the profile the player picked

#### Scenario: Classic Era
- **WHEN** a Classic Era character logs in and both keys are the same
- **THEN** the saved data and profile choice are not touched

#### Scenario: Data already under the new key
- **WHEN** the character already has saved data under the new key
- **THEN** that data stays as it is and the data under the old key is not copied over it

### Requirement: Ability switch scope
The system SHALL save the switch of an ability on a class page for the whole spell, so it applies to every rank, and SHALL say so on the page: each list that has switches (Save your gold, Not worth buying yet, Ranks to skip) shows one line above its rows stating that each switch covers every rank of the spell, not only the ranks listed there. Read-only lists and lists with no rows SHALL NOT show the line.

#### Scenario: Switch a spell that lists some ranks
- **WHEN** the player turns off a spell in Ranks to skip, whose row names only some of its ranks
- **THEN** the addon stops marking every rank of that spell, and the list's note says each switch covers every rank

#### Scenario: Read-only list
- **WHEN** the player opens Worth buying or Optional
- **THEN** the lists have no switches and show no scope note

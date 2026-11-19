# purchase-warnings Specification

## Purpose
Shows the player where a gold-spending action is not advised using one consistent set of signals across trainer, talent, respec, and profession surfaces, and asks for confirmation when the client allows it safely.

## Requirements

### Requirement: Consistent warning signals
The system SHALL use the same three signals for every surface: a badge on the affected item, a tooltip line stating the reason and cost, and a confirmation prompt for the defer tier where interception is possible.

#### Scenario: Flagged trainer row
- **WHEN** the player opens a class trainer showing a deferred spell
- **THEN** that row shows a badge and its tooltip includes the reason and cost

### Requirement: Information bubble
The information indicator SHALL show the tier recommendation, accurate reason and cost on hover and pin the same explanation on click. Pinned content SHALL use the shared readable hierarchy and dimmable black surface with native close action, grow for long text and clamp to screen. Hover SHALL remain silent; pinning SHALL NOT be mistaken for a purchase attempt.

#### Scenario: Mouseover
- **WHEN** the information indicator is hovered
- **THEN** the reason and cost appear with native tooltip chrome and no alert sound

#### Scenario: Click to pin
- **WHEN** the indicator is clicked
- **THEN** details remain visible until close, Escape or the same indicator toggles them off, without triggering a purchase

#### Scenario: Long pinned text
- **WHEN** a localized reason or earn-back line is long
- **THEN** height grows and all content stays readable and on screen; closing does not affect a real confirmation

### Requirement: Confirmation before proceeding
The system SHALL show a confirmation prompt before a purchase proceeds when its verdict tier is one the player chose to be asked about (only defer by default), and SHALL complete the action only if the player confirms.

#### Scenario: Player cancels
- **WHEN** the player declines the prompt
- **THEN** the purchase is not made

#### Scenario: Player confirms
- **WHEN** the player confirms the prompt
- **THEN** the purchase proceeds and is recorded as spent against the rules

#### Scenario: Extra tier chosen
- **WHEN** the player has chosen to be asked about defer-low-value and tries to buy such a spell
- **THEN** the prompt appears

#### Scenario: Tier not chosen
- **WHEN** a tier is not chosen
- **THEN** a purchase of that tier proceeds with no prompt, and its badge and tooltip still show

### Requirement: Graceful degradation
The system SHALL fall back to badge and tooltip on any surface where a confirmation prompt cannot be provided safely, and SHALL NOT silently do nothing.

#### Scenario: Interception unavailable
- **WHEN** a surface cannot be intercepted without risk of breaking the default interface
- **THEN** the badge and tooltip are still shown

### Requirement: No interference with the default interface
The system SHALL NOT break or disable the default trainer, talent, or profession interfaces, and SHALL NOT produce interface errors from its warning logic.

#### Scenario: Warning logic fails
- **WHEN** evaluating a row raises an error
- **THEN** the default interface continues to work and the error is logged when debugging is on

### Requirement: Covered surfaces
The system SHALL annotate class trainer services, talent selection, talent respec, pet or beast training services, profession trainer services for supported classes and professions, vendor purchases of flagged item categories, and auction house bids and buyouts of flagged item categories.

#### Scenario: Respec dialog
- **WHEN** the game opens its talent reset dialog while warnings are active
- **THEN** the warning sound plays and the game's own dialog stays up with the addon's note added; accepting resets the talents and cancelling leaves them alone

#### Scenario: Pet training reset
- **WHEN** the game opens its pet skill reset dialog while warnings are active
- **THEN** the warning sound plays and the game's own dialog stays up with the addon's note added

#### Scenario: Flagged vendor item
- **WHEN** the player buys an item from a vendor in a category whose mode includes Vendor, at or above the minimum price
- **THEN** the warning sound plays and an Accept / Cancel question is shown before the purchase

#### Scenario: Flagged auction
- **WHEN** the player bids on or buys out an auction in a category whose mode includes AH, at or above the minimum price
- **THEN** the warning sound plays and an Accept / Cancel question is shown before it is placed

### Requirement: Independent switches
The system SHALL let the player independently turn off blocking confirmations, badges and tooltips, alerts, and the Recommended trainer filter, with all on by default.

#### Scenario: Confirmations off
- **WHEN** blocking confirmations are disabled
- **THEN** no prompt appears but badges and tooltips continue

#### Scenario: Filter off
- **WHEN** the Recommended trainer filter is disabled
- **THEN** trainers show all rows and badges and tooltips continue

### Requirement: Inactive when not applicable
The system SHALL show no warnings for unsupported classes or professions, or once the mount the player chose to stop at is bought (detected or marked in settings). This SHALL cover every surface: trainers, vendors, the auction house, bank and stable slots, COD mail, and talent and pet resets. Warnings SHALL resume everywhere if the milestone becomes active again.

#### Scenario: Unsupported class
- **WHEN** the player is a class with no rule data
- **THEN** no warnings are shown

#### Scenario: Stopped after the level 40 mount
- **WHEN** the player chose to stop after the level 40 mount and has bought it
- **THEN** a flagged vendor or auction house purchase completes with no question, sound or message
- **AND** buying a bank or stable slot, paying a COD, or resetting talents or pet skills shows only the game's own dialog

#### Scenario: Milestone active again
- **WHEN** the milestone was finished and the player clears its "mark done" checkbox or moves the stop point to the level 60 mount before buying it
- **THEN** shopping and gold-sink warnings ask again

### Requirement: Recommended trainer filter
The system SHALL add a "Recommended" entry to the class and profession trainer's existing filter list that hides services whose verdict is defer or defer-low-value, and SHALL leave keep and informational services visible. It is in addition to badges, tooltips, and prompts.

#### Scenario: Flagged rows hidden
- **WHEN** Recommended is checked and the trainer lists a deferred spell
- **THEN** that row is not shown

#### Scenario: Kept rows stay
- **WHEN** Recommended is checked and the trainer lists a keep or informational spell
- **THEN** that row remains shown

#### Scenario: Filter unchecked
- **WHEN** Recommended is unchecked
- **THEN** all rows are shown and flagged rows keep their badge and tooltip

### Requirement: Recommended filter default
The system SHALL have the Recommended filter checked by default whenever the addon is enabled, and SHALL NOT add text of its own to the trainer window.

#### Scenario: First visit
- **WHEN** the player opens a supported trainer for the first time
- **THEN** the Recommended entry is checked

### Requirement: Filter never alters purchase targets
The system SHALL ensure that activating any visible trainer row sends the service index of the service that row displays, and SHALL NOT change which index purchase calls receive.

#### Scenario: Purchase from a filtered list
- **WHEN** rows are hidden and the player buys the third visible row
- **THEN** the spell shown on that row is the spell purchased

### Requirement: Filter scope and inactivity
The system SHALL apply the Recommended filter to class, profession, and pet trainer windows, not the Beast Training window, and SHALL show all rows, without offering the Recommended entry, when the addon is off. It SHALL also show all rows when the level 60 mount has been acquired or the class is unsupported.

#### Scenario: Deferral finished
- **WHEN** the level 60 mount has been acquired
- **THEN** the trainer shows all rows

### Requirement: Filter degrades safely
The system SHALL fall back to badge and tooltip when the Recommended filter cannot be installed safely, SHALL log the reason when debugging is on, and SHALL NOT hide any rows in that case.

#### Scenario: Install fails
- **WHEN** the trainer window differs from what the filter expects
- **THEN** all rows remain visible and flagged rows show badges and tooltips

### Requirement: One-time warning when learning a non-gathering profession
The system SHALL, when the player first trains a profession other than Fishing, Skinning, Herbalism or Mining while warnings are active, play the warning sound and ask Accept / Cancel with the profession's name and why leveling it costs gold, and SHALL train only on Accept. The question SHALL NOT show the lesson's price or an earn-back time. After either answer, later trainings of that profession SHALL NOT ask again.

#### Scenario: First time learning a crafting profession
- **WHEN** a player who has not been asked about Leatherworking trains it
- **THEN** the warning sound plays and a question names Leatherworking and why it is not advised yet, with no price or earn-back line
- **THEN** accepting trains the profession and cancelling leaves it untrained

#### Scenario: Asked once only
- **WHEN** the player cancelled the question for Engineering earlier and later tries to train it again
- **THEN** no question is shown and the training proceeds

#### Scenario: Gathering professions
- **WHEN** the player trains Fishing, Skinning, Herbalism, or Mining
- **THEN** no question is shown

#### Scenario: Question not safe
- **WHEN** a question cannot be shown safely on the profession trainer
- **THEN** the system falls back to a badge and tooltip and does not block the training

#### Scenario: Respects existing switches
- **WHEN** the player has turned off blocking confirmations or the addon is off
- **THEN** no question is shown, and the profession is not recorded as asked about

### Requirement: Skip reasons are accurate in the training window
The system SHALL show for a skipped rank, in the trainer window's tooltip and in the confirmation prompt, the reason that is true for it: what the guide says, a small step up for a spell used only now and then or one that does not repay its price, nothing gained over the rank before it, or a level 60 rank that can wait for the mount. It SHALL NOT name the data source there.

#### Scenario: Guide says first rank only
- **WHEN** the trainer lists Thunder Clap rank 3 and the guide advises only the first rank
- **THEN** the tooltip says the guide advises buying only the first rank of Thunder Clap

#### Scenario: Small step for an occasionally used spell
- **WHEN** a rank is skipped because it is 12% stronger than the previous rank for a spell the player only uses now and then
- **THEN** the tooltip says how much stronger it is and that the spell is only used now and then

#### Scenario: Small step for a core spell
- **WHEN** a rank is skipped because it is 8% stronger than the previous rank for a spell in the player's core rotation
- **THEN** the tooltip says how much stronger it is and that the gain does not repay its price, and does not say the spell is rarely used

#### Scenario: Nothing measurable
- **WHEN** a rank adds nothing measurable over the rank before it
- **THEN** the tooltip says it adds nothing over the rank before it

#### Scenario: Level 60 wait
- **WHEN** a later rank of a utility spell unlocks at level 60 and is skipped
- **THEN** the tooltip says it can wait until the level 60 mount

#### Scenario: Same words in the prompt
- **WHEN** the player is asked to confirm buying that rank
- **THEN** the question gives the same reason as the tooltip

#### Scenario: Earlier revision
- **WHEN** the player is on revision 1
- **THEN** each skipped rank's reason states the cause revision 1 records for it, not a reason it does not have

### Requirement: Profession question is once per character
The system SHALL remember which professions it has asked about separately for each character. Answers saved before the update SHALL NOT be copied to characters, so each character may be asked once about a profession.

#### Scenario: Alt learns a profession the main was asked about
- **WHEN** the player was asked about Tailoring on one character and later trains Tailoring on another character
- **THEN** the other character is asked once

#### Scenario: Same character
- **WHEN** a character was asked about Tailoring and trains it again later
- **THEN** no question is shown

### Requirement: Mount fund line in the purchase question
The system SHALL add one line to the "Buy anyway?" question, after the earn-back line, when the player's gold minus the price is below the current mount milestone's target. The line SHALL give the gold left, the target and the milestone level. It SHALL be left out when the player would still meet the target or when the price, gold, target or active milestone is unknown.

#### Scenario: Still short after buying
- **WHEN** a player saving for the level 40 mount (target 100g) with 73g is asked about a 12g purchase
- **THEN** the question includes "After this you'll have 61g of the 100g for your level 40 mount."

#### Scenario: Purchase takes the player below the target
- **WHEN** the player has 105g, the target is 100g, and the purchase costs 12g
- **THEN** the question includes "After this you'll have 93g of the 100g for your level 40 mount."

#### Scenario: Still enough after buying
- **WHEN** the player has 150g, the target is 100g, and the purchase costs 12g
- **THEN** the question has no mount fund line

#### Scenario: Price unknown
- **WHEN** the question is shown for a purchase with no known price
- **THEN** the question has no mount fund line

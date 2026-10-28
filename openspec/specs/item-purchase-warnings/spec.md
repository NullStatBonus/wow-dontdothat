# item-purchase-warnings Specification

## Purpose
Warns the player before they spend gold on non-essential items at vendors and the auction house, with a per-category choice of where each warning applies and a minimum price below which nothing is flagged.

## Requirements

### Requirement: Item categories
The system SHALL group items into these categories: Armor, Weapons, Bags, Vanity, Recipes, Potions/elixirs/flasks, Gems/enchants, Food and drink, Trade goods, Ammo/quivers/pouches, Class reagents, Mounts, and Keys/quest/misc, and SHALL place every item in exactly one.

#### Scenario: Armor piece
- **WHEN** the player considers buying a chest piece
- **THEN** it belongs to Armor

#### Scenario: Unrecognized item
- **WHEN** an item matches no listed category
- **THEN** it belongs to Keys/quest/misc and is treated with that category's mode

### Requirement: Per-category surface mode
The system SHALL give each category one mode: Off, Vendor, AH, or Both. A category warns only on the surfaces its mode names.

#### Scenario: AH-only category at a vendor
- **WHEN** a category set to AH is offered by a vendor
- **THEN** buying it produces no warning

#### Scenario: Both
- **WHEN** a category set to Both is bought at a vendor or bid on at the auction house
- **THEN** each produces a warning

#### Scenario: Off
- **WHEN** a category is set to Off
- **THEN** it never produces a warning, badge, or tooltip line

### Requirement: Default modes
The system SHALL start with Armor, Weapons, and Vanity set to Both; Bags, Recipes, Potions/elixirs/flasks, Gems/enchants, Food and drink, Trade goods, Ammo/quivers/pouches, and Class reagents set to AH; and Mounts and Keys/quest/misc set to Off.

#### Scenario: First install
- **WHEN** the addon runs for the first time
- **THEN** every category has the mode listed above

### Requirement: Minimum price
The system SHALL NOT warn about a purchase whose total price is below the player's minimum price, which defaults to 10 silver. A vendor stack's total is the unit price times the quantity, and an auction's is the bid or buyout amount.

#### Scenario: Cheap item
- **WHEN** the player buys one item costing 4 copper with the default minimum
- **THEN** no warning is shown

#### Scenario: Cheap items in bulk
- **WHEN** the player buys 20 items at 8 copper each, a total of 1 silver 60 copper
- **THEN** the purchase is compared against the minimum as 1 silver 60 copper

#### Scenario: At the minimum
- **WHEN** the total equals the minimum price
- **THEN** the warning is shown

#### Scenario: Minimum of zero
- **WHEN** the minimum price is zero
- **THEN** every purchase in an active category is warned about

### Requirement: Vendor purchase prompt
The system SHALL, when the player buys a flagged item from a vendor, play the warning sound and show an Accept / Cancel question naming the item, its total price, the reason, and the earn-back estimate, and SHALL complete the purchase only if the player accepts.

#### Scenario: Player declines
- **WHEN** the player cancels the question
- **THEN** the item is not bought and the declined price is recorded as avoided

#### Scenario: Player accepts
- **WHEN** the player accepts the question
- **THEN** the purchase goes through exactly as without the addon and is recorded as spent against the rules

#### Scenario: Quantity purchases
- **WHEN** the player buys a stack or several units at once
- **THEN** one question covers the whole quantity and its total price

### Requirement: Auction house purchase prompt
The system SHALL, when the player places a bid or buyout on a flagged auction, show the same kind of question with the bid or buyout amount, and SHALL place it only if the player accepts.

#### Scenario: Buyout declined
- **WHEN** the player cancels the question for a buyout
- **THEN** no buyout is placed and the amount is recorded as avoided

#### Scenario: Bid accepted
- **WHEN** the player accepts the question for a bid
- **THEN** the bid is placed as without the addon

### Requirement: Fallback when a prompt is unsafe
The system SHALL show a badge and tooltip line for a flagged item instead of a question on any surface where a question would risk breaking the default interface, and SHALL NOT block the purchase there.

#### Scenario: Client refuses interception
- **WHEN** the client refuses the addon's confirmation for a surface
- **THEN** the question switches off for the session on that surface, flagged items still show badge and tooltip, and the purchase can still be made

### Requirement: Respects existing switches
The system SHALL apply the overall enable, "Ask before buying", badges and tooltips, and alerts settings to item warnings in the same way it applies them to trainer warnings.

#### Scenario: Master off
- **WHEN** the overall enable is off
- **THEN** no item warnings, prompts, or alerts occur

#### Scenario: Ask before buying off
- **WHEN** "Ask before buying" is off and the player buys a flagged item
- **THEN** the warning sound and banner play and the purchase goes ahead

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

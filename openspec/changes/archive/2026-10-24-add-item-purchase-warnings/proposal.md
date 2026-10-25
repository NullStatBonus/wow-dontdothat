## Why

The addon protects gold for the level 40 and 60 mounts, but it only watches trainers and resets. Armor, weapons, and other non-essentials bought from vendors and the auction house drain the same gold unchecked. Prompts also say what something costs without saying what that cost means in play time.

## What Changes

- Warn, with an Accept / Cancel prompt, when the player buys an item from a vendor or places a bid or buyout at the auction house, if the item's category is switched on for that surface.
- Add item categories, each with its own mode: Off, Vendor, AH, or Both. Defaults:
  - Both: Armor, Weapons, Vanity (pets, toys, tabards).
  - AH: Bags, Recipes, Potions/elixirs/flasks, Gems/enchants, Food and drink, Trade goods, Ammo/quivers/pouches, Class reagents.
  - Off: Mounts, Keys/quest/misc.
- Add a minimum price setting, default 10 silver, entered as gold / silver / copper boxes with coin icons. Purchases below it are not warned.
- Add an estimated time to earn the money back by grinding mobs, from a static gold-per-hour table by level, to **every** prompt: trainer, talent and pet resets, and the new item prompts.
- Count a declined item purchase as avoided cost in the tally, kept separate from verified and projected savings. Count a confirmed one as spent against the rules.
- Add an Items page to Settings holding the category dropdowns and the minimum price.
- Where the auction house cannot be intercepted safely, fall back to badge and tooltip only.

## Capabilities

### New Capabilities
- `item-purchase-warnings`: item categories, per-category surface modes, minimum price, and the vendor and AH warning flow.
- `earn-back-estimate`: gold-per-hour data by level and the "time to earn back" line shown on prompts.

### Modified Capabilities
- `purchase-warnings`: covered surfaces gain vendor and AH; every confirmation prompt shows the earn-back line.
- `addon-settings`: new Items page; subpage count changes.
- `savings-ledger`: new avoided-purchases total, kept separate from verified and projected.
- `warning-alerts`: alerts and banners fire for item purchases; the banner includes the earn-back line.

## Impact

- New: `Intercepts/Merchant.lua`, `Intercepts/Auction.lua`, `Model/ItemCategory.lua`, `Model/EarnBack.lua`, `Data/GoldRates.lua`.
- Changed: `Core/Addon.lua` defaults, `Options/Options.lua`, `Model/Ledger.lua`, `UI/ConfirmPopup.lua`, `Intercepts/Confirm.lua` and `Intercepts/Resets.lua` (earn-back line), both `.toc` files.
- Tests for the new models and the settings page. The AH hook needs an in-game check; this is the first task.
- No new libraries. The gold-per-hour table is an estimate, flagged `needsReview`.

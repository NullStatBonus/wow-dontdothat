# In-game test plans

The in-game checks live in CheckThat test plans. This file points there and keeps only the checks no plan covers yet, so it cannot drift from the plans.

| Plan | Kind | Covers |
| --- | --- | --- |
| [`plans/dontdothat-pr72.yaml`](../plans/dontdothat-pr72.yaml) | feature plan | Always Allow at a vendor (PR 72) |
| [`plans/dontdothat.yaml`](../plans/dontdothat.yaml) | foundation, release gate | load and version, test settings and saved data across `/reload`, purchase calls wired at login, the settings window, the trainer window, the vendor question (Cancel, no purchase), the warning draws and plays, no Lua error. WoW Forever is the gate client. Buys nothing |
| [`plans/dontdothat.purchases.yaml`](../plans/dontdothat.purchases.yaml) | feature plan | vendor, trainer and auction purchases (Accept and Cancel), a stack at the auction house, what is counted as spent. Needs about 3 gold, level 10 and a marked trainer spell |

`make test` covers the rules, prices, Tally, Savings, settings, migrations, commands, the debug report, test settings with the real bundled AceDB (real TOC order, saved variables from a WoW Forever and a Classic Era player) and every guard against a fake game. `make plan` (with the CheckThat tools installed) validates, compiles and replays each plan, and runs the foundation plan's offline block on the Classic Era and Forever TOCs with recorded trainer calls. The unit tests prove the logic. A plan keeps only what a fake game cannot prove: real game data and events, drawing, sound, other addons and saved variables across `/reload`.

The WoW Forever API facts the fixes rely on were checked against Blizzard's API documentation for build 1.60.1.70959 (wow-addon-api): no `GetNumTalentTabs`; the trait fields `currentRank`, `activeEntry`, `definitionID` and `spellID`; `C_MerchantFrame.GetItemInfo` with `hasExtendedCost`; `C_AuctionHouse.PlaceBid`. The Classic Era return positions (`GetMerchantItemInfo`, `GetAuctionItemInfo`, `GetInboxHeaderInfo`) and the Bids-tab list type were checked against Blizzard's Era UI source: the Bids tab sets `AuctionFrame.type = "bidder"` and its Buyout button calls `PlaceAuctionBid(AuctionFrame.type, ...)`.

Test settings: when a CheckThat run of the Don't Do That plan starts, the addon switches the character to a temporary profile with default settings, so the player's own settings do not matter. A banner on every settings page and a chat line name the profile in use. See the README, Test settings.

## Checks done by hand

Each check is one action, a `Check:` line with what you should see, and a `Log:` line for the reviewer. Setup: install the build and `/reload`, then type `/ddt debug on`. (Loading the addon turns debug recording off, so turn it on after the reload.) Afterwards, `/reload` once more and send the saved variables (`WTF/Account/<account>/SavedVariables/DontDoThat.lua`).

## 1. Spend is counted when the gold leaves

- [ ] On either client, at a vendor, buy armor or a weapon that costs more than 1 silver and choose Buy anyway.
  Check: Progress > "Spent on things the addon marked" goes up by the item's price.
  Log: `items: spend of <price> pending`, then `items: spent <price> counted`.

## 2. Trainer and beast training (Classic Era, Hunter)

- [ ] At your class trainer, buy a marked spell with Buy anyway, then open Beast Training and train a pet ability.
  Check: both are learned, and no "blocked from an action" message shows.
  Log: `confirm: bought <spell> anyway` and no `confirm: prompts disabled` line.

## 3. Always Allow (either client)

- [ ] At a vendor, buy armor or a weapon that costs more than 1 silver and choose Always Allow.
  Check: the question has three buttons, and the item is bought.
  Log: `items: always allowed <item ID> <name>`.
- [ ] Buy the same item again.
  Check: the item is bought without a question.
  Log: `items: vendor <name> ... -> passed through: allowed`.

## 4. Test settings (either client)

- [ ] Type `/ddt testsettings on`, open `/ddt`, then type `/ddt testsettings off`.
  Check: chat names the temporary profile "DDT test" and your own profile when it turns on, an amber banner with Restore my settings shows on every page, and chat names your own profile when it turns off.
  Log: `test settings: on (own settings put aside)`, then `test settings: off (own settings restored)`.
- [ ] Type `/ddt testsettings on`, then `/reload` with no CheckThat run open.
  Check: chat says test settings were left on and names your own profile, and your settings are as before.
  Log: saved variable `profileKeys` names your own profile, and `char` has no `testSettings` entry.

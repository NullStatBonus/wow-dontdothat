# In-game test plan

`make test` covers the rules, prices, Tally, Savings, settings, migrations, commands, the debug report and every guard against a fake game. The WoW Forever API facts the fixes rely on were checked against Blizzard's API documentation for build 1.60.1.70959 (wow-addon-api): no `GetNumTalentTabs`; the trait fields `currentRank`, `activeEntry`, `definitionID` and `spellID`; `C_MerchantFrame.GetItemInfo` with `hasExtendedCost`; `C_AuctionHouse.PlaceBid`. The Classic Era return positions (`GetMerchantItemInfo`, `GetAuctionItemInfo`, `GetInboxHeaderInfo`) were checked against Blizzard's Era UI source.

This plan keeps only what needs a live client: server timing, taint and one Era list type. Each check is one action, a `Check:` line with what you should see, and a `Log:` line for the reviewer.

Setup: install the build, type `/ddt debug on`, then `/reload`. Afterwards, `/reload` once more and send the saved variables (`WTF/Account/<account>/SavedVariables/DontDoThat.lua`).

## 1. Spend is counted when the gold leaves

- [ ] On either client, at a vendor, buy armor or a weapon that costs more than 1 silver and choose Buy anyway.
  Check: Progress > "Spent on things the addon marked" goes up by the item's price.
  Log: `items: spend of <price> pending`, then `items: spent <price> counted`.

## 2. Bids-tab buyout (Classic Era)

- [ ] On the auction house Bids tab, buy out a marked auction you already bid on.
  Check: the "Buy anyway?" question shows.
  Log: `items: auction bidder <index> checked (<buyout>)`.

## 3. Trainer and beast training (Classic Era, Hunter)

- [ ] At your class trainer, buy a marked spell with Buy anyway, then open Beast Training and train a pet ability.
  Check: both are learned, and no "blocked from an action" message shows.
  Log: `confirm: bought <spell> anyway` and no `confirm: prompts disabled` line.

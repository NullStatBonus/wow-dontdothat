# In-game test plan

`make test` covers the rules, prices, Tally, Savings, settings, migrations, commands, the debug report and every guard against a fake game. This plan keeps only what needs the real client. Each check is one action, a `Check:` line with what you should see, and a `Log:` line for the reviewer.

Setup for every section: install the build, type `/ddt debug on`, then `/reload`. After a session, `/reload` once more and send the saved variables (`WTF/Account/<account>/SavedVariables/DontDoThat.lua`).

## 1. Everyday play

- [ ] Type `/ddt`.
  Check: the settings window opens at Home.
  Log: `/ddt log` shows no Lua error lines.
- [ ] Open your class trainer.
  Check: spells the addon marks have a colored (i) at the right edge of the row.
  Log: `overlay: ClassTrainerFrame_Update hooked`.
- [ ] Select a marked spell, click Train, then click Cancel.
  Check: the "Buy anyway?" question shows, and nothing is bought.
  Log: `confirm: declined <spell>`.
- [ ] Select the same spell, click Train, then click Buy anyway.
  Check: you learn the spell.
  Log: `confirm: bought <spell> anyway`.
- [ ] Hunter only: open Beast Training and train a pet ability that costs training points.
  Check: no question shows, and the pet learns the ability.
  Log: no `BuyTrainerService wrapped` line while the window is open.

## 2. Purchases

- [ ] At a vendor, right-click an item sold in a stack of more than one (arrows, bullets, reagents) whose stack costs at least 1 silver.
  Check: the "Buy anyway?" question shows the price of the whole stack.
  Log: `items: vendor <item> total=<stack price>`.
- [ ] Accept a "Buy anyway?" question for a vendor item, then open Progress.
  Check: "Spent on things the addon marked" goes up by the item's price.
  Log: `items: spent <price> counted (money dropped <price>, price <price>)`.
- [ ] With full bags, accept a "Buy anyway?" question for a vendor item.
  Check: the game says your bags are full, and Progress does not change.
  Log: `items: pending spend of <price> expired, not counted` (it shows at your next change of money).
- [ ] At the auction house, bid (do not buy out) on a marked item and accept the question.
  Check: your bid is placed, and Progress does not change.
  Log: `items: bid of <amount> is not counted as spent`.
- [ ] Classic Era: on the Bids tab, buy out a marked auction you already bid on.
  Check: the "Buy anyway?" question shows.
  Log: `items: auction bidder <index> checked (<buyout>)`.
- [ ] Classic Era: on the Browse tab, open the question for a marked auction, click another column header to sort the list, then accept.
  Check: nothing is bought.
  Log: `items: auction list <index> changed while the question was open, purchase dropped`.

## 3. Trainers

- [ ] Classic Era: select a marked spell and click Train. While the question shows, click a different spell in the list, then click Buy anyway.
  Check: you learn the first spell, not the one you clicked after.
  Log: `confirm: buying the service chosen when asked (<index>)`.
- [ ] At a profession trainer, learn the first rank of a crafting profession you do not have (Tailoring, Alchemy …).
  Check: the question has an "earn back" line and, while you are saving for a mount, a mount fund line.
  Log: `popup: shown`.

## 4. Dialogs and resets

- [ ] Ask your class trainer to reset your talents and click Cancel. Then open a COD mail, take the item and click Cancel.
  Check: both times the game's dialog has the addon's red note.
  Log: `reset: the game's Talent reset dialog opened`, then `reset: the game's COD mail dialog opened`.
- [ ] WoW Forever, Hunter: at the pet trainer, choose to untrain your pet and click Cancel.
  Check: the dialog has the addon's red note about pet skills.
  Log: `reset: the game's Pet skill reset dialog opened`.

## 5. WoW Forever

- [ ] Spend a talent point, then open your class trainer.
  Check: the trainer opens as usual, with its (i) marks.
  Log: `spec: talent points per tree` with your points in the right tree.
- [ ] At the auction house, buy a stack of a marked commodity (ore, herbs) and wait 30 seconds before you accept the question.
  Check: the purchase goes through, or the game says the price changed. The auction house still responds after.
  Log: the `items:` lines for the purchase.

## 6. Open questions

- [ ] Classic Era, Hunter: visit your class trainer and buy a spell with Buy anyway. Then open Beast Training and train a pet ability.
  Check: no "blocked from an action" message shows.
  Log: no `confirm: prompts disabled` line.
- [ ] Hover a trainer row's (i), then hover an item in your bags.
  Check: the item tooltip has its normal width.
  Log: none (the fix is covered by `tests/bubble_test.lua`).

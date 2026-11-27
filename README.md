# Don't Do That

Don't Do That is a World of Warcraft addon for WoW Forever and Classic Era.
It helps you save gold for your mount, for all nine classes.
It warns you before you spend gold that you do not need to spend yet.
This helps you to buy your **level 40** and **level 60** mounts on time.

## Quick start

1. Copy the `DontDoThat` folder into your AddOns folder (see [Install](#install)).
2. Start the game, or type `/reload`.
3. Open a trainer. Look for the colored **(i)** marks next to the spells.
4. Type `/ddt` to open the settings.

## What it does

The addon is on from level 1 until you buy the mount that you chose to stop at. Then every warning stops: trainers, shopping, slots, COD mail and resets.
You can stop at your level **40** mount or your level **60** mount (default: level **60**).
It only asks. It never stops a purchase.
You can turn off each part.

### At the trainer

- **Marks spells you can skip.** A colored **(i)** shows next to each one. Hover over it to see the reason and the cost.
  - Red, "Save your gold": you do not need this spell until a later level.
  - Gold, "Not worth buying yet": this spell gives little for its price.
  - Blue, "Optional": you use this spell only sometimes. You can play without it.
- **Asks "Buy anyway?"** before you buy a spell with a red mark. You can always choose Yes.
  The question tells you about how long it takes to farm that gold again.
  You can also choose to be asked about gold and blue spells, or to get marks only.
- **Knows your class and spec.** The advice depends on your spec. The addon reads your talents, or you can choose a spec.
- **Has a Recommended filter.** Use the trainer's Filters menu to hide the spells that the addon marks as skippable.
  On Forever, the filter fades the rows. It does not remove them.

### At vendors and the auction house

The addon asks before you buy items that you do not need while you level.
These are the item kinds: armor, weapons, vanity items, bags, recipes, potions, gems and enchants, food, trade goods, ammo, class reagents, mounts, and other items.
For each kind, you choose where the addon asks: at vendors, at the auction house, at both, or nowhere.
By default, armor, weapons and vanity items are watched at both. The other kinds are watched at the auction house only. Mounts are not watched.
The addon does not ask about purchases that cost less than **1 silver**. You can change this price.
If you always buy an item, choose **Always Allow** when the addon asks about it. The addon buys the item and stops asking about that item on this character, at vendors and at the auction house. Other items of the same kind are still watched.
A purchase of an allowed item does not count as spent or as turned down in your savings.
To be asked again, remove the item on the What to watch page, under Shopping.

### Other ways to lose gold

The addon also asks before you pay for:

- a bank slot
- a stable slot
- COD mail
- a talent reset
- a pet skill reset (Hunters)
- your first lesson in a new profession (not gathering professions)

For COD mail and talent and pet resets, the game's own question stays on screen with a note from the addon added to it, and you hear the warning sound; no toast or banner covers it. You can turn off each of these, except the profession lesson, on the What to watch page under Other. The stable slot and pet skill switches show only for Hunters.

### Warnings you can see and hear

- A loud sound and an on-screen message tell you when a purchase is not advised. You choose the sound and the volume.
- You choose how the message looks. **Toast** (the default for new installs) is a small box near the top of the screen that you can move, resize and make see-through. **Warning** is the large message in the middle of the screen. Players who already used the addon keep Warning until they choose Toast.
- Every warning also adds one line to chat, so you can read it again. You can turn this off.
- When the addon asks "Buy anyway?", the question is the warning. No second message shows.
- If the purchase leaves you short of your next mount, the question says how much you will have left. For example: "After this you'll have 61g of the 100g for your level 40 mount." The line does not show when you will still have enough, or after the mount stop point.
- You can click an **(i)** to keep its explanation open. It is a black box that wraps its text, closes with its button or Escape, and has its own opacity and scale. A sample explanation (from a preview or `/ddt demo`) closes by itself or with its button, not Escape.
- You choose how strongly the addon warns you: marks only, ask about spells to wait for, or ask about everything.
- The addon warns you at most once every **3** seconds for the same item. You can change this time. The chat line follows the same wait.

### Your savings

The Progress page adds up the gold you kept.
It also shows how close you are to your mount.
On Classic Era the level 40 goal is 100g (20g riding, 80g mount) and the level 60 goal is 1,000g.
The goal is 10% lower at Honored with your home city. On Classic Era, PvP rank 3 takes off another 10%. Progress shows the discount.

What the Tally counts:

- **Kept so far** counts only spells your character can buy from a trainer. Other races' spells, spell effects and the first rank of a talent you have do not count. Optional (blue) spells do not count, so the Tally agrees with Projected savings.
- **Spent on things the addon marked** goes up only when your gold really goes down after the purchase, within 5 seconds, and by no more than the price. A purchase that fails (full bags, not enough gold) does not count. An auction bid does not count, because you get the gold back if someone outbids you. A buyout counts. Purchases you make after only a warning (no question) count too.
- When you buy (or mark) your last mount, the Tally keeps the amounts it showed before.

## How the advice is made

The advice comes from three sources:

- **Expert guides.** The addon follows the Wowhead leveling guides where they say which ranks to buy or skip.
- **The game's spell data.** Where a guide says nothing, the addon compares the price of a rank with how much stronger the rank is.
  It also uses how long you stay at each level. A rank that gives little for its price is skipped.
- **Common leveling builds.** These decide which spells are useful for your spec.

The list of ranks to skip has numbered revisions.
Revision 1 is the original list. Revision 2 is the newer list, and it is the default.
To see or change the revision, type `/ddt revision` or `/ddt revision 1`.
The addon never changes a spell that you turned on or off yourself.

## Install

Install the addon from CurseForge or Wago with your addon manager.
To install it by hand:

1. Copy the `DontDoThat` folder into your AddOns folder:
   - Classic Era: `World of Warcraft/_classic_era_/Interface/AddOns/`
   - WoW Forever: `World of Warcraft/_classic_beta_/Interface/AddOns/`
2. Start the game, or type `/reload`.

## Settings

Type `/ddt` to open the settings at Home. You can also find them under Options > AddOns.
The "Don't Do That" entry there shows the Home controls at once, with the other pages under it.
The settings have these pages:

- **Home:** turn the addon on or off, choose how strongly it warns you, choose when to stop warning you, turn the on-screen message on or off, and reset all settings. A reset also removes the items that this character always allows (not while test settings are on).
- **What to watch:** choose Spells, Professions and Shopping, and which purchases the addon watches. Under Shopping, **Always allowed on this character** lists the items you chose Always Allow for, each with a **Remove** button.
- **Progress:** the gold you saved, and how close you are to your mounts. **Start the count over** forgets what the addon recorded (trainer prices, purchases you turned down or made, and reset counts). Spell totals come from your spellbook, so they come back. The "I've already bought my mount" checkboxes are kept for each character, so marking a mount on one character does not change your other characters.
- **Appearance:** three tabs.
  - **Warnings:** choose Toast or Warning, preview it, set the toast's background opacity, text and icon opacity and scale, move it (Done saves, Cancel or Escape puts it back, and Escape does not close the settings window; it keeps its place when you change its scale), reset its position, and turn the chat line on or off.
  - **Explanations:** opacity and scale for the explanations you keep open, and a preview.
  - **Sound:** the warning sound, the volume channel, a Play sound button, and the seconds between warnings for the same thing. Turning the sound off also turns off the on-screen message. The chat line and the questions stay.
- **Advanced:** fine controls (Tuning), the skip list revision, the spells and rules for each class (Classes), and Debug. In the game's Options window, Classes is an **Open classes** button that opens the list in the Don't Do That window. On a class page, the switch beside a spell covers every rank of that spell, even when the row names only some ranks.
- **About:** what the marks mean, how to use the addon, and the main commands.
- **Profiles:** shows which profile this character uses. Choose another, create one, copy one, reset the current one or delete one. Characters can share a profile or use their own. Your tally, progress and Always Allow items stay with each character. The page is locked while test settings are on.

The addon has its own icon in the AddOns list at the character screen.

## Commands

| Command | What it does |
|---|---|
| `/ddt` | Opens the settings at Home. |
| `/ddt settings [page]` | Opens a page: `watch`, `progress`, `appearance`, `warnings`, `explanations`, `sound`, `advanced`, `classes`, `debug`, `about` or `profiles`. |
| `/ddt status [topic]` | Prints current settings. Topics: `nudge`, `warnings`, `explanations`, `sound`. |
| `/ddt help [topic]` | Lists the commands. Topics: `appearance`, `rules`, `diagnostics`. |
| `/ddt get` | Lists the setting keys. |
| `/ddt get <key>` | Shows one setting. |
| `/ddt set <key> <value>` | Changes one setting. A value that does not fit is refused and nothing changes. Open settings pages, trainer marks, the toast and an open explanation update at once, as with the settings controls. |
| `/ddt demo` | Shows the samples one at a time, five seconds apart: four toasts or warnings, a kept-open explanation, marks (captioned "Sample") with a tooltip, and a question. A chat line names each sample. The tour takes about 40 seconds. It does not buy anything. |
| `/ddt preview [name]` | Shows one sample: `toast`, `warning`, `mark`, `tooltip`, `explanation` or `prompt`. Without a name it lists them. |
| `/ddt test` | Shows a sample warning and question. It does not buy anything. If "Ask before buying" and the sound are both off, it says only the chat line would show (when the chat line is on). |
| `/ddt revision` | Shows the revision of the skip list in use. |
| `/ddt revision <number>` | Changes the revision (1 or 2). |
| `/ddt version` | Shows the addon version and the game build. |
| `/ddt debug on` and `/ddt debug off` | Starts or stops the debug recording. |
| `/ddt testsettings on` and `/ddt testsettings off` | For testers. Switches this character to a temporary profile with default settings, or back to its own profile. See Test settings below. |
| `/ddt log` | Opens the debug report. Escape closes it. If the window cannot open, the report prints in chat. |
| `/ddt log clear` | Asks in its own dialog, then clears the recording. It never touches an open "Buy anyway?" question. |

`/ddt export` still works and does the same as `/ddt log`. `/ddt clear` still works and clears the recording at once, without asking.
Two more commands are for developers: `/ddt probe` and `/ddt trainerids [hover]`.

The keys for `/ddt get` and `/ddt set` are `enabled`, `nudge` (`mark`, `ask` or `everything`), `watch.spells`, `watch.professions`, `watch.shopping`, `alerts`, `appearance.message`, `appearance.warning-style` (`toast` or `warning`), `appearance.chat`, `appearance.toast.background-opacity`, `appearance.toast.text-opacity`, `appearance.toast.scale`, `appearance.explanation.background-opacity`, `appearance.explanation.text-opacity`, `appearance.explanation.scale`, `alert.cooldown` and `alert.channel`.
Switches take `on` or `off`. Opacity is 0 to 100, scale is 50 to 200 and `alert.cooldown` is 1 to 30.

## Test settings

Test settings are for people who run the CheckThat test plans. They are not needed to use the addon.

- `/ddt testsettings on` puts your own profile aside and uses a temporary profile named `DDT test` with default settings. `/ddt testsettings off` brings your own profile back and deletes the temporary one. Your own profile is never changed.
- The mode ends by itself. The saved file never names the temporary profile, so a crash, an older version or a missing CheckThat leaves you on your own profile. At the next login with no open CheckThat run, chat says test settings were left on and your own profile is back. `/reload` during a run keeps them on.
- Every page of the settings shows an amber banner while they are on, with a **Restore my settings** button. The **Profiles** page is locked until then.
- Chat always names the profile in use: at every login (`Profile in use: Default (your own).`), at every profile switch (`Profile changed. Profile in use: Raid (your own).`) and in every test-settings message.
- While they are on, **Reset all settings** keeps this character's Always Allow items.
- CheckThat starts and ends the mode on its own when it runs the Don't Do That plan. Its entries are `version` (0.15.0 is 1500), `testsettings` (`on` or `off`), `setting` (a key of `/ddt get`, or `marks` or `allowed`) and `trainer` (`rows=<n>` for the open trainer window). An entry only reads state and writes no log line.
- With **Record debug information** on, the log has these lines: `debug log turned on`, `debug log turned off`, `test settings: on (own settings put aside)`, `test settings: reset to defaults`, `test settings: off (own settings restored)`, `test settings: on at login`, `test settings: restored at login`, `test settings: another run started`, `test settings: run already seen`, `test settings: run start without an id`, `test settings: run ended: <reason>`, `checkthat: entries registered: <n>`, `checkthat: run hook registered` and `checkthat: FAILED: <why>`. Each purchase call also writes a line: `items: purchase call made` (or `dropped`) at a vendor or the auction house, and `confirm: training call made for row <n>` at a trainer. A declined question writes none.
- The debug report lists the profile in use, whether test settings are on, and the CheckThat status (`working`, `not detected`, `too old` or `failed: <why>`).

## Known limits

### Spells

- The spell advice comes from expert guides and spell data. You can turn off the advice for each spell, or for each kind of advice.
- Wowhead has leveling guides for Priest, Mage, Druid, Shaman and Warrior. The other classes have no guide check.
- The addon does not mark or question beast training. Beast training is the pet abilities that cost training points. The addon does check the Pet Trainer NPC.
- The addon does not judge talent choices. It only warns you about the cost of a talent reset.
- On WoW Forever, the addon reads your talent points from the game's talent trees to choose your spec.
- Version 0.14.0 gives Holy Shock (Paladin) and Shadow Word: Death (Priest) new spell IDs. A switch you set for them moves to the new ID when you log in.

### Your characters

- Settings are shared by all your characters. Your savings, the mounts you marked as bought, the professions the addon already asked about, and the items you always allow are kept for each character.
- After updating from an older version, a mount you marked as bought is kept only on characters that are at least that level. Each character may be asked once about a profession that another character was asked about.

### Warnings

- A toast has no buttons and you cannot click it. Questions ("Buy anyway?") are never replaced by a toast.
- The **Reset all settings** button puts the style back to Toast, even for players who had Warning.
- The Warning style has no look or position settings. Your toast settings are kept for when you switch back.
- You can't move the toast in combat. Entering combat while moving it puts it back where it was.
- A plain right-click on a vendor stack is checked at the price of the whole stack. A split stack is checked at the price of the amount you buy.
- If the auction list changes while a question is open (you sort, search or turn the page), Buy anyway buys nothing. Open the question again for the auction you want.
- On Classic Era, Buy anyway at a trainer buys the spell the question named, even if you click another row while it is open.
- If the game has no free dialog for a question, the purchase goes ahead and does not count as turned down.
- The addon never asks about an allowed item again, at any price. An item you allowed at a vendor is also allowed at the auction house.
- The addon knows an item by its item ID. Gear with a random suffix, such as "of the Bear", shares one ID, so if you allow one suffix you allow all of them.
- You can allow an item only from the question. If "Ask before buying" is off, there is no question, so you cannot add items. You can still remove them.

### WoW Forever

- The addon asks "Buy anyway?" from its own button on top of the Train button.
- If you use the keyboard instead of the mouse, you get a sound and a message, but no question. The purchase goes ahead.
- The Recommended filter fades the rows. It cannot remove them.

### Language

- The text of the addon is in English.
- Spell names use the language of your game. The addon finds spells, talents and trainers by ID.
- You can add other languages. See [docs/localization.md](docs/localization.md).

## Problems?

1. Type `/ddt debug on`.
2. Do the action that went wrong.
3. Type `/ddt log`. A window opens with a report. If it cannot open, the report prints in chat.
4. Select all (Ctrl+A) and copy (Ctrl+C).
5. Send the report with a description and your client (Classic Era or Forever).
6. Type `/ddt debug off` to stop the recording.

You can also use **Advanced > Debug**: turn on **Record debug information**, then select **Show debug report**.

The report holds:

- The addon version.
- Your settings, including how warnings look, and your gold tally. The **Rules** part lists every setting with its value, also the ones you never changed: nudge level, prompt tiers, What to watch, stop point, skip revision, item kinds and the minimum price.
- The items and the vendor and auction decisions that the addon saw.
- A log of what the addon saw and decided.
- The profile in use, whether test settings are on, and the CheckThat status.
- The addon version that wrote your saved data, and the one before it.
- The libraries that the game loaded, and the game functions that the addon uses.

Read the report before you send it.

## For developers

See [CONTRIBUTING.md](CONTRIBUTING.md). In short:

```
make test     # the Lua tests (luajit tests/run.lua [pattern])
make check    # TOC, embed and version checks, the same ones the release workflow runs
```

The skip lists are generated. Do not edit `DontDoThat/Data/SkipRevisions.lua` by hand.
See [tools/skip-revision/README.md](tools/skip-revision/README.md).

## License and data

MIT, see [LICENSE](LICENSE).
The Ace3 libraries in the addon keep their own license (`DontDoThat/Libs/LICENSE-Ace3.txt`).
The spell and price data comes from the Wowhead leveling guides and trainer lists, and from wago.tools game data tables.

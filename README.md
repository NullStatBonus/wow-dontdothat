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

The addon is on from level 1 until you buy the mount that you chose to stop at.
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
- **Marks profession ranks that you cannot use yet.**

### At vendors and the auction house

The addon asks before you buy items that you do not need while you level.
These are the item kinds: armor, weapons, vanity items, bags, recipes, potions, gems and enchants, food, trade goods, ammo, class reagents, mounts, and other items.
For each kind, you choose where the addon asks: at vendors, at the auction house, at both, or nowhere.
By default, armor, weapons and vanity items are watched at both. The other kinds are watched at the auction house only. Mounts are not watched.
The addon does not ask about purchases that cost less than **10 silver**. You can change this price.

### Other ways to lose gold

The addon also asks before you pay for:

- a bank slot
- a stable slot
- COD mail
- a talent reset
- your first lesson in a new profession (not gathering professions)

### Warnings you can see and hear

- A loud sound and an on-screen message tell you when a purchase is not advised. You choose the sound and the volume.
- You choose how the message looks. **Toast** (the default for new installs) is a small box near the top of the screen that you can move, resize and make see-through. **Warning** is the large message in the middle of the screen. Players who already used the addon keep Warning until they choose Toast.
- Every warning also adds one line to chat, so you can read it again. You can turn this off.
- When the addon asks "Buy anyway?", the question is the warning. No second message shows.
- You can click an **(i)** to keep its explanation open. It is a black box that wraps its text, closes with its button or Escape, and has its own opacity and scale. A sample explanation (from a preview or `/ddt demo`) closes by itself or with its button, not Escape.
- You choose how strongly the addon warns you: marks only, ask about spells to wait for, or ask about everything.
- The addon warns you at most once every **3** seconds for the same item. You can change this time. The chat line follows the same wait.

### Your savings

The Progress page adds up the gold you kept.
It also shows how close you are to your mount.

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

- **Home:** turn the addon on or off, choose how strongly it warns you, choose when to stop warning you, turn the on-screen message on or off, and reset all settings.
- **What to watch:** choose Spells, Professions and Shopping, and which purchases the addon watches.
- **Progress:** the gold you saved, and how close you are to your mounts.
- **Appearance:** three tabs.
  - **Warnings:** choose Toast or Warning, preview it, set the toast's background opacity, text and icon opacity and scale, move it (Done saves, Cancel or Escape puts it back, and Escape does not close the settings window; it keeps its place when you change its scale), reset its position, and turn the chat line on or off.
  - **Explanations:** opacity and scale for the explanations you keep open, and a preview.
  - **Sound:** the warning sound, the volume channel, a Play sound button, and the seconds between warnings for the same thing. Turning the sound off also turns off the on-screen message. The chat line and the questions stay.
- **Advanced:** fine controls (Tuning), the skip list revision, the spells and rules for each class (Classes), and Debug. In the game's Options window, Classes is an **Open classes** button that opens the list in the Don't Do That window.
- **About:** what the marks mean, how to use the addon, and the main commands.

The addon has its own icon in the AddOns list at the character screen.

## Commands

| Command | What it does |
|---|---|
| `/ddt` | Opens the settings at Home. |
| `/ddt settings [page]` | Opens a page: `watch`, `progress`, `appearance`, `warnings`, `explanations`, `sound`, `advanced`, `classes`, `debug` or `about`. |
| `/ddt status [topic]` | Prints current settings. Topics: `nudge`, `warnings`, `explanations`, `sound`. |
| `/ddt help [topic]` | Lists the commands. Topics: `appearance`, `rules`, `diagnostics`. |
| `/ddt get` | Lists the setting keys. |
| `/ddt get <key>` | Shows one setting. |
| `/ddt set <key> <value>` | Changes one setting. A value that does not fit is refused and nothing changes. Open settings pages, trainer marks, the toast and an open explanation update at once, as with the settings controls. |
| `/ddt demo` | Shows sample toasts and warnings, marks (captioned "Sample"), a tooltip, a question and a kept-open explanation. It does not buy anything. |
| `/ddt preview [name]` | Shows one sample: `toast`, `warning`, `mark`, `tooltip`, `explanation` or `prompt`. Without a name it lists them. |
| `/ddt test` | Shows a sample warning and question. It does not buy anything. If "Ask before buying" and the sound are both off, it says only the chat line would show (when the chat line is on). |
| `/ddt revision` | Shows the revision of the skip list in use. |
| `/ddt revision <number>` | Changes the revision (1 or 2). |
| `/ddt version` | Shows the addon version and the game build. |
| `/ddt debug on` and `/ddt debug off` | Starts or stops the debug recording. |
| `/ddt log` | Opens the debug report. Escape closes it. If the window cannot open, the report prints in chat. |
| `/ddt log clear` | Asks in its own dialog, then clears the recording. It never touches an open "Buy anyway?" question. |

`/ddt export` still works and does the same as `/ddt log`. `/ddt clear` still works and clears the recording at once, without asking.
Two more commands are for developers: `/ddt probe` and `/ddt trainerids [hover]`.

The keys for `/ddt get` and `/ddt set` are `enabled`, `nudge` (`mark`, `ask` or `everything`), `watch.spells`, `watch.professions`, `watch.shopping`, `alerts`, `appearance.message`, `appearance.warning-style` (`toast` or `warning`), `appearance.chat`, `appearance.toast.background-opacity`, `appearance.toast.text-opacity`, `appearance.toast.scale`, `appearance.explanation.background-opacity`, `appearance.explanation.text-opacity`, `appearance.explanation.scale`, `alert.cooldown` and `alert.channel`.
Switches take `on` or `off`. Opacity is 0 to 100, scale is 50 to 200 and `alert.cooldown` is 1 to 30.

## Known limits

### Spells

- The spell advice comes from expert guides and spell data. You can turn off the advice for each spell, or for each kind of advice.
- Wowhead has leveling guides for Priest, Mage, Druid, Shaman and Warrior. The other classes have no guide check.
- The addon does not mark or question beast training. Beast training is the pet abilities that cost training points. The addon does check the Pet Trainer NPC.
- The addon does not judge talent choices. It only warns you about the cost of a talent reset.

### Warnings

- A toast has no buttons and you cannot click it. Questions ("Buy anyway?") are never replaced by a toast.
- The **Reset all settings** button puts the style back to Toast, even for players who had Warning.
- The Warning style has no look or position settings. Your toast settings are kept for when you switch back.
- You can't move the toast in combat. Entering combat while moving it puts it back where it was.

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
- Your settings, including how warnings look, and your gold tally.
- The items and the vendor and auction decisions that the addon saw.
- A log of what the addon saw and decided.
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

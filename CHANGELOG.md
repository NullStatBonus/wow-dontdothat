# Changelog

## 0.13.2

- **Fixed: On WoW Forever, each character keeps its savings and profile when you turn off an addon.** Some addons, such as Closest Vendor and KeepThat, bring a newer settings library. When you turn them off, the game uses the older library again. The addon now moves your data back to the name that library uses.

## 0.13.1

- **Fixed: On WoW Forever, each character keeps its savings and profile.** A newer settings library saves characters under a new name. The addon now moves your data to that name once.
- Changed: The addon now uses the same library versions as Closest Vendor and KeepThat. On WoW Forever, this fixes the transparency of color pickers in addons that use these libraries.

## 0.13.0

- **New: The "Buy anyway?" question shows your mount fund.** If a purchase leaves you short of your next mount, the question says so. For example: "After this you'll have 61g of the 100g for your level 40 mount." The line does not show when you still have enough gold. It also does not show after the mount stop point.
- **Changed: The demo is slower.** `/ddt demo` shows one sample at a time, five seconds apart. A chat line tells you what each sample is. The demo takes about 40 seconds. The sample question also shows the mount fund line.

## 0.12.3

- Changed: The spell data now comes from WoW Forever build 1.60.1.70959. In this build, the Rogue spell Shank has two ranks. The addon now knows both ranks. Classic Era has no spell changes.

## 0.12.2

- **Fixed: Classic Era now uses the correct mount prices.** The level 40 goal is 100g: 20g for riding and 80g for the mount. The level 60 goal is 1,000g for the epic mount. Before, the level 60 goal was 1,200g, which are WoW Forever prices.
- **Fixed: On Classic Era, the addon now finds your level 60 mount.** It looks for an epic mount in your bags or bank. Before, it never found it, and you had to tick the box yourself.
- **New: The goal is lower when you get a discount.** At Honored with your home city, mounts and riding cost 10% less. On Classic Era, PvP rank 3 gives another 10%. Progress shows the discount.

## 0.12.1

- **Fixed: All warnings stop when you buy the mount that you set as the stop point.** Before, only trainers stopped. Vendors, the auction house, slots, COD mail and resets continued to warn. To start the warnings again, clear the "bought" checkbox or set the stop point to the level 60 mount.
- **Fixed: Each character keeps its own mount marks and profession answers.** Before, a mark on one character could stop all warnings on a new character.
  - After the update, a character keeps a mount mark only if its level is the same as or more than the mount level.
  - The addon can ask each character one time about a profession, also if it asked a different character before.
- Fixed: When you cancel a talent or pet reset, the addon adds the price from the game to your savings. Before, it added an estimate.
- Fixed: When the addon adds its note to the game's dialog, it does not show the toast or banner. Before, the toast was behind the dialog. You still hear the sound. This applies to talent resets, pet resets, COD mail, and slots when "Ask before buying" is off.
- **New: Two switches, "Resetting talents" and "Resetting pet skills".** They are in What to watch > Other. Only Hunters see the stable slot and pet skill switches.
- Changed: "Start the count over" tells you what it clears. The spell totals come back from your spellbook.
- Changed: The README does not mention marks for profession ranks. The addon does not have this feature. The README gives the correct minimum price, 1 silver.

## 0.12.0

- **New: A small warning.** When the addon warns you without a question, it can show a small toast at the top of the screen. The toast shows the icon of the item or spell. Before, the addon always showed a large banner in the middle of the screen.
  - To select Toast or Warning, go to Appearance > Warnings. New installs use Toast.
  - If you used an earlier version, you keep the large Warning banner. You can change it.
  - You can move the toast. Click Move, then Done or Cancel. Escape also cancels. You cannot move the toast in combat.
  - You can set the opacity and the size of the toast.
- **New: Each warning also shows a line in chat.** This also occurs when a question or a toast shows. To stop it, turn off "Also note warnings in chat".
- **New: `/ddt demo` and `/ddt preview <name>`.** These commands show sample warnings, marks, a tooltip, a question and an explanation. Each sample has a label. The addon does not buy anything. A real warning replaces a sample.
- **New commands:** `/ddt settings <page>`, `/ddt status`, `/ddt help <topic>`, `/ddt get`, `/ddt set` and `/ddt log`. `/ddt log clear` clears the log. `/ddt export` opens the same report as before.
- Changed: The settings have new pages: Home, What to watch, Progress, Appearance, Advanced and About. Appearance has Warnings, Explanations and Sound.
- Changed: The options panel of the game shows the Home controls. Advanced has a button that opens the class list.
- Changed: The pinned explanation is a black panel. You can set its opacity and size. Escape closes it.
- Changed: The settings, the toast and the report window use the same spacing, fonts and sizes as KeepThat and Closest Vendor.
- New: The addon has an icon in the AddOns list.
- Changed: Escape closes the debug report window. The report shows the appearance settings.

## 0.11.3

- Changed: The trainer, item and reset warnings use one shared set of alert settings. You do not see a difference.

## 0.11.2

- Fixed: The warning sound for vendor and auction house purchases uses the volume channel that you select. Before, it always used Master.

## 0.11.1

- **Fixed: On Forever, the game stopped pet ability purchases in Beast Training.** This occurred after you used a class or pet trainer. The error was "AddOn 'DontDoThat' tried to call the protected function 'UNKNOWN()'".
  - Cause: The addon changed parts of the trainer window. The game does not let you buy with training points from a changed window.
  - Gold purchases were not stopped, so class trainers did not show the error.
  - The "Buy anyway?" question now comes from a button of the addon. This button is on top of the Train button.
  - The Recommended filter now makes rows dim. It does not remove them.
  - Beast Training never shows a question.
  - Vendors, the auction house and Classic Era did not change.
- Fixed: On Forever, the question is about the spell that you selected. Before, the addon could read the wrong row.
- Fixed: The addon asks the game which type of trainer is open. Before, it could think that a window was Beast Training when it was not.
- Fixed: On Forever, the addon reads trainer rows in the correct order. Before, all rows looked unranked and not learned. Because of this, the rank-skip advice and the Progress tally did not work on Forever.

## 0.11.0

- **Changed: The rank-skip advice.** The list of ranks to skip now has numbered revisions. Revision 2 is the new default.
  - Revision 2 skips more ranks.
  - It uses your spec. It marks a rank only when all specs that you can play skip it.
  - It uses the advice in the Wowhead leveling guides.
  - It marks a level 60 rank only for utility spells, and only until you have your level 60 mount.
- New: Each skipped rank tells you why. The reasons are: the guide says to buy only the first rank, it is only a little stronger for a spell that you use rarely, it is not stronger than the rank before it, or it can wait for the mount. The Rules page shows the source of each skip.
- New: The first time the addon loads the new revision, chat shows which revision is in use and how to change it.
- New: To use the old list, type `/ddt revision 1` or use Skip list on the Tuning page. `/ddt revision` shows the revision in use. Your switches work with both revisions.
- Changed: The tools that make the skip data are in `tools/skip-revision/`. `tools/build-skip-revisions.py` makes `Data/SkipRevisions.lua` again.

## 0.10.9

- Fixed: The AddOns panel of the game showed each page heading two times. The `/ddt` window did not change.
- Changed: The store summary and the addon notes say "safeguards your gold so you can save up for your mount".

## 0.10.8

- Fixed: On Forever, Beast Training did not let you buy ranks that cost training points. The addon now does not change that window. It shows no marks and no questions there. A Pet Trainer still gets all the warnings.

## 0.10.7

- Fixed: The Forever trainer asks "Buy anyway?" again before you buy a marked spell.
- Changed: Talent resets, pet skill resets and COD mail only warn. The game's dialog stays, with a note, a sound and a banner. Bank tabs on Forever also work this way.
- Fixed: A blocked action from one warning does not stop the trainer questions. A block now stops only the warning that made the purchase.

## 0.10.6

- Fixed: On Forever, the addon checks vendor purchases again. The game removed the call that the addon used to read prices.
- Fixed: On Forever, the addon reads talents from the new talent trees, professions from the new skill list, and stable slot purchases from the new stable calls.
- Fixed: The reset at the pet trainer is now a pet reset, not a talent reset.
- Changed: `/ddt export` shows more of the game calls. This helps to find other differences.

## 0.10.5

- Fixed: On Forever, the addon checks auction house purchases. Before, it did not check them, so marked items such as bags did not show a question. Classic Era did not change.

## 0.10.4

- Fixed: On Forever, the trainer window did not let you buy some services, such as hunter pet training. The addon does not replace the Train button there now. A marked spell gets a sound and a banner, but the purchase always occurs. On Classic Era, if the game stops the "Buy anyway?" question, the button gets its own handler again.

## 0.10.3

- Fixed: The Recommended trainer filter and its row marks work in the Forever trainer window. The filter is in the Filters menu.

## 0.10.2

- Changed: Spell data for WoW Forever build 1.60.1.70790. Rogue has new Death Mark and Shank spells. Shaman Totemic Projection is now Totemic Call. Priest Binding Heal and Shaman Lava Burst are removed.

## 0.10.1

- Changed: Spell data for WoW Forever build 1.60.1.70755. Druid has new Ferocious Bite, Lacerate and Primal Bite ranks. Some Mage and Paladin talents have new names. Paladin Salvation and Blessing of Light are removed. Trainer prices are updated.

## 0.10.0

- New: The addon works on game clients in all languages. It finds spells, talents, trainers, riding and grimoires by ID. The text of the addon can be translated.

## 0.9.0

- New: Each class page shows all its spells by spec and reason. Progress shows how much you can save.

## 0.8.1

- Changed: The Home page is clearer. There is one reset control. Debug recording is off when you log in.

## 0.8.0

- New: Support for Mage, Warlock, Priest, Druid, Shaman, Rogue and Warrior. This includes Warlock grimoires and the free level 40 mount for Warlocks.

## 0.7.0

- New: Support for Paladin, with a low-cost level 40 mount goal.

## 0.6.0

- Changed: The settings have five pages. You can set how strongly the addon warns you and what it watches.

## 0.5.0

- New: The addon tells you to skip Hunter ranks that do not give much. It asks one time before you learn a new profession.

## 0.4.0

- New: Rule switches and tuning. All settings have the same look.

## 0.3.0

- New: The addon asks before you buy bank slots and stable slots, and before you pay COD mail.

## 0.1.0

- First release: Hunter spells and pet skills, Herbalism and Skinning, warnings on vendor and auction house purchases, and a tally of the gold that you kept.

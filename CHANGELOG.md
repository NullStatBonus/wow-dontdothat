# Changelog

## 0.12.1

- **Fixed: warnings now stop everywhere once you buy the mount you chose to stop at.** Before, only trainers stopped. Vendors, the auction house, bank and stable slots, COD mail and resets kept asking. They come back if you clear a "bought" checkbox or move the stop to the level 60 mount.
- **Fixed: mounts you mark as bought, and professions the addon already asked about, are now kept for each character.** Before, marking a mount on one character could silence every warning on a new alt.
  - After updating, a mount you marked is kept only on characters that are at least that level. Each character may be asked once about a profession another character was asked about.
- Fixed: a talent or pet reset you turn down now adds the price the game showed to your savings, not an estimate.
- Fixed: when the addon adds its note to the game's own dialog (talent and pet resets, COD mail, or any slot once "Ask before buying" is off), it no longer also shows the toast or banner, which sat half hidden behind the dialog. You still hear the sound.
- **New switches:** "Resetting talents" and "Resetting pet skills" under What to watch > Other. The stable slot and pet skill switches now show only for Hunters.
- "Start the count over" now says what it clears: spell totals come back from your spellbook.
- The README no longer mentions marks for profession ranks; that feature was removed earlier. It also now gives the real minimum price, 1 silver.

## 0.12.0

- **New: a smaller warning.** When the addon warns you without asking a question, it can now show a small toast at the top of the screen, with the item or spell icon, instead of the large banner in the middle.
  - Choose Toast or Warning under Appearance > Warnings. New installs use Toast.
  - If you used an earlier version, you keep the large Warning banner until you change it.
  - You can move the toast (Move, then Done or Cancel; Escape cancels) and set its opacity and size. You can't move it in combat.
- **New: every warning is also noted in chat**, even when a question or toast shows. Turn it off with "Also note warnings in chat".
- **New: `/ddt demo` and `/ddt preview <name>`** show labelled sample warnings, marks, a tooltip, a question and an explanation. Nothing is bought, and a real warning always replaces a sample.
- **New commands:** `/ddt settings <page>`, `/ddt status`, `/ddt help <topic>`, `/ddt get` and `/ddt set` for the main settings, and `/ddt log` (with `/ddt log clear`). `/ddt export` still opens the same report.
- The settings are reorganized: Home, What to watch, Progress, Appearance (Warnings, Explanations, Sound), Advanced and About. The game's own options panel now shows the Home controls, and Advanced has a button that opens the class list.
- The pinned explanation is now a black panel with its own opacity and size, and Escape closes it.
- The settings, toast and report window now match KeepThat and Closest Vendor in spacing, fonts and sizes.
- The addon now has an icon in the AddOns list.
- The debug report window can be closed with Escape and lists the presentation settings.

## 0.11.3

- Changed: the trainer, item and reset guards now share one copy of their alert settings, sound-only alert, banner fallback and chat notice. Nothing you see changes.

## 0.11.2

- Fixed: the warning sound for vendor and auction house purchases now plays on the volume channel you picked. It always played on Master before.

## 0.11.1

- Fixed: on Forever, the game refused to let you buy pet abilities in Beast Training after you used a class or pet trainer. The error said "AddOn 'DontDoThat' tried to call the protected function 'UNKNOWN()'".
  - Cause: the addon changed parts of the trainer window, and the game blocks training-point purchases in a changed window.
  - Gold purchases are not blocked, so class trainers never showed the error.
  - The "Buy anyway?" question now comes from a button of the addon, on top of the Train button.
  - The Recommended filter now fades the rows. It does not remove them.
  - Beast training never gets a question.
  - Vendors, the auction house and Classic Era are not changed.
- On Forever a flagged spell is now recognised by its place in the trainer's own service list, so the question is asked about the spell actually selected; the window numbers its rows by display order and the addon was reading that number as the service index.
- The addon now asks the client what kind of trainer is open, the way the game's own window does, before treating a window as beast training.
- Forever's trainer rows are now read in the order that client returns them (name, type, icon, level, rank text, category). The addon was reading Classic Era's order, so on Forever every row looked unranked and never learned: the rank-skip advice and the learned-versus-open tally on the Progress page were silent there.

## 0.11.0

- **The rank-skip advice has changed significantly.** The list of ranks to skip now has numbered revisions. Revision 2 is the new default.
  - Revision 2 skips more ranks.
  - It decides for your spec. A rank is flagged only when every spec you might play skips it.
  - It follows the Wowhead leveling guides where they give advice.
  - A later rank that unlocks at level 60 is flagged only for utility spells, and only until you have your level 60 mount.
- Every skipped rank now says why: the guide says to buy only the first rank, it is only a few percent stronger for a spell you only use now and then, it adds nothing over the rank before it, or it can wait for the mount. The Rules page also shows where each skip came from.
- The first time the addon loads with the new revision it prints a notice in the chat saying which revision is in use and how to change it.
- To go back to the earlier list, use `/ddt revision 1` or the new Skip list choice on the Tuning page. `/ddt revision` shows what is in use. Switches you have already set keep working under both revisions.
- The tools that build the skip data now live in `tools/skip-revision/`; `tools/build-skip-revisions.py` regenerates `Data/SkipRevisions.lua`.

## 0.10.9

- Fixed the doubled page headings in the game's AddOns panel: the page name and an identical title line were both shown. The `/ddt` window is unchanged.
- The store summary and addon notes now read "safeguards your gold so you can save up for your mount".

## 0.10.8

- Fixed beast training (a hunter's pet abilities, paid in training points) refusing ranks that cost points on Forever. The addon now leaves that window alone: no wrapped purchase, no marks, no prompts. A Pet Trainer NPC still gets the full treatment.

## 0.10.7

- The Forever trainer asks "Buy anyway?" again before a flagged ability. It now wraps the game's own purchase call instead of replacing the Train button, which the client had refused.
- Talent resets, pet skill resets and COD mail only warn now: the game's own dialog stays up with a note, a sound and a banner. Bank tabs on Forever work the same way.
- A blocked action from one guard no longer switches off the trainer's questions, and a block now switches off the guard whose purchase it was.

## 0.10.6

- Vendor purchases are checked again in the Forever client. The client removed the call that the addon used to read prices.
- The addon now reads talents from the new Forever talent trees, professions from the new skill list, and stable slot purchases through the new stable calls.
- The pet trainer's reset is now a pet reset, not a talent reset.
- `/ddt export` reports more of the client's calls, to help find other differences.

## 0.10.5

- Auction house purchases are now checked in the Forever client. Its retail-style auction house (single items and stackable goods) was never hooked, so flagged items such as bags sailed through without a question. Classic Era is unchanged.

## 0.10.4

- Fixed the Forever trainer window refusing purchases, such as hunter pet training. The Train button is no longer replaced there, so a flagged spell gets a warning sound and banner but the purchase always goes through. If the game ever refuses the "Buy anyway?" question on Classic Era, the button gets its own handler back.

## 0.10.3

- The Recommended trainer filter and its row marks now work in the Forever trainer window, with the filter in the Filters menu.

## 0.10.2

- Spell data refreshed for WoW Forever build 1.60.1.70790: new Rogue Death Mark and Shank, Shaman Totemic Projection is now Totemic Call, and Priest Binding Heal and Shaman Lava Burst are gone.

## 0.10.1

- Spell data refreshed for WoW Forever build 1.60.1.70755: new Druid Ferocious Bite, Lacerate and Primal Bite ranks, renamed Mage and Paladin talents, and the removed Paladin Salvation and Blessing of Light spells dropped. Trainer prices updated.

## 0.10.0

- Works on game clients in any language, recognising spells, talents, trainers, riding and grimoires by ID, and the addon's text can now be translated.

## 0.9.0

- Every class page lists all its spells by spec and reason, and Progress shows your projected savings.

## 0.8.1

- Clearer Home page, one reset control, and debug recording off at login.

## 0.8.0

- Support for Mage, Warlock, Priest, Druid, Shaman, Rogue and Warrior, including Warlock grimoires and a free level 40 mount for Warlocks.

## 0.7.0

- Paladin support with a cheap level 40 mount target.

## 0.6.0

- Settings simplified into five pages with a nudge level and watch areas.

## 0.5.0

- Skips low-value Hunter ranks and asks once before you learn a new profession.

## 0.4.0

- Rule switches, tuning and a consistent settings look.

## 0.3.0

- Asks before bank slots, stable slots and COD mail.

## 0.1.0

- First release: Hunter spells and pet skills, Herbalism and Skinning, warnings on vendor and auction house purchases, and a tally of gold kept.

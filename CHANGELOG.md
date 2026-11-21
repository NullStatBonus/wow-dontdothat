# Changelog

## 0.13.4

- **Fixed: Reset all settings brings back purchase warnings at once.** Before, vendor and auction house warnings stopped until you reloaded.
- Fixed: After a reset, the Classes page shows the newest skip list. Before, it kept the list you picked earlier.
- Fixed: A reset during Move puts the warning in its default place. Before, the Move stayed open.

## 0.13.3

- **Fixed: On WoW Forever, the addon finds savings and profiles from version 0.13.0 and earlier.** Before, 0.13.1 and 0.13.2 lost them on some setups.

## 0.13.2

- **Fixed: On WoW Forever, characters keep their savings and profile when you turn off an addon.** Before, turning off Closest Vendor or KeepThat could hide them.

## 0.13.1

- Changed: The addon uses the same library versions as Closest Vendor and KeepThat.
- **Fixed: On WoW Forever, each character keeps its savings and profile.** Before, a newer library could hide them.
- Fixed: On WoW Forever, color pickers in addons that use these libraries show the correct transparency. Before, the transparency was inverted.

## 0.13.0

- **New: The "Buy anyway?" question shows your mount fund.** It tells you when a purchase leaves you short of your next mount.
- Changed: `/ddt demo` shows one sample every five seconds. A chat line names each sample.

## 0.12.3

- **Changed: The spell data comes from WoW Forever build 1.60.1.70959.** The addon knows both ranks of the Rogue spell Shank.

## 0.12.2

- New: The mount goal is lower when you get a discount. Honored reputation and PvP rank 3 on Classic Era give 10% each.
- **Fixed: Classic Era uses the correct mount prices.** Before, the level 60 goal was 1,200g instead of 1,000g.
- Fixed: On Classic Era, the addon finds your epic mount in your bags or bank. Before, you had to tick the box yourself.

## 0.12.1

- New: Two switches, "Resetting talents" and "Resetting pet skills", in What to watch.
- Changed: "Start the count over" tells you what it clears.
- **Fixed: All warnings stop when you buy your stop-point mount.** Before, only trainers stopped.
- Fixed: Each character keeps its own mount marks and profession answers. Before, one character's mark could stop warnings on another.
- Fixed: A cancelled talent or pet reset adds the game's price to your savings. Before, it added an estimate.
- Fixed: A note on the game's dialog does not also show a toast. Before, the toast showed behind the dialog.

## 0.12.0

- **New: A small toast can show warnings at the top of the screen.** You can move it and set its size and opacity.
- New: Each warning also shows a line in chat.
- New: `/ddt demo` and `/ddt preview` show sample warnings. The addon does not buy anything.
- New: More commands, such as `/ddt status`, `/ddt help` and `/ddt log`.
- New: The addon has an icon in the AddOns list.
- Changed: The settings have new pages: Home, What to watch, Progress, Appearance, Advanced and About.
- Changed: The pinned explanation is a black panel. You can set its size and opacity.
- Changed: Escape closes the explanation and the debug report window.

## 0.11.3

- **Changed: Trainer, item and reset warnings use one set of alert settings.**

## 0.11.2

- **Fixed: Vendor and auction house warnings use the sound channel you select.** Before, they always used Master.

## 0.11.1

- Changed: The Recommended filter dims rows. It does not hide them.
- **Fixed: On Forever, Beast Training lets you buy pet abilities.** Before, the game showed a "protected function" error.
- Fixed: On Forever, the question is about the spell you selected. Before, it could name the wrong row.
- Fixed: The addon knows which type of trainer is open. Before, it could mistake a window for Beast Training.
- Fixed: On Forever, the rank-skip advice and the Progress tally work. Before, all rows looked unranked and not learned.

## 0.11.0

- New: Each skipped rank tells you why.
- New: Chat tells you which skip list is in use the first time it loads.
- New: `/ddt revision 1` brings back the old skip list.
- **Changed: The skip list has numbered revisions, and revision 2 is the default.** It follows the Wowhead leveling guides and your spec.

## 0.10.9

- Changed: The store summary says "safeguards your gold so you can save up for your mount".
- **Fixed: The game's AddOns panel shows each page heading once.** Before, each heading showed two times.

## 0.10.8

- **Fixed: On Forever, Beast Training lets you buy ranks that cost training points.** Before, the addon blocked them.

## 0.10.7

- Changed: Talent resets, pet skill resets, COD mail and Forever bank tabs only warn. The game's own dialog stays.
- **Fixed: The Forever trainer asks "Buy anyway?" before you buy a marked spell.** Before, it bought without a question.
- Fixed: A blocked action stops only the warning that caused it. Before, it also stopped the trainer questions.

## 0.10.6

- **Fixed: On Forever, the addon checks vendor purchases.** Before, it could not read prices after a game change.
- Fixed: On Forever, the addon reads talents, professions and stable slot purchases. Before, it missed them.
- Fixed: The pet trainer reset counts as a pet reset. Before, it counted as a talent reset.

## 0.10.5

- **Fixed: On Forever, the addon checks auction house purchases.** Before, marked items such as bags showed no question.

## 0.10.4

- **Fixed: On Forever, the trainer lets you buy services such as pet training.** Before, the addon blocked them.

## 0.10.3

- **Fixed: The Recommended filter and row marks work in the Forever trainer.** Before, they did not show.

## 0.10.2

- **Changed: The spell data comes from WoW Forever build 1.60.1.70790.** It adds new Rogue spells and removes some Priest and Shaman spells.

## 0.10.1

- **Changed: The spell data and trainer prices come from WoW Forever build 1.60.1.70755.**

## 0.10.0

- **New: The addon works on game clients in all languages.** Its own text can be translated.

## 0.9.0

- **New: Each class page shows all its spells by spec and reason.**
- New: Progress shows how much you can save.

## 0.8.1

- **Changed: The Home page is clearer and has one reset control.**
- Changed: Debug recording is off when you log in.

## 0.8.0

- **New: Support for Mage, Warlock, Priest, Druid, Shaman, Rogue and Warrior.**
- New: Warlock grimoires and the free Warlock mount are part of the goals.

## 0.7.0

- **New: Support for Paladin, with a low-cost level 40 mount goal.**

## 0.6.0

- **Changed: The settings have five pages.** You can set how strongly the addon warns and what it watches.

## 0.5.0

- **New: The addon tells you to skip Hunter ranks that do not give much.**
- New: The addon asks one time before you learn a new profession.

## 0.4.0

- **New: Rule switches and tuning.**

## 0.3.0

- **New: The addon asks before you buy bank slots and stable slots, and before you pay COD mail.**

## 0.1.0

- **New: First release.** It covers Hunter spells and pet skills, Herbalism, Skinning, vendor and auction house purchases.

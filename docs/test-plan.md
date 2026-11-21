# In-game test plan

Test on a **Hunter**. Everything below is checked in the game window; nothing needs a console except the first step. Tick each line; if one fails, note what you saw and the `/ddt log` report.

Levels needed: most steps work at **level 10**. Steps marked (L12) need level 12, (L18) level 18.

## 0. Setup
- [ ] Copy the `DontDoThat` folder over the installed one and `/reload`.
- [ ] `/console scriptErrors 1` (so any problem shows as a popup).
- [ ] `/ddt version` prints "Don't Do That v" and the version in the .toc files. No error popups.
- [ ] `/ddt debug on` (so the report has details).

## 1. Settings window
- [ ] Type `/ddt`. The settings window opens at **Home**, with six pages: Home, What to watch, Progress, Appearance, Advanced, About.
- [ ] Options > AddOns shows "Don't Do That" with the other pages under it. Selecting the root entry shows the Home controls at once (not a blank page).
- [ ] Home: an introduction, the switch **Turn on Don't Do That**, the three warning levels (**Mark it, but let me buy**, **Ask me first**, **Ask me about everything**), **When to stop warning me** (after the level 60 or level 40 mount), and **On-screen message** (**Show a message on screen**) and **Start over** (**Reset all settings**). Turn the first switch off. The other controls grey out. Turn it back on.
- [ ] What to watch: the areas Spells, Professions and Shopping, each with an on/off switch, the **Recommended filter** switch, the item kinds with their vendor and auction house choices, and the minimum price.
- [ ] Progress: three boxes. **Milestones** shows a gold status line, a progress line ("You have 12g of the 100g you need (12%)."), the two mounts (icon, price, gray note) and the two "I've already bought" switches. **Projected savings** shows what you could still save. **Tally** shows **Kept**, **Spent anyway** and **Start over**. The Tally shows numbers before you visit any trainer, because it reads your spellbook and the bundled spell list. "Kept so far" is about the cost of everything marked that you could buy at your level but have not.
- [ ] Appearance: three tabs, **Warnings**, **Explanations** and **Sound**. There is no separate "Sound & messages" page anywhere.
- [ ] Advanced: a tree with **Tuning**, **Classes** and **Debug**, and a note on where settings are kept.
- [ ] Appearance > Sound: **Warning sound** (a picker that starts with common sounds such as Raid warning, Ready check, Alarm clock 1-3 and Murloc aggro, then any sound-pack sounds, and a **Play sound** button), and the slider for how often the same warning repeats. (The on-screen message switch is on Home.)
- [ ] Advanced > Classes: the tree has **How this works** and the classes. Open **Hunter**. The categories show counts. Open **Save your gold**. Each spell has its **real icon at once**, even before you open a trainer (the icons come from the game by spell ID), the name and a gray reason. A question mark means the game returned no icon for that spell. Tell me which spell.
- [ ] About: a gold title and the version, then three sections (What the marks mean, How to use it, Good to know). Each mark is a colored bullet with a gray explanation under it.
- [ ] Advanced > Debug: **Recording** (**Record debug information** with its explanation), **Report** (a note and **Show debug report**) and **Clear** (a note and **Clear the recording**).

## 2. Marks in the trainer
- [ ] Open your **Hunter trainer**. Flagged rows show a colored **(i)** at the right edge; kept rows show nothing (for example Aspect of the Hawk, Serpent Sting, Wing Clip, Mend Pet, Dual Wield).
- [ ] Hover an (i): a tooltip with a **colored heading** (red, gold or blue to match the mark), the reason on its own wrapped line, then a blank line and the cost in **gold** ("Costs 12s"). Click it: the message stays open, spaced out with blank lines and sized to fit its text; click again to close it.
- [ ] Colors: red for Distracting Shot, Aspect of the Beast, Wyvern Sting, Volley; gold for tracking spells (Track Humanoids …), Scare Beast, Beast Lore, Scorpid/Viper Sting.
- [ ] Scroll the list: the (i) marks stay on the right rows.
- [ ] Open the **Pet Trainer**: the five resistances are marked gold; Great Stamina and Natural Armor ranks 5/7/9 and 6/8/10 are marked red.
- [ ] Hunter **beast training** (the pet's own window, paid in training points): no marks, no prompts, and ranks that cost points train normally. The log shows no "BuyTrainerService wrapped" line while it is open.
- [ ] Back in settings, **Rules** now shows real spell icons for what you just saw.

## 3. Warning and question
- [ ] `/ddt test`: you hear the sound and get **a dialog only, no toast or banner**. **Cancel** prints "test: you declined". Run it again and press **Accept**: it prints "test: you chose to buy it anyway (nothing was bought)". If Accept does nothing, or you see "Don't Do That: that didn't work (…)" in chat, copy that text and `/ddt log` (the `popup:` lines say what happened).
- [ ] (L12) Select **Distracting Shot, Rank 1** (6 silver) and click **Train** (on Forever, the click lands on the addon's own button on top of Train): sound plus the "Buy anyway?" dialog. **Cancel**: nothing is bought, the spell is still listed.
- [ ] Click Train again and choose **Buy anyway**: the spell **is learned** and the list updates. (This is the key check. If a "blocked from an action" popup appears, or it isn't bought, tell me; the addon will also say in chat that it is turning the question off.)
- [ ] Buy a gold row such as **Track Humanoids**: **no** dialog and **no** sound; it just buys.
- [ ] Home > choose **Mark it, but let me buy**, then try a red row: you hear the sound and see the **on-screen message** (a toast on a fresh profile), and the purchase goes ahead.
- [ ] Turn off **Play a warning sound** (Appearance > Sound): no sound and no on-screen message, but the chat line still prints. Questions still show. Turn everything back on afterwards.
- [ ] Turn the whole addon off: no marks, no sound, no dialog.

## 4. Recommended filter
- [ ] Click the trainer's **Filter** menu: a **Recommended (Don't Do That)** checkbox appears below Available / Unavailable / Already known, and it is **checked**.
- [ ] The list is shorter (no extra text is added to the window): Distracting Shot, tracking spells, Eagle Eye and similar are gone; category headers remain. On Forever those rows are faded instead of removed (removing them taints Blizzard's list and the game then refuses beast training).
- [ ] Forever: at a class trainer select a flagged spell (Distracting Shot) and click Train. The question appears; decline and nothing is bought; click Train again and confirm, and the spell is learned. The button lights up under the mouse and presses as usual. An unflagged spell is bought with no question.
- [ ] Forever: in `/ddt log` with a class trainer open, the trainer snapshot shows `rank=2 ... status=available` style rows, not an icon number as the status; a rank the skip list passes over is faded and marked.
- [ ] Forever: with the filter on, visit a class trainer and a pet trainer, then open Beast Training and buy a pet ability that costs training points. No error, no question, and the ability is learned. `/run print(issecurevariable("BuyTrainerService"))` prints `true` throughout.
- [ ] Select a visible spell, click Train (use a cheap one): **the spell you selected is the one bought**.
- [ ] Scroll the list; click a category header to collapse and expand it; use the collapse-all button. Nothing looks broken and rows stay in order.
- [ ] Untick Recommended: every row comes back. Tick it again.
- [ ] With the trainer open, untick **Add a Recommended filter to trainers** on the What to watch page: all rows return at once and the **Recommended entry is gone** from the Filter menu. Tick it again and it comes back.
- [ ] With the trainer open, turn off **Turn on Don't Do That** on Home: all rows return, the (i) marks disappear and the Recommended entry is gone from the Filter menu. Turn it back on.
- [ ] Untick the **Recommended checkbox inside the Filter menu**: all rows return but the entry stays, so you can tick it again.
- [ ] Switch the Available/Unavailable/Already known boxes: the list still behaves normally.
- [ ] If anything looks wrong, the filter turns itself off and the normal window returns. `/ddt log` then contains a line "filter: turned off (reason)". Send it to me.

## 5. Tally and milestones
- [ ] Buy one marked spell and reopen the Progress page: the number moves from "Kept so far" to **Spent** straight after the purchase, without needing another trainer visit.
- [ ] After visiting both trainers, the **Tally** box on the Progress page shows "Kept so far" with a number (the cost of flagged things you could buy now but haven't).
- [ ] Buy one marked spell: **Spent on things the addon marked** goes up by its price.
- [ ] (L18) Skip Serpent Sting rank 2 and buy rank 3 straight away. It should be allowed, which confirms ranks can be bought out of order. The tally doesn't change, because those ranks aren't marked.
- [ ] **Start the count over** asks for confirmation and sets everything to zero.
- [ ] Milestones: tick "I've already bought my level 40 mount": the status changes to saving for level 60. Untick it.
- [ ] After you actually learn Apprentice Riding, the status moves on by itself. (If it doesn't, the override above is the workaround, and tell me.)

## 6. Resets
- [ ] Talents (level 10): open the talent window, spend your point, click **Learn**. Nothing is blocked (talent choices aren't judged).
- [ ] Ask your class trainer to **reset your talents**: you hear the warning sound and the **game's own dialog** stays, with a red "Don't Do That:" note added to it. **No toast or banner** shows, with either Toast or Warning chosen. One line is added to chat.
- [ ] Press **Cancel**: nothing is reset, and the Tally later shows "Talent resets: skipped 1".
- [ ] Ask again and press **Accept** (it costs gold, so only if you're happy to): your talents reset and the Tally shows "done 1".
- [ ] Buy a bank slot: Don't Do That's own question shows instead of the game's, with no toast or banner. Turn off **Ask before buying** and try again: the game's own dialog stays with the note and the sound, and no toast or banner.
- [ ] Pet Trainer (needs a pet that has learned something): choose its **untrain** option and do the same.

## 7. Safety checks
- [ ] With every switch on, open and close the trainer a dozen times, scroll, and click around: no error popups.
- [ ] Open the **talent window**, **spellbook** and **bags** while the addon is on: nothing changes or breaks.
- [ ] `/ddt log`, copy it, and look for lines like "overlay: ClassTrainerFrame_Update hooked", "confirm: Train button click wrapped" (Classic Era) or "confirm: Forever window: Train button hooked, question asked from the addon's own button" and "filter: menu entry registered". Send me the report if any step above failed.

## 8. Spell data check
- [ ] `/ddt log`, then find the **Spell data check** section. It should say "bundled spell tables: build 1.60.1.70532, 157 spells for HUNTER" and "spellbook says N known" with N a believable number for your character (not 0 unless you know nothing).
- [ ] The five sample lines each show an **icon** number (not nil) and a believable known flag: for example Arcane Shot rank 2 known=true once you've bought it, false before.
- [ ] If a sample shows `known [..=false]` for something you do know, or `icon nil`, send me the section: it means an ID doesn't match this client.

## 9. Items and earn-back
- [x] At a vendor, right-click an armor or weapon piece costing 10 silver or more: a "Buy anyway?" question appears. Cancel: nothing bought, Tally shows one more turned-down purchase. (Checked 2026-10-24 with Hunter's Boomstick, 1192c: flagged, popup shown, cancelled; `itemsAvoided` rose to 4.)
- [x] The question has a line like "At level N, that's about X of grinding to earn back", and the gold amount is right. (Verified by hand 2026-10-24.)
- [x] Vendor: Accept buys the item. (Verified by hand 2026-10-24.)
- [x] Buy something under the minimum price (or a Food and drink item at a vendor): no question. (Verified by hand 2026-10-24; the minimum was lowered to 5c for the auction house tests.)
- [x] Purchases page (was Items): every category has a dropdown; changing one takes effect without a reload; gold/silver/copper boxes show 0 / 10 / 0 and reject letters.
- [x] Auction house: a flagged item shows the question and Cancel buys nothing. (Checked 2026-10-24 with Malachite, 18c, three times; `PlaceAuctionBid` wrapped and the game still calls ours.)
- [x] Auction house: both a bid and a buyout show the question, and Accept completes them. (Verified by hand 2026-10-24.) If instead the chat says item purchases are only warned, `/ddt log` and send the "items:" lines (task 1.1).
- [x] Talent-reset questions show the earn-back line. (Verified by hand 2026-10-24.)
- [ ] Trainer questions show the earn-back line.
- [ ] Appearance > Sound: set Volume channel to Dialog, turn the Master volume down and Dialog up, and buy a flagged vendor item: the warning sound follows the Dialog volume.

## 10. Bank, stable and COD
- [ ] Buy a bank slot from the banker: the game's dialog is replaced by a question with the price and the earn-back line. Cancel: nothing bought, Tally's turned-down count rises. Accept: slot bought.
- [ ] Hunter: same for a stable slot at the stable master.
- [ ] Open a COD mail and take the item: the question shows the COD amount. Accept pays it; cancel leaves the mail alone. Taking an item from ordinary mail shows nothing.
- [ ] Items page: turn each of the three switches off and confirm the game's own dialog returns untouched.
- [ ] `/ddt log`: the Items section lists each guarded dialog as on and "lastSeen" with the dialog name and price read. Send it if a dialog never triggered.

## 11. Language and spell identity
- [ ] On an English client, `/ddt log`: the **Spell identity** section lists what the trainer row and the talent call return. Paste it into the change notes: it settles whether Forever gives the trainer a spell ID directly.
- [ ] Open any trainer and type `/ddt trainerids`: a window lists, per row, what every known call returns, and ends with a `RESULT:` line. Then `/ddt trainerids hover`, hover a trainer row within 5 seconds, and read the **hovered row** section. Paste both into the change notes. The report also ends with **identity checks**: talent links (do they carry a talent ID the table knows), the riding spell IDs, the profession apprentice spells and which trainer window is open. Run it once at a class trainer, once at a profession trainer, once at the Pet Trainer and once with no trainer open. So far this has only been done on a Hunter with no talent points; repeat it on another class that has spent talent points (the report should say "with points" and resolve them), ideally a Paladin or Warlock to see the class mount spells as known.
- [ ] A talent you have points in (for example Aimed Shot for a Hunter) counts as active: the spell is judged as part of your rotation, and `/ddt log` shows what `GetTalentLink` returns.
- [ ] Switch a spell off in Advanced > Classes (for example Distracting Shot), `/reload`, and open the trainer: the row has no (i). Switch it back on and the (i) returns.
- [ ] If you can run the client in another language (the locale is set in the Battle.net launcher): the trainer marks, the Classes page and the toggles from the two lines above behave exactly the same, with spell names in that language and the addon's own text in English. A switch set in English is still set.
- [ ] Learn a profession's first tier from its trainer (Alchemy, Cooking, Tailoring…): you are asked once. Learning a gathering profession asks nothing. A second tier (Journeyman) asks nothing.
- [ ] Warlock: at a demon trainer or vendor, a secondary grimoire (Soothing Kiss, Devour Magic…) is asked about and one the guides recommend (Firebolt, Torment…) is not. Works the same on a client in another language.
- [ ] The Milestones box on the Progress page notices riding once learned: Apprentice Riding on Forever, or your race's riding spell (Horse Riding, Wolf Riding…) on Classic Era. On Classic Era level 60 riding shows once the racial riding skill has a max rank of 150; the identity checks print the skill line's rank and what `ReadRiding` says.

## 12. Skip list revisions
- [ ] First load after installing or updating (use a fresh `WTF` profile, or delete `revisionNotice` from the saved variables): the chat prints, once, that skip list revision 2 is in use, that its rules changed significantly (many more ranks skipped, decided for your spec, each with its reason), and how to change it (`/ddt revision 1`, Advanced > Tuning). `/reload`: it is not printed again.
- [ ] `/ddt revision` prints the revision in use and the revisions available. `/ddt revision 1` says "Now using skip list revision 1." and the Classes page and the Tuning page agree. `/ddt revision 9` changes nothing and lists the valid revisions. `/ddt revision 2` goes back.
- [ ] Advanced > Tuning > Skip list: a select with "Revision 2 (default): ..." and "Revision 1: ...". Picking Revision 1 and reopening Advanced > Classes shows its ranks to skip, and the line at the top of the class page names revision 1.
- [ ] Warrior at a trainer on revision 2: Thunder Clap rank 2 and later are marked, and the tooltip says the leveling guide says to buy only the first rank of this spell. Rend rank 5 says to buy it only up to rank 4. On revision 1 the same ranks give the same guide reasons. Neither tooltip names Wowhead or "computed".
- [ ] A rank skipped for some specs only (for example a Mage spell skipped for Frost and Fire): with Frost chosen as the spec it is marked; with Arcane chosen it is not; with the spec undecided and talents split, it is not marked.
- [ ] At level 60 without the mount: a utility spell's later rank says it can wait until the level 60 mount; the first rank of a new level 60 spell and a damage or healing rank are not marked. After buying the mount nothing is marked.
- [ ] Switch an ability off in Advanced > Classes, then change revision: it stays off under both. Switch off Skip ranks on Tuning: no rank is marked under either revision.
- [ ] The Ranks to skip list in Advanced > Classes lists each rank with its reason and, beneath it, where it came from ("From the Wowhead leveling guide.", "Computed from the game data.", "From the earlier skip list.").

## 13. Warning style and chat line
- [ ] Upgrade: install this version over a profile saved by an older version (no `alert.style`, `styleMarked` unset). On the first `/reload` the style is **Warning**; Appearance > Warnings shows Warning selected and the toast controls are hidden with a note. `/reload` again: still Warning.
- [ ] Fresh install (new `WTF` profile): the style is **Toast**. Try to buy a flagged item with Mark it, but let me buy: a small toast shows near the top of the screen with the tier color, item, price and reason, and it does not take clicks.
- [ ] Reset all settings (Home, confirm), then `/reload`: the style is Toast, even on a profile that had Warning. The tally and progress are kept.
- [ ] Choose Warning, buy a flagged item that gets no question: the large centered message shows, not a toast. Choose Toast again: toast.
- [ ] Question case: a flagged trainer spell with Ask me first shows "Buy anyway?" and **no** toast or banner. Cancel and Accept still work.
- [ ] Chat line: each warning prints one line in chat (item, reason). It prints with a question, with Mark it, but let me buy, and with the warning sound off (Appearance > Sound). It does not print twice inside the cooldown (set the seconds to 10 and repeat quickly). Turn off **Also note warnings in chat**: no line, toast and sound unchanged.
- [ ] Turn off **Show a message on screen** on Home: no toast or banner, but the sound and the chat line stay. Appearance > Warnings explains the message is off and Preview still works.
- [ ] Appearance > Warnings > Move: a sample toast appears above the settings with **Done** and **Cancel**. Drag it, press **Done**: it stays there on the next toast and after `/reload`. Move again, drag, press **Cancel**: it jumps back. Move again, drag, press **Escape**: it goes back, the Done/Cancel overlay is gone and the settings window stays open. Afterwards Escape closes windows as usual and nothing is left on screen. In combat (for example, attack a target dummy), press **Move**: chat says to leave combat and nothing moves. Start Move out of combat, drag, then enter combat: it goes back and the overlay is gone. **Reset position** puts it at the start.
- [ ] Toast Background opacity 0: no box or border, only the text and icon. 80 and 100: box matches. Text and icon opacity 0 / 80 / 100: words and icon fade, the box is unchanged. Scale 100 and 150: the toast is 1.5 times larger and still readable and not cut off at the screen edge. Move the toast, then change its scale: it keeps its place.
- [ ] Appearance > Explanations: click an (i) on a trainer row. The pinned explanation is a black box with wrapped text and a close button. The button and Escape both close it. **Preview** (a sample) closes by its timeout or its X button, and Escape does not close it. Background and text opacity 0 / 80 / 100 and scale 100 / 150 change only the pinned box; **Preview** shows it without a trainer.
- [ ] The tooltip on hover (not pinned) is unchanged.
- [ ] With a real explanation pinned, `/ddt preview explanation` and `/ddt demo` leave it in place: no sample explanation shows, and the real one is still open after the samples end.

## 14. Previews and demo
- [ ] `/ddt demo`: sample toasts/warnings, a row of marks with a "Sample" caption, a hover tooltip, an inert question and a pinned explanation show, nothing is bought, the Tally does not change and nothing is added to the log as a purchase.
- [ ] `/ddt demo` pace: one sample at a time, about five seconds apart, in this order: four toasts (or warnings), the explanation, the marks with a tooltip, the question. Each step adds a chat line "Demo N of 7: …" that matches what is on screen. The question has the mount fund line: your own numbers when the sample price leaves you short, else the 61g of 100g example. Everything is gone about 40 seconds after the start.
- [ ] `/ddt preview` lists toast, warning, mark, tooltip, explanation, prompt. Each `/ddt preview <name>` shows that one sample. `/ddt preview prompt` shows a question that buys nothing when accepted.
- [ ] While a sample is showing, try to buy a flagged item: the real warning or question takes over.
- [ ] `/ddt preview banana` says it is unknown and lists the kinds.
- [ ] Appearance > Warnings **Preview** shows the chosen style; Explanations **Preview** shows a pinned explanation.

## 15. Commands
- [ ] `/ddt` opens at Home, also after the window was last left on Classes. `/ddt settings` opens Home. `/ddt settings appearance`, `warnings`, `explanations`, `sound`, `advanced`, `classes`, `debug`, `about`, `watch`, `progress` each open that page. `/ddt settings nothing` lists the valid pages.
- [ ] `/ddt status` prints one line each for nudge, warnings, explanations and sound. `/ddt status nudge`, `warnings`, `explanations`, `sound` print that topic. With the nudge on a custom mix, `/ddt status nudge` lists the custom values. `/ddt status foo` lists the topics.
- [ ] `/ddt help` lists the commands. `/ddt help appearance`, `rules` and `diagnostics` each print their group. `/ddt help foo` lists the topics.
- [ ] `/ddt get` lists the keys. `/ddt get nudge` shows the value. `/ddt get nope` says the setting is unknown.
- [ ] `/ddt set appearance.warning-style warning`: confirms, and the Appearance page (if open) and the next warning change at once, without a reload. `/ddt set appearance.toast.scale 150` works; `/ddt set appearance.toast.scale 400`, `... abc`, `/ddt set appearance.chat maybe`, `/ddt set nudge loud` and `/ddt set appearance.toast.scale` (no value) are refused with the allowed values, and `/ddt get` shows the old value. Set `appearance.warning-style toast` back.
- [ ] `/ddt set` refreshes like the controls: with Appearance open, `/ddt set appearance.toast.scale 150` and `appearance.warning-style warning` update the page at once; with a trainer open, `/ddt set watch.spells off` and back on update the marks and filter; with a pinned explanation open, `/ddt set appearance.explanation.scale 150` resizes it.
- [ ] `/ddt test` with Ask before buying off and the warning sound off: it says only the chat line would show (chat line on) or that nothing would happen (chat line off).
- [ ] `/ddt set watch.spells off`, then `/ddt get watch.spells` says off; Home/What to watch agree. Set it back on.
- [ ] `/ddt log` opens the report window; Escape closes it. Reopen it: the text is selected; Ctrl+A, Ctrl+C copies it. Edit the text, close, reopen: the report is fresh and unchanged. `/ddt export` opens the same report.
- [ ] `/ddt log clear` asks first. **Cancel**: prints "log kept" and the log still has its lines. Run it again and accept: prints "log cleared"; with a real "Buy anyway?" question open, `/ddt log clear` asks in its own dialog and the question stays untouched; and `/ddt log` shows an empty log. `/ddt clear` empties it at once without asking.
- [ ] If the report window cannot open (for example with the AceGUI library removed in a test copy), `/ddt log` prints the whole report in chat.
- [ ] `/ddt debug on` and `/ddt debug off` print "debug on" / "debug off". `/ddt debug maybe` prints the usage.
- [ ] Advanced > Debug > **Show debug report** opens the same report. The header lists the warning style, chat line and appearance settings.

## 16. Game options and the AddOns list
- [ ] Options > AddOns > Don't Do That > **Advanced** shows Tuning and Debug and an **Open classes** button (no class tree, and the game does not freeze). The button closes the game's Settings window and opens Advanced > Classes in the Don't Do That window, with only that path open.
- [ ] Standalone `/ddt` > Advanced > Classes starts collapsed and the tree works as before.
- [ ] Change **Ask me first** to **Mark it, but let me buy** on the root game-options page, then open `/ddt`: Home shows the same choice.
- [ ] The Don't Do That window opens at about 600 by 460 and can be resized. Dropdowns, sliders and buttons are not stretched across the window.
- [ ] At the character screen, the AddOns list shows the Don't Do That icon (a badge) next to the name, on both Classic Era and Forever.

## 17. Stop point and reset savings
- [ ] Home: stop after the **level 40** mount, then on Progress mark the level 40 mount done. Buy a flagged AH item (for example armor over 10 silver): it is bought with no question, sound or message. Buy a bank slot and reset talents: only the game's own dialogs show, with no note from the addon.
- [ ] Clear the level 40 "done" checkbox: the same AH purchase asks "Buy anyway?" again.
- [ ] With the mount not done, start a talent reset, note the price the game quotes, and cancel. Progress grows by that quoted price, not by a different estimate.
- [ ] What to watch > Professions has only the warning switch and its note: no rank switch and no skill margin slider.
- [ ] What to watch > Other on a non-Hunter shows Buying a bank slot, Paying for COD mail and Resetting talents only. On a Hunter it also shows Buying a stable slot and Resetting pet skills.
- [ ] Turn off **Resetting talents**, then reset talents: only the game's dialog shows, with no sound or note, and Progress does not change. Turn it back on: the warning returns.
- [ ] Progress > **Start the count over**: the confirm text says spell totals are worked out again. After it, "Purchases you turned down" is 0; spell totals for learned ranks come back.
- [ ] Buy a flagged item that costs 2 silver: the question shows. One that costs 80 copper: no question.

## 18. Per-character marks
- [ ] On a level 60 character, mark the level 40 mount bought (Progress > Not right?). Log in a level 10 character: its checkbox is clear and warnings are active.
- [ ] On the level 10 character, learn Tailoring after another character was asked about it: the question shows once.
- [ ] Update from 0.12.0 with a mark saved: a character at that level or higher keeps the mark; a lower character does not. `/ddt export` shows "mounts marked bought (this character)".

## 19. Mount goals per client
- [ ] Classic Era, Progress: the level 40 mount says 100g for riding and your first mount; the level 60 mount says 1,000g for an epic mount and that no riding lesson is needed.
- [ ] A character Honored with its home city (Stormwind, Ironforge, Darnassus, Gnomeregan, Orgrimmar, Thunder Bluff, Undercity, Darkspear): the progress line ends "(10% off for your reputation and rank)" and the goal is 10% lower. Below Honored: no note.
- [ ] Era level 60 with an epic mount in the bags or bank: Progress says the level 60 mount is bought, without ticking the box.
- [ ] WoW Forever, Progress: level 60 is 1,000g riding plus 200g for each epic mount.

## 20. Mount fund line in the question
- [ ] With less gold than the mount goal on Progress, buy a spell with a red mark (or use `/ddt test`). Below the earn-back line, the question says "After this you'll have X of the Y for your level N mount." X is your gold minus the price. Y and N match Progress.
- [ ] At a vendor, ask about a flagged item. The question has the same line, with that item's price.
- [ ] If you have more gold than the goal plus the price, the question has no such line. To check this with little gold, tick "I've already bought my level 40 mount" on Milestones; the goal becomes the level 60 mount, so the line shows again. Untick it after.
- [ ] After the mount stop point is reached, no question has the line.

## 21. Settings library update
- [ ] Classic Era and WoW Forever, with Don't Do That, Closest Vendor and KeepThat all loaded: open each addon's settings window, `/reload`, visit a merchant. No Lua errors.
- [ ] WoW Forever, a character with savings on Progress and a profile other than Default: after the update, Progress shows the same savings and observed prices, and the same profile is in use.
- [ ] WoW Forever, the same character: pick another profile, `/reload`. The profile you picked stays.
- [ ] Classic Era: savings and profile are unchanged after the update.
- [ ] WoW Forever, a character with savings and a non-default profile: turn off every addon that ships the newer library (Closest Vendor, KeepThat), `/reload`. Progress and the profile are unchanged. Turn them on again, `/reload`: still unchanged.

## 22. Reset all settings takes effect at once
Each check starts with Home > **Reset all settings** and no `/reload` before the action.
- [ ] Reset, then buy a piece of armor over 1 silver at a vendor and answer No. Then `/reload` and send saved variables.
  Check: the question shows. The character's ledger `itemsAvoided` is one higher, and the profile has no `itemModes` or `minPrice`.
- [ ] Type `/ddt revision 1`, reset, then open Advanced > Classes > your class.
  Check: the "Ranks to skip follow skip list revision N" line names the same revision as `/ddt revision`, not 1.
- [ ] Appearance > Warnings > **Move**, drag the toast away, then reset. Then `/ddt preview toast`, `/reload` and send saved variables.
  Check: the Move box closes and the sample toast shows at top center. The profile has no `toast.point`.

## Not covered yet
- Profession trainer rows are recognised by the client's name for the apprentice spell. Section 11 checks this on a real trainer; until it is ticked the row shape is unverified. With debug on, open each trainer and `/ddt log`.
- Anything on WoW Forever itself. Everything here is Classic Era until Forever is available.

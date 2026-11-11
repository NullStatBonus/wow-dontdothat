# Store listing

This page has the text and field values for the CurseForge and Wago projects. Both TOC files already have the project IDs (`## X-Curse-Project-ID`, `## X-Wago-ID`). To release, see [publishing.md](publishing.md). The category names and field limits below come from memory of the site forms. Check them when you fill in the forms. If a name is different, choose the closest match.

## Fields

| Field | Value |
|---|---|
| Project name | Don't Do That |
| Slug / URL name | dont-do-that (use whatever is free) |
| Summary (one line, keep under 250 characters) | Save your gold for your mount. Marks trainer spells you can skip and asks "Buy anyway?" before you waste gold. For all nine classes, on WoW Forever and Classic Era. |
| Main category | Auction & Economy |
| Additional categories | Quests & Leveling, Miscellaneous |
| Game versions | CurseForge calls Classic Era **Classic**: tick Classic (1.15.x) and Forever (1.60.x). The packager reads `## Interface` from each TOC: 11509 for `DontDoThat_Vanilla.toc`, 16001 for `DontDoThat_Camelot.toc`. |
| License | MIT |
| Source code URL | `https://github.com/NullStatBonus/wow-dontdothat` |
| Issues URL | `https://github.com/NullStatBonus/wow-dontdothat/issues` |
| Relations | None. The Ace3 libraries are bundled. |
| Tags | gold, saving, mount, leveling, trainer, spells, talents, auction house, vendor, quality of life, classic, forever |
| Release type | Release (use Beta for pre-release tags) |
| Changelog | Taken from `CHANGELOG.md` by the packager; nothing to type. |
| Donations | none |

## Description

Paste this into the description box (CurseForge and Wago both take Markdown or HTML; use the Markdown editor if offered).

---

**Your trainer wants your gold. Your mount needs it more.**

Don't Do That is the leveling addon that keeps your gold for your **level 40** and **level 60** mounts. It works on WoW Forever and Classic Era, for all nine classes.

- **Skip spells you do not need yet.** A colored **(i)** shows in the trainer window. Hover over it to see why, and how much gold you keep.
  - Red: save your gold. You do not need this spell until later.
  - Gold: not worth buying yet.
  - Blue: optional.
- **Get a "Buy anyway?" before you waste gold.** The addon asks before you buy a spell you can skip. It tells you how long it takes to farm that gold again. You can always choose Yes.
- **Shop smart.** The addon also asks before you buy gear, bags, potions and more, at vendors and the auction house. It guards bank slots, stable slots, COD mail, talent resets and your first profession lesson too.
- **Hear it coming.** A loud sound and an on-screen banner tell you before you spend gold you do not need to spend yet.
- **Advice for your class and spec.** It follows the Wowhead leveling guides and the game's spell data.
- **See your savings grow.** The Progress page shows the gold you kept and how close you are to your mount.
- **A trainer filter.** Hide every spell that the addon marks as skippable.

It only asks. It never stops a purchase. It turns off when you buy your mount, and you can turn off each part before that.

**Start:** type `/ddt` to open the settings. Type `/ddt test` to see a sample warning.

**Problems?** Type `/ddt debug on`, repeat what went wrong, then type `/ddt export`. Copy the report and send it with your client (Classic Era or Forever).

Free and open source (MIT). The Ace3 libraries in the addon keep their own license.

---

## Screenshots to capture

1. A trainer window with red, gold and blue **(i)** marks and a tooltip open on one.
2. The "Buy anyway?" question with the earn-back time (`/ddt test`).
3. The warning banner after trying to buy a flagged item.
4. The Progress page with savings tallied.
5. The settings page under Options, AddOns.
6. The Recommended filter in the trainer's Filters menu.

Use 1920x1080 or larger, UI scale unchanged, with the chat frame showing nothing private.

## Before each release

1. Check the Game versions row still matches the `## Interface` values in both TOCs.
2. Skim the description against `README.md`; update both if the features changed.

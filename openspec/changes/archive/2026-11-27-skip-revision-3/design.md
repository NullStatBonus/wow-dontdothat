## Context

Revision 2 was decided by a computed review plus Wowhead's Classic guides. Forever guides now exist for most specs, with "Mandatory" and "Optional" training tables in several formats.

## Decisions

- **Statements, not a parser.** Each guide table is read once into a statement (spec, spell, operation) in `revision3.json`, with the page URL and the page's date. The formats differ too much to parse safely, and a reviewer can check each statement against its page.
- **Operations:** `all` (train every rank), `first` and `optfirst` (only rank 1; the second for spells the guide calls optional), `skip` (named ranks), `up`/`top` (up to a rank), `lv` (a list of levels to train at), `after` (nothing past a level).
- **Rules that combine statements with revision 2:**
  1. A Forever guide wins over a computed entry and over a Classic guide entry.
  2. Each spec follows its own guide, so one spell can differ between specs.
  3. A rank missing from a "key spells" table is not a statement. Method is used only for explicit sentences (Raptor Strike).
  4. A level list counts only when every listed level is a real rank level in Forever. Otherwise revision 2 stays.
  5. "Optional" skips ranks above the first, and rank 1 is never skipped.
  6. A statement read from an Optional table, with any operation, is held when the spell is in the spec's core rotation.
  7. Conditional advice about a core spell is held, not adopted.
  8. A statement decides only the ranks it speaks about; `skip` and a top-rank table leave the other ranks at revision 2.
  9. A spec or spell no guide covers keeps revision 2. Tables whose level lists mostly do not match (Arms Warrior) are not trusted for any row.
- **Review by a second model** found statements copied from another spec's page, a core-rotation guard that covered one operation, skips read from omissions in Method's table, and statements that replaced revision 2 for ranks they never named. These are fixed and tested.
- **Revisions 1 and 2 are frozen.** Rerunning the old pipeline changed seven revision 2 lines, because the rules data moved. The tool now reads them from the shipped file and adds revision 3.
- **Default.** The newest revision stays the default, so players who never chose move to revision 3. The existing once-per-profile notice announces it, and `/ddt revision 2` goes back.

## Risks

- The wording of some Wowhead tables is read by judgment (for example "Rank 1" in a Holy Paladin table). These are held as no statement, not as a cap.
- Nothing has been checked in the game. The offline tests check the data and the engine, not the guides.

## Non-Goals

- Specs the Forever guides do not cover (Balance Druid, and Mage, Hunter and Restoration Shaman ranks), computed skips with no expert support, and the guides behind a verification check (Icy Veins, Warcraft Tavern, Mobalytics): issue #83.

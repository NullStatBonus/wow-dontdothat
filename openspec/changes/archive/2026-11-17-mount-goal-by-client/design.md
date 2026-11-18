# Design

## Context

`Milestones.Defaults` holds one table (40: 100g riding; 60: 1,000g riding + 200g mount). `Options.MilestoneProgress` sums riding + mount. The addon has no client switch yet; the two TOCs (`DontDoThat_Vanilla.toc` for Classic Era, `DontDoThat_Camelot.toc` for Forever) load the same files.

## Evidence for the prices

- **Game data** (`tools/.cache/items/ItemSparse-*.csv`): Classic Era 1.15.9 sells level 40 racial mounts for 80g and level 60 epic mounts for 1,000g; Forever 1.60.1 sells the same items for 20g and 200g.
- **Classic Era training:** BlizzardWatch (June 2019) gives 20g riding + 80g mount = 100g, and a 20% discount saving "200 gold on the price of the best mount" (so a 1,000g base); Warcraft Wiki says riding before patch 1.12.1 was a single 20g skill.
- **Forever training:** Gamertag (Nov 14, 2026, citing Wowhead/Icy Veins/Method) and Finalboss (Nov 10, 2026) give Apprentice Riding 100g with the first mount included, Journeyman 1,000g, epic mounts 200g, and 10% off at Honored. No source documents a PvP discount on Forever, and Blizzard has not published the numbers.
- **Discounts:** BlizzardWatch and a 2019 Blizzard forum post both give 10% at Honored + 10% at PvP rank 3, adding to 20% on Classic.

## Goals / Non-Goals

**Goals:** correct per-client goals; automatic discounts; one goal function used by Progress and the purchase question.

**Non-Goals:** a player-editable goal (#33); discounts from other factions (only the home race's faction gives one on the mount vendor and riding trainer).

## Decisions

- **Client switch:** `Milestones.Client(env)` reads the interface number from `GetBuildInfo` (Era 11509, Forever 16001; below 16000 is Era). A per-TOC data file was rejected: `tools/check-tocs-match.sh` requires both TOCs to list the same files.
- **Discount reader** in `Adapter`: home faction by race (Stormwind, Ironforge, Darnassus, Gnomeregan Exiles, Orgrimmar, Thunder Bluff, Undercity, Darkspear Trolls), standing from `GetFactionInfoByID` (6 = Honored); PvP rank from `UnitPVPRank("player")` on Era (UNVERIFIED offset: rank 1 is 5, so rank 3 is 7). Both pcall-guarded; failure means no discount.
- **Discount data** lives with the defaults: `discounts = { honored = 0.10, pvpRank3 = 0.10 }` on Era, `{ honored = 0.10 }` on Forever.
- **`Milestones.Goal(profile)`** returns level, copper target and the discount applied; shared with `mount-fund-line`.

## Resolved: Classic Era has no epic riding lesson

Game data for Classic Era 1.15.9 (`tools/.cache`):
- `SkillLineAbility`: each racial riding skill line (Horse 148, Wolf 149, Tiger 150, Ram 152, Raptor 533, Mechanostrider 553, Undead Horsemanship 554, Kodo 713) teaches exactly one spell (for example Horse Riding 824). There is no second, epic rank to train.
- `ItemSparse`: every level 60 epic mount (Swift Palomino 18776, Swift Frostsaber 18766, Horn of the Swift Brown Wolf 18796, Swift Brown Ram 18786, Great White Kodo 18793, Green Skeletal Warhorse 13334, Swift Green Mechanostrider 18772, and others) costs 1,000g and needs riding skill rank 1 and level 60. Level 40 mounts cost 80g, also rank 1.
- BlizzardWatch (2019) gives 20g for the riding skill and 80g for the mount at level 40, and a 20% discount worth 200g on an epic mount (so a 1,000g base).

So on Era: level 40 goal 20g + 80g; level 60 goal 1,000g (mount only). The current level 60 check (racial riding skill max rank 150, `Adapter.lua:308`) can never fire on Era. Era level 60 detection must look for an epic mount item in the bags (item IDs from ItemSparse: level 60, a riding skill requirement, 1,000g).

## Risks / Trade-offs

- Forever prices come from third-party guides, not Blizzard; they are data and easy to change.

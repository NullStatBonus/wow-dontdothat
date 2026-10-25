# Don't Do That

A World of Warcraft Classic addon that warns you off gold you don't need to spend yet, so you can afford your **level 40** and **level 60** mounts. Works on **Classic Era** and **WoW Forever**, for all nine classes.

## What it does

- **Marks things to wait on.** In a trainer window, a colored **(i)** appears next to a spell you can skip. Hover it for the reason and the cost; click it to keep the message open.
  - Red: *Save your gold*. You won't need it until later.
  - Gold: *Not worth buying yet*. A low-value spell.
  - Blue: *Optional*. Handy now and then, but you can get by without it.
- **Asks before you buy** something in red: a warning sound and a "Buy anyway?" question. You can always say yes.
- **Knows your class and spec.** Each class has a list of spells worth buying and spells that can wait, built from common leveling builds and expert guides (Wowhead, Icy Veins). It follows your talents, or the spec you choose.
- **Skips low-value ranks** of spells you do want, again from the expert guides.
- **Adds a "Recommended" filter** to the trainer's filter menu that hides what you can wait on.
- **Shows your projected savings** on the Progress page: what you keep by following the advice up to the mount you're saving for. Each class page shows the same for level 40 and level 60 by spec, and every switch shows what it is worth in gold.
- **Warns on non-essential purchases.** Armor, weapons, vanity, bags, recipes and more get a "Buy anyway?" question at vendors, the auction house, or both, above a minimum price you set. It also asks before you buy a bank slot or a stable slot, pay for COD mail, learn a new profession, or reset talents or pet skills. Every question says roughly how long it takes to grind that gold back.
- **Warns about Warlock grimoires** you don't need, and knows Warlocks and Paladins get a free level 40 mount, though it still saves your gold.
- **Keeps a tally** of gold you've kept by waiting. It reads your spellbook against a bundled list of every spell your class can learn, so it works before you visit a trainer.

It stays on from level 1 until you've bought the mount you chose to stop at (level 40 or level 60). It only ever asks; you can always buy anything, and you can turn any part off.

## Install

Install it from CurseForge, WoWInterface or Wago with your addon manager, or by hand:

1. Copy the `DontDoThat` folder into your AddOns folder:
   - Classic Era: `World of Warcraft/_classic_era_/Interface/AddOns/`
   - WoW Forever: `World of Warcraft/_classic_beta_/Interface/AddOns/`
2. Start the game, or `/reload`. The right TOC file loads for each client.

## Using it

Type **`/ddt`** to open the settings (also under Options > AddOns).

| Page | What it has |
|---|---|
| Home | On/off, how firmly the addon nudges you (mark only, ask first, or ask about everything), and when to stop warning you |
| What to watch | Spells, professions, shopping and other purchases, each on or off, with the minimum price and the profession skill margin |
| Progress | The mounts you're saving for, your projected savings, and the tally of gold kept |
| Advanced | Sound and on-screen message, tuning, the class pages (every spell and why, with a switch for each), and debug tools |
| About | What the marks mean |

Commands: `/ddt` (settings), `/ddt version`, `/ddt test` (shows the warning and question for a pretend purchase, buys nothing), `/ddt debug on|off`, `/ddt probe`, `/ddt export`, `/ddt clear`.

## Known limits

- **Some game data is unverified.** Spell IDs, ranks and levels come from the game's own tables. Trainer prices for every class except Hunter come from Wowhead's Classic lists, and ranks Wowhead doesn't list use an estimate for the level. Prices your own trainers show take precedence. Many class rotations are marked for review in the data files.
- **Rank skips and tiers follow guides**, which can disagree. You can switch off any spell, kind of spell, or the skipped-rank rule.
- **Profession rules cover Herbalism and Skinning** so far.
- **Talent choices are not judged.** Only the cost of resetting is warned about.
- **Warning sounds:** the picker offers common game sounds, then every sound the game names, plus any registered with LibSharedMedia by other addons.

## Reporting a problem

Turn on **Advanced > Debug > Record what the addon sees**, do the thing that went wrong, then **Show the report**, copy it (Ctrl+A, Ctrl+C) and send it with a description and your client (Classic Era or Forever).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The tests run with LuaJIT: `luajit tests/run.lua [filter]`. Module shapes are in `docs/contracts.md`, rule data in `docs/rules-data.md`, and the in-game test plan in `docs/test-plan.md`.

## License

[MIT](LICENSE). The bundled Ace3 libraries keep their own license (`DontDoThat/Libs/LICENSE-Ace3.txt`).

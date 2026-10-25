# Proposal

## Why

Hunters reach the level 40 mount faster by skipping spell ranks and profession choices that add little while leveling. Today the addon already defers many Hunter spells, but it still lets three kinds of spending through unflagged: low-value Wing Clip and Freezing Trap rank upgrades, learning a crafting profession that will not pay back before level 40, and (in principle) recommending talent-only spells the player has not taken.

## What Changes

- Skip Wing Clip ranks 2 and 3 (rank 1 stays kept) and Freezing Trap ranks 2 and 3. Frost Trap has a single rank, so nothing changes there. This is rule data only.
- Warn once per profession, with a confirmation prompt, the first time the player trains a non-gathering profession. Skinning, Herbalism and Mining are exempt. The prompt wording is specific to the profession.
- Never treat a talent-only spell (Aimed Shot, Scatter Shot, Wyvern Sting, Intimidation, Bestial Wrath, Counterattack) as a "you'll use this" rotation spell while its talent is not active.
- Out of scope, decided during exploration: pet food, ammo rules, Aspect of the Cheetah, Mongoose Bite (already flagged for non-Survival players by spec inference), Raptor Strike skips, and the Arcane Shot / Serpent Sting rank 7 skips (unchanged).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `purchase-warnings`: adds a one-time, per-profession confirmation when the player trains a non-gathering profession.
- `rule-engine`: rotation membership no longer counts a talent-only spell as core or situational until its talent is active.

## Impact

- `DontDoThat/Rules/Data/Hunter.lua`: `skipRanks`, `talentSpells` data.
- `DontDoThat/Rules/Engine.lua`, `Rules/Schema.lua`: talent gating in rotation lookup; a profession-learn evaluation.
- `DontDoThat/Intercepts/Trainer.lua`, `Intercepts/Confirm.lua`, `Intercepts/Adapter.lua`: recognise the profession-learn row, prompt, and read talent ranks.
- `DontDoThat/Model/PlayerProfile.lua`, `Model/Settings.lua`: carry talent ranks; store which professions were already warned.
- `CLAUDE.md` release rule: new user-visible feature, so version 0.4.0 becomes 0.5.0 in both `.toc` files at archive.

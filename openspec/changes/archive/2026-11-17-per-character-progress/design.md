# Design

## Context

`AceDB:New("DontDoThatDB", ns.defaults, true)` makes every character use the shared "Default" profile (`Core/Addon.lua`). `milestoneOverride` and `professionAsked` live in `db.profile` and are read in `Intercepts/Context.lua`, written in `Options.lua` (checkboxes) and `Settings.MarkProfessionAsked`. `db.char` already exists (ledger, catalog).

## Goals / Non-Goals

**Goals:** per-character marks and profession answers; a migration that never silences an alt.

**Non-Goals:** per-character profiles for all settings; deleting the old shared values.

## Decisions

- **Storage:** `db.char.milestoneOverride` and `db.char.professionAsked`, default `{}`. Readers and writers switch to `db.char`.
- **Migration:** a `db.char.migratedMarks` flag. On first login without it, for each of 40 and 60 set in `db.profile.milestoneOverride`, copy the mark when `UnitLevel("player") >= level`; then set the flag. Runs once per character.
- **Why level-gated:** a character below 40 cannot have bought its level 40 mount, so a copied mark would be wrong. Above that level the mark is probably right, and if not the player can clear it.
- **Profession answers not copied:** the cost of being wrong is one extra question per character; copying would silence alts, which is the bug.
- **Reset all settings** keeps `db.char` values (they were already kept on reset).

## Risks / Trade-offs

- A level 45 alt that never bought its mount inherits a level 40 mark from the main. It can clear the checkbox; the README says so.

## Context

`Options/Options.lua` builds eight AceConfig groups, one per page, from pure functions (`Options.General`, `Alerts`, `Items`, `Rules`, `Milestones`, `Tally`, `Debug`, `About`) assembled by `Options.Pages()`. The Blizzard AddOns list gets one subpage per entry, and `/ddt` opens the same groups as a tree. Settings live in `ns.db.profile` and are read through `Model/Settings.lua`. "How firmly" is today decided by `warnings`, `blockingConfirmations`, `alerts`, `alert.banner` and `tuning.promptTiers`.

## Goals / Non-Goals

**Goals:** five pages organised by player intent; one nudge choice for the common case; deep controls kept but behind Advanced; plain labels; no saved-settings migration.

**Non-Goals:** new warning rules, a respec switch, changes to rule data, renaming saved keys.

## Decisions

1. **The nudge is derived, not stored.** `Settings.Nudge()` returns `mark`, `ask`, `everything` or `custom` from `warnings`, `blockingConfirmations` and the prompt tiers. Just mark things = marks on, question off (any tiers). Ask me first = marks on, question on, only the defer tier. Ask about everything = marks on, question on, all three tiers. Anything else is `custom`. `Settings.SetNudge(name)` writes those three values; `custom` writes nothing. Alternative rejected: storing the choice, which would make it disagree with Advanced edits.
2. **Sound is outside the nudge.** Muting the sound would otherwise flip Home to Custom for something unrelated to how firmly it asks. With the question off, a flagged purchase still gets the sound and banner, as today; Just mark things therefore means "never asks", not "silent".
3. **Three new area switches, none for Other.** `watch.spells`, `watch.professions` and `watch.shopping`, all on unless saved as false. Spells is checked where trainer rows for spells are evaluated, Professions where profession-tier and learn rows are, and Shopping in the vendor and auction item guards. Turning one off leaves the settings inside it as they were. Other has no master: its three existing `guard` switches are the control.
4. **Page structure.** `Options.Pages()` returns Home, What to watch, Progress, Advanced and About. Progress is the existing Milestones and Tally content as two sections of one page. Advanced is a tree-style group with Sound & messages, Tuning, Rules and Debug, so the Rules class tree stays untouched and nested one level down. Existing builders are reused where possible and reshaped to return sections.
5. **Collapsing.** "Choose categories" is an AceConfig inline group with a toggle, hidden until opened, so the 13 dropdowns do not show by default. The open state is not saved.
6. **Stop-after moves to Home; prompt tiers move to Advanced Tuning.** The rank window and profession margin stay in Tuning, and the Tuning reset no longer touches stop-after.
7. **Wording.** Labels drop "tiers" and "supersession" where they are visible; the three tiers keep their existing names ("Save your gold", "Not worth buying yet") since they are already player-facing.

## Risks / Trade-offs

- **Nested trees:** Advanced holds a tree and Rules is a tree inside it. The Blizzard options panel is small, so this may be cramped. Fallback: Advanced lists Sound & messages, Tuning and Debug, and a button opens the `/ddt` window at Rules.
- **Custom may be seen often:** any edit to the prompt tiers breaks the match. This is intended, and the Home line explains it, but check it feels right in play.
- **New switches add behavior:** the three area switches are small but real new behavior; each needs a test where it is read.
- **Spec page names:** the Rules and rule-engine specs still say "Rules page"; it now lives inside Advanced. Left alone, since the name of the section is unchanged.

## Migration Plan

No migration. Existing keys keep their meaning; `watch.*` is new and absent means on. Versions: 0.5.0 becomes 0.6.0 at archive.

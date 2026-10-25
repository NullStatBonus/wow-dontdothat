## Context

The rule engine decides per spell with `skipRanks`, `overrides`, spec rotations, tags, supersession, then keep (`Rules/Engine.lua`). Profession data files (`Rules/Data/Skinning.lua`, `Herbalism.lua`) only describe skill-tier rows (Journeyman, Expert, Artisan); a profession with no data file produces no verdict at all. Hunter.lua says Wing Clip and Freezing Trap ranks are "deliberately not skipped". Player state comes from `PlayerProfile.Build`, which carries tree points, not individual talents.

## Goals / Non-Goals

**Goals:** skip Wing Clip 2-3 and Freezing Trap 2-3; warn once per non-gathering profession; keep talent-only spells out of "rotation" verdicts while the talent is inactive.

**Non-Goals:** pet food, ammo, Cheetah, Mongoose Bite, Raptor Strike skips, Arcane/Serpent rank 7 skips; no new settings screen.

## Decisions

1. **Rank skips are data only.** Add `["Wing Clip"] = { 2, 3 }` and `["Freezing Trap"] = { 2, 3 }` to `skipRanks`, and update the Hunter.lua comment that says they are deliberately not skipped. Wing Clip keeps its `keep` override, which only applies to rank 1 because `skipRanks` is evaluated first. Alternative rejected: a level cutoff rule (e.g. skip ranks unlocking after 20); it was suggested for Raptor Strike but the player chose to keep explicit per-rank lists.
2. **Profession-learn is a separate evaluation kind, not a tier row.** The engine gains `professionLearn` actions. A profession counts as non-gathering when its name is not in a small `gathering` set (Skinning, Herbalism, Mining) held in rule data. Reasons come from a per-profession table with a generic fallback sentence, so unknown professions still get a sensible reason. Verdict tier is `defer` so the existing prompt, badge and filter machinery applies.
3. **"Once per profession" lives in saved settings.** A `professionAsked` table keyed by profession name in the profile. It is written only when a question is actually shown and answered. If prompts are off, or the fallback badge is used, nothing is recorded, so the question is not lost.
4. **Recognising the row.** The trainer row naming for the first tier of a profession is unverified (the existing `MatchProfessionTier` says the same about tier rows). The adapter will match the first-tier row of the profession trainer and fall back to doing nothing on an unrecognised row. Verify with the debug capture tools on a real Classic Era trainer before relying on it.
5. **Talent gating via a `talentSpells` map.** Hunter.lua lists the talent-only spells; each spell's talent has the same name as the spell. The adapter reads talent ranks by name (talent API) into the profile as `activeTalents`. In `evaluateSpell`, rotation membership is ignored for a spell in `talentSpells` unless its talent is active. Alternative rejected: infer from tree points; points in a tree do not prove a specific talent is taken.

## Risks / Trade-offs

- Practical effect of decision 5 is small: the trainer only offers talent-spell ranks after the talent is learned, and rotation lists are not shown elsewhere in the UI. It is kept as a correctness rule for the engine; if it adds more code than it is worth, it can be dropped without affecting the rest.
- Wing Clip rank 2 unlocks at level 38 and Freezing Trap rank 2 at level 40, so these skips matter only for players still saving for the mount at those levels.
- Unverified assumptions: trainer row naming for first-tier profession rows, and talent-name lookup on Forever clients. Both are covered by the fallback of doing nothing.
- Fishing, Cooking and First Aid fall in "non-gathering" by the rule as stated and would be asked about. Treat this as open: add them to the exempt set if the prompt feels wrong in play.

## Migration Plan

New saved key `professionAsked` is optional and defaults to empty, so existing saved settings keep working. No version break; version bumps to 0.5.0 at archive.

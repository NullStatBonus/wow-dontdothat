# Design

## Context

`Popup.Ask(verdict, …)` (`UI/ConfirmPopup.lua`) builds the question as head, reason, earn-back line and "Buy anyway?". `Options.MilestoneProgress` already reads the current milestone, its target (riding + mount from `Milestones.For(class)`) and `GetMoney()`.

## Goals / Non-Goals

**Goals:** one extra line using the same target the Progress page shows.

**Non-Goals:** a setting to turn the line off (add one only if players ask); COD mail and resets (they annotate the game's dialog, not our question); the profession question (it shows no price by design).

## Decisions

- **One wording for both short cases.** "After this you'll have X of the Y for your level N mount." reads correctly whether the player was already short or the purchase takes them below the target.
- **Shared goal helper.** Move the target lookup out of `Options.MilestoneProgress` into a small `Milestones.Target(env)` (current level, copper target and discount, or nil; it calls the existing `Milestones.Goal`) and use it in both places, so the question and Progress can't disagree.
- **Profile source.** `Popup.Ask` gets the profile from `ns.Context.Profile(_G)` inside a pcall; any failure drops the line, never the question.
- **Money format** reuses the helper the Progress page uses.

## Risks / Trade-offs

- One more line in the question. It is shown only when it matters (short after buying).

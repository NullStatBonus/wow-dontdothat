# Design

## Context

Settings are AceConfig tables built by pure functions in `Options/Options.lua`, which keeps them testable without the game. Each page picks its own font size, spacing (blank `description` rows) and gray. The Rules page is read-only and only lists abilities that carry a tag or override.

The engine (`Rules/Engine.lua`) is pure: it takes a `profile` table from `PlayerProfile.Build` and an action. It resolves rules in a fixed order (rank skip, override, rotation, tag, off-spec, supersession) plus a separate recipe-tier path. Thresholds live in rule data (`supersessionWindow`, `nearCapMargin`). Only `tier == "defer"` prompts and sounds (`Confirm.Decide`, `Alert.Trigger`). Milestone state ends only at the level 60 mount.

## Goals / Non-Goals

**Goals:**
- Consistent look across all pages without leaving AceConfig.
- Player control over which rules apply and a few thresholds, flowing through one place (the engine profile) so badges, tooltips, filter, prompts, Ledger and Tally agree.
- Zero behavior change at defaults.

**Non-Goals:**
- Custom-frame UI, gold-per-hour, mount costs, a separate hidden-tier control for the Recommended filter, forcing warnings on kept abilities.

## Decisions

**Page template.** Add small builders in `Options.lua` (`pageTitle`, `section`, `row`, `note`) with one type scale (title large, body medium, notes medium gray `9d9d9d`) and use them on every page. Blank spacer rows go away; sections are separated by headers. Alternative considered: custom frames in a Settings canvas. Rejected: several times the code, loses pure-table tests, and Classic Era support for the canvas API is unverified.

**Settings reach the engine through the profile.** `Context.Profile` passes the relevant saved settings into `PlayerProfile.Build`, which copies them to `profile.rules = { offAbilities, offTags, offKinds, supersessionWindow, nearCapMargin }`. The engine reads only `profile`, so it stays pure and tests need no database. Alternative: the engine reads `ns.db` directly. Rejected: breaks purity and every existing engine test.

**Storage.** New profile keys, all optional with defaults in `ns.defaults.profile` so existing saves stay valid:

```
ruleOff = {                      -- present key = switched off
  abilities = { HUNTER = { ["Arcane Shot"] = true } },
  tags      = { HUNTER = { PvP = true } },
  kinds     = { skipRank = true, supersession = true, offSpec = true, professionCap = true },
}
specOverride = { HUNTER = "MM" }  -- absent = Automatic
tuning = { supersessionWindow = 4, nearCapMargin = 25, stopAfter = 60,
           promptTiers = { defer = true } }
alert.channel = "Master"
```

Storing only what is switched off means a new rule added in a later release is on by default.

**Disabled ability is a full bypass.** The check runs first in `evaluateSpell`, returning keep with source `disabled`. Chosen over fall-through because "unticked means never flagged" is the mental model. Tag and rule-kind switches do fall through, because they remove one reason, not the ability. The recipe-tier path honors `professionCap`.

**Tag off.** The tag loop skips an off tag, so a second tag on the same ability can still decide. The Rules page's ability list is built from the same switches so it shows the tags that apply.

**Tuning values.** `supersessionWindow` and `nearCapMargin` override the rule data value when they are whole numbers >= 0 (a small `validNumber` check), else the data value is used. `Rules.SupersessionWindow` stays as the data fallback.

**Prompt tiers.** Replace the two hard-coded `tier == "defer"` tests with `ns.Settings.PromptsFor(tier)`, reading `tuning.promptTiers` with default `{ defer = true }`. `keep` never prompts regardless of settings. The Recommended filter's hidden tiers are unchanged.

**Stop after.** `Milestones.State` gets a fourth argument `stopAfter`. If it is 40 and the level 40 mount is done (learned, or manual override), state is finished. Changing it back resumes immediately, since state is recomputed on each read, not stored.

**Spec override.** `Context.Profile` sets `plausibleSpecs = { pick }` when `specOverride[class]` is a key of `classData.specs`, else infers. The Rules page builds the dropdown from `classData.specs` names, so new classes need no UI code.

**Alert channel.** `alert.channel` already exists in defaults and is passed to the sound call. The Alerts page adds a select over the game's five channels. Unknown values fall back to Master at play time.

## Risks / Trade-offs

- Switching off a whole rule kind or tag can hide many warnings at once. Mitigation: a visible count beside each switch group, and a per-class reset on the Rules page.
- The Ledger records savings through the engine, so existing recorded verdicts are not rewritten when a rule is switched off; only future evaluation changes. Acceptable and documented on the Tally page note.
- Without the in-game client, layout changes are checked only by building the option tables in tests; the final look needs a manual in-game pass.
- The AceConfig tree has no real card or panel primitive, so "modern" is limited to consistency, icons and color accents.

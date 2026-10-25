# Design

## Context

Greenfield addon for WoW Forever, which the Warcraft Wiki documents as part of the Mainline code family, Interface `16001`, with Midnight's addon restrictions ("secrets") also active. Several API facts cannot be confirmed from the web and are resolved by an in-game probe (see proposal.md - Impact). Source data on Forever (costs, ranks, rotations) comes from fan sites reporting on a beta capped at level 30, so all game data must be editable and flagged where unverified.

## Goals / Non-Goals

**Goals:**
- Self-contained modules with one-directional dependencies, so rules are testable outside the game.
- Treat client APIs as an unstable edge, isolated behind adapters.
- All game numbers (costs, ranks, rotations, sounds, mount prices) live in data files.

**Non-Goals:**
- A Classic client adapter in v1.
- Per-rule user editing in v1.
- Parsing community guides at runtime.

## Decisions

### Module layout and dependency direction

```
 Core/        Addon (AceAddon), DB (AceDB), Slash (AceConsole), Events
 Model/       PlayerProfile, SpecInference, Milestones, Ledger
 Rules/       Engine.lua + Data/{Hunter,Herbalism,Skinning,Tags,Costs}.lua   <- pure Lua
 Intercepts/  Trainer, TrainerFilter, Talents, Respec, BeastTraining (+ Adapter)
 UI/          Badge, InfoBubble, TooltipAugment, ConfirmPopup, AlertBanner
 Options/     General, Alerts, Rules, Milestones, Tally, Debug, About
 Data/        Sounds.lua
 Debug/       Log, Probe, Export
```

Dependencies point inward: UI and Intercepts depend on Model and Rules, and Rules depend on nothing. `Rules/Engine` takes `(profile, action)` and returns a verdict with no frames and no WoW calls.

*Alternative:* one large file or event-driven everything. Rejected because it makes rules untestable and hides client-specific code.

### Bundled Ace3 subset, no more

Use LibStub, CallbackHandler, AceAddon, AceDB, AceHook, AceEvent, AceConsole, and AceConfig (with AceConfigDialog and AceGUI). Skip AceLocale, AceTimer, AceComm, AceSerializer, and AceBucket since nothing in v1 needs them. AceConfig is the heaviest choice, but it gives a consistent Options > AddOns subpage structure without depending on client-specific Settings API details. AceHook gives tracked, removable hooks for Intercepts.

*Alternative:* the native Settings API directly. Rejected for added client-specific code in v1. Libraries are bundled in `Libs/` loaded through one `embeds.xml`, with `.pkgmeta` externals for packaging.

### Client adapter boundary for Intercepts

All calls to trainer, talent, and respec APIs go through `Intercepts/Adapter`, which presents a stable internal interface (list services, get cost, get rank, read talent points, learn). Surface modules never call client APIs directly. The probe determines which adapter implementation applies.

*Alternative:* call APIs from each surface. Rejected because the API family is not confirmed and would be copied everywhere.

### Verdicts are computed, not stored

The engine evaluates on demand with precedence: override, rotation membership, tags, supersession, keep. Authors write rotations (core and situational lists per spec) and tags, and tiers derive from them. Explicit rank skips are checked first, so a spell that is kept as a whole can still have individual low-value ranks deferred. Explicit overrides exist for judgment calls (for example Keep for traps, Deterrence, Disengage, Aspect of the Pack, Serpent Sting, Hunter's Mark).

*Alternative:* a hand-authored tier per spell. Rejected because it cannot express spec dependence, and does not scale to hundreds of recipes.

### Deferral is continuous until the level 60 mount

Warnings are active from level 1 and stay active after the level 40 mount; only buying the level 60 mount finishes them. The milestones drive savings progress and the "saving for" message, not whether warnings apply. The goal is the most gold saved, so an earlier design that paused warnings between the mounts and resumed them at a placeholder level was dropped.

*Alternative:* pause after the level 40 mount until a configured level. Rejected because it lets gold leak on endgame-only spells between the two mounts.

### Spec inference is conservative with hysteresis

Plausible specs are derived from points per tree. A tree must lead by a configured margin to narrow the set. With no clear leader, every spec is plausible, so an ability is flagged only if no plausible spec uses it. With dual specialization the union is used.

*Alternative:* assume the recommended leveling spec (Beast Mastery for Hunter) when ambiguous. Rejected for risk of false warnings. This default can be revisited by changing one setting.

### Savings are derived from state, with explicit counters only where state is blind

Savings = available-and-unlearned flagged services at their known cost, split into verified (a higher rank of the same spell is learned) and projected. Respecs leave no state trace, so they use explicit counters and an editable escalating-cost table. Costs come from a trainer-cost cache populated when trainers are viewed, falling back to data estimates marked as estimates.

*Alternative:* event-based counting of dismissed prompts. Rejected because it can be gamed and cannot tell whether the purchase happened elsewhere.

### Spells identified by spell ID, with name+rank as a bootstrap fallback

Spell names are locale-dependent. Rule data still keys by name and rank, but the spell IDs are now bundled: `Data/SpellData.lua` is generated by `tools/build-spell-data.py` from the game's own database tables (as published by wago.tools for the WoW Forever build), with prices taken from a trainer report. The IDs give two things without any trainer visit: spell icons (the game returns an icon for any ID) and "have I learned this?" (a direct spellbook check, so the tally no longer depends on inferring purchases from vanished trainer rows). Some spells exist under two IDs; the first is primary, and a spell counts as known if any of its IDs is.

### Alerts fire on attempts, not hover

Hover shows a badge and tooltip only. The sound and banner fire on a click or when a prompt opens, with a per-action cooldown. Sounds are a data table, so IDs can be filled in after launch. Playback uses a channel audible when effects are muted, with a fallback sound.

### Pet spending has two stages, only one is gold

A Hunter first learns a pet ability (bought from a Pet Trainer for gold, or learned by taming a beast that knows it), and then spends training points to teach it to the pet in the Beast Training window. Only the first stage and the Pet Trainer's untrain fee cost gold, so pet abilities are handled as ordinary trainer rows by the rules engine, and untraining is tracked like a respec with its own counters and editable cost table. Training points are out of scope because they are not gold. All of this is confirmed for Classic only; Forever's prices and ability list are unverified and are collected by the debug export.

### Recommended trainer filter

A "Recommended" entry is added to the trainer's existing filter list, checked by default, and hides rows whose verdict is defer or defer-low-value (supersession produces defer, so superseded ranks are hidden too). A pure visibility function takes the adapter's full service list plus verdicts and returns the visible service indexes and a hidden count; the UI layer lays out rows from that. Rows keep their original service indexes, and the click path is verified so a visible row can only send the index of the service it displays. The ledger reads the full list, so hidden rows still count toward savings. The window gets no extra text of its own, since any line added to Blizzard's trainer frame collided with its controls. v1 covers class and profession trainers only. If the filter cannot be installed safely, it degrades to badge and tooltip and hides nothing.

*Alternative:* a separate companion list window of recommended spells. Rejected because it adds a new UX paradigm beside the one players already use.

### Debug tooling is part of v1

The probe doubles as the spike that resolves the open API questions. The export opens a standard copyable text window and the log is persisted via SavedVariables, since addons cannot write files or access the clipboard. Every probed call is wrapped in `pcall`.

## Risks / Trade-offs

- [Trainer or talent actions cannot be intercepted under the addon restrictions] → Badge and tooltip are the baseline and the prompt is an upgrade; surfaces degrade gracefully.
- [Interface number or API names differ from fan-site reports] → Interface is set in one place; the probe checks function availability before any adapter is relied on.
- [Game data is from a level-30 beta] → All costs, ranks, and prices are editable data and flagged; the export collects real values.
- [Spell ranks cannot be bought out of order] → The probe records this; the supersession and verified-savings logic is disabled for a spell if observed otherwise.
- [Marksmanship and Survival rotations are thinly sourced] → Flagged "needs review" and conservative handling keeps false warnings low.
- [Judgment calls will not please everyone] → Rules are visible on the Rules page with reasons; per-rule disabling is deferred to a later change.
- [AceConfig adds weight] → Accepted for consistent behavior; libraries bundled and only the used subset included.
- [Restricted-value ("secrets") behavior may affect reads] → Reads are wrapped and failures logged, never crashing the interface.
- [The game has no native custom trainer filter, so hiding rows means re-laying-out the list ourselves] → Keep the logic in a pure visibility function and keep the frame code thin and guarded.
- [Row positions map to purchase service indexes, so a layout mistake could buy the wrong spell] → Rows keep their original indexes, and an automated check in the debug build confirms each clickable row's index matches the service it displays.
- [Adding an entry to a Blizzard dropdown can cause taint] → Install guarded, fall back to badge and tooltip on any failure, and verify the default filters still work.
- [Forever's trainer UI may be categorized and differ from Classic] → Build against the probe's findings for Forever, and treat the Classic implementation as unproven there.

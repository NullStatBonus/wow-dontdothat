## Context and approval

The shared design A–E was approved on 2026-11-15, DDT was deferred, and DDT design resumed on 2026-11-16. Latest requests: the root settings entry must contain real top-level controls, `/ddt log` is primary with export retained, and feedback from the implemented siblings must be evaluated explicitly. This is a planning-only change. No runtime edits, canonical sync, archive, version bump, commit or release are authorized by preparing these artifacts.

The DDT checkout was clean and had no active changes at preparation. Canonical specs are its baseline. Both siblings have archived their cohesive changes and added follow-ups; use their current implementation and the feedback provenance below rather than the original three-addon sketch.

## Goals / Non-goals

Match the corrected siblings’ hierarchy, settings dimensions, explanations, report window, useful root registration, command vocabulary and Move layering. Retain DDT’s rule engine, actual revision-specific reasons, nudge derivation, class controls, totals, estimates, once-only flags, guards and purchase callbacks.

No new suite library, AceDB migration beyond the one-time warning-style marker, profile unification, runtime dependency on a sibling, cross-addon hooks, CV routing tour, new rule search feature, savings algorithm change, or implementation in this pass. CV-only notification sound/routing changes are not DDT gameplay requirements.

## Settings and navigation

Six landmarks, in order: Home, What to watch, Progress, Appearance, Advanced, About. Appearance has Warnings, Explanations and Sound tabs. Classes stays under Advanced; don’t add more top-level pages just to imitate another addon’s domain content.

The game’s root DDT entry renders Home itself. The current `Options.Register` parent description is the concrete replacement point: register the same Home builder under the root, not a copy of the full root tree and not the old “Pick a page” placeholder. `/ddt`, `/dontdothat` and `settings` explicitly select Home after Open, even after closing elsewhere. Child game-options entries show their corresponding page and current values. Rebuild must refresh the root Home registration as well as child tables. Use a stable app key, register categories once and avoid duplicate callbacks on reopen.

Keep large Classes/rule trees in the standalone dialog. Game-options Advanced exposes a contextual Open classes action, closing game Settings through guarded existing client patterns before opening the standalone Advanced > Classes path. KeepThat measured a roughly 77-second game freeze with a full materials tree embedded; do not reproduce that risk with DDT’s much larger class lists. On ordinary standalone open, classes start collapsed; targeted navigation expands only the requested path. Preserve revision changes and their refresh behavior.

Default window: 600×460 UI units, resizable, matching current siblings. Use compact standard control widths (1.5 units where labels fit), full-width descriptions and checkbox labels, readable section gaps, and no clipped long choices. Don’t copy the discarded CV 900×700 layout or blanket full-width dropdowns. Intro order is nonnegative and precedes control orders; negative orders sort last in Ace. Every page and Appearance tab states its purpose before consequential choices. Titles are only “Don’t Do That”; Advanced explains active profile, shared defaults, per-character savings and account-wide diagnostics. Scope is not repeated in every page title.

## Presentation and data flow

Introduce a small local presentation module/token table and injected synthetic drawing dependencies where useful. Keep model logic plain Lua and avoid replacing the existing AceAddon, event, interception or saved-data architecture. Inspect current bundled Ace controls and sibling implementations as read-only source references before adding controls. Retain licensing/version provenance for existing libraries; no wholesale library upgrade is required by design.

Use one existing verdict-to-content path for live tooltip, Toast, Warning, chat record, pinned explanation and question. Preserve exact tier and revision meaning, estimates and earn-back wording; don’t invent missing data as zero. Presentation routes choose Toast or Warning; they never decide what should be bought. A real question suppresses either alert visual for the same attempt; when a question is wanted but cannot be shown, the selected visual appears instead. After the enable, tier and cooldown gates pass, one chat line (item/action, cost, reason) prints for every real attempt, independent of the alerts toggle and of whether a question or visual shows, under its own `alert.chat` setting (default on for everyone). Samples never print it. Sound/cooldown remain one existing route rather than replaying once per visual component.

Toast uses a 320-unit starting width and content-driven height, small semantic cue, neutral title, recommendation, cost, reason and optional earn-back line; scale and dimming are independent. Larger reasons require more than KT’s two-line 40-unit toast, so don’t force them into that geometry. Warning keeps the existing prominent four-second banner role. Toast inherits that lifecycle rather than introducing new cooldowns. Pinned explanations keep a normal dismiss control, can grow for long text and have separate dimming/scale. Native tooltip and confirmation chrome remain native; do not dim the game’s tooltips globally.

Fresh profiles start Toast. Previously persisted profiles without valid style become Warning once, even if message or alerts were disabled. Detect preexisting raw SavedVariables before AceDB default injection; a missing key after defaults is insufficient to tell new from existing. Store a per-profile marker whose value never equals a default (AceDB strips default-valued keys, `AceDB-3.0.lua:173`), add it to `KEEP_ON_RESET` in `Model/Settings.lua`, and preserve valid choices. Profile switches must not reset another profile’s presentation. Reset all settings uses fresh defaults (Toast), keeps the marker so a relog does not reclassify the profile as Warning, retains the tally and once-only state, and turns debug recording off per existing rules.

## Commands and report

Use one public registry mapping stable external keys to typed model setters and refresh callbacks, not raw Lua paths. Nudge remains derived: set mark/ask/everything invokes `Settings.SetNudge`; get may return custom and its detail. Preserve existing min price, tier, class, rule and filter controls without inventing public setters for unsafe nested tables. Normalize command words and enums only. Invalid/surplus input never partially mutates.

`log` is the primary report verb everywhere player-facing; `export` is a full alias to the same builder/window. Keep existing `clear` as its immediate diagnostic-log-only compatibility command. New `log clear` confirms first. Neither touches ledger, observations, presets or rule settings. Login still clears debug/trace enabled flags; sibling debug persistence is not imported into DDT. Match the standard AceGUI Frame/MultiLineEditBox report, read-only selected text, copy instructions, close/reopen and a new chat fallback that prints the full report in chunks when the window cannot be created (today `Debug/Export.lua:186` only prints an error). The report builder may keep recording rank observations through `Probe.Run`; "no writes" means no settings, savings or gameplay data change. Status topics: nudge, warnings, explanations, sound (bare status summarises all four). Help topics: appearance, rules, diagnostics.

## Demo, preview and Move lifecycle

DDT’s demo is broad but synthetic: buying, training, respec, mail and auction are never safe tour actions. Do not copy CV’s later production routing demo. Draw realistic verdict samples through real render helpers with inert acceptance callbacks and separate sample dialog IDs. Clearly identify samples, show one fixed set per demo run (informational, defer-low-value, defer, skipped rank, estimated-price/earn-back), and preview the currently configured alert sound once. Samples may ignore disabled visuals without altering settings. A real action/guard always wins; old timeout callbacks cannot hide real prompts or change their one-shot callbacks.

Use a generation/session token for sample replacement and cleanup. Real alerts replace sample notices, real questions dismiss sample prompts, and terminating samples restores live display state without consuming real cooldowns or one-time flags. Existing `/ddt test` stays the current focused integration check and is not silently renamed to demo.

Move only changes the toast anchor. A transient warning needs no lock; the later CV feedback removed its toast lock for this reason. Snapshot position, show a placeholder and Done/Cancel above Ace settings, commit on Done, roll back on Cancel/Escape or profile/visibility loss, restore normal strata/input on completion. Escape registration is temporary to the Move session and must not disable normal game Escape or real question cancellation. Reset position is a deliberate exception to DDT’s old “no other reset” requirement and changes no other value. Pinned explanations remain anchored to their owning indicator, so they do not receive a meaningless persistent Move control.

## Reconciliation of canonical requirements

- addon-settings Options category, Advanced and layout: replace five-page navigation and the blank parent; relocate presentation/sound without losing controls. Home keeps enable/nudge/stop choice and gains the existing message enable flag.
- addon-settings Reset all settings: explicitly allow position-only reset but no additional feature/full reset.
- warning-alerts On-screen banner and related requirements: replace banner-only wording with selected presentation while retaining question suppression, attempt-only alerts, tier/sound/channel/cooldown behavior.
- purchase-warnings Information bubble: add readable black pinned surface, wrapping and dismiss/escape while retaining hover/pin semantics.
- debug-tools Copyable export: replace primary naming with log plus alias; preserve full report contents and login debug-off behavior.

## Implementation and review gates

Read feedback.md and coverage.md before applying tasks. Use the actual Ace registry for option-table validation and the current harness for migration, public validation, event isolation, generation tokens, one-shot callbacks, Move rollback and report lifecycle. Verify both supported clients in game: root Home content, all game-options pages, standalone Classes launch, class tree performance, long/localized labels, default/resized windows, actual font rendering, alpha 0/80/100, scale 100/150, Move above settings, Escape, color/disabled controls and live attempts during samples. Capture matching-scale comparisons with current siblings; don’t claim browser or stub tests prove client behavior.

Only after implementation and checks should normal sync/archive/version/CHANGELOG workflow update canonical specs. Keep unverified manual tasks unchecked. Never archive just because proposal/design validation passes.

# Sibling feedback carried into DDT

Reference snapshot: 2026-11-16. Evidence comes from local source, canonical specs, archived changes and CV’s implementation.md. These are recorded user corrections, not assumptions that every intermediate implementation choice is still desired. Latest current behavior takes precedence over superseded notes. No sibling files are edited.

| ID | Feedback/evidence | DDT disposition and acceptance destination |
| --- | --- | --- |
| F01 | Latest user: DDT root settings is blank | Incorporated: Useful root settings entry; actual Home controls on the parent and explicit Home selection on bare commands |
| F02 | CV addon-list-pages archive, 2026-11-16: child pages missing from game options | Incorporated: Registration and large-tree isolation; root plus children in order, no duplicate registrations |
| F03 | KT settings-panel-launcher archive: roughly 77-second freeze leaving embedded large Materials tree | Incorporated preventively: Classes stays standalone; contextual game-options launcher; test full rule-tree switching performance |
| F04 | KT professions stayed expanded on reopen | Incorporated by analogy: standalone class tree collapses on ordinary open; targeted navigation expands only its path |
| F05 | CV screenshot review: 900×700 too big versus KT 600×460 | Incorporated: Corrected settings layout, 600×460 and resize/scroll checks |
| F06 | CV report/control-width corrections: long stretched controls, clipped choices | Incorporated: compact appropriate widths, full text/checkbox rows, long labels wrap; no blanket full-width sliders/dropdowns |
| F07 | CV intro appeared after controls because negative Ace order sorts last | Incorporated: nonnegative intro-first order, validated against bundled Ace registry |
| F08 | CV context-first review: insufficient visible guidance and consequence explanation | Incorporated: purpose and consequences before choices on every page/tab; no hover needed |
| F09 | CV title amendment: remove repeated scope suffixes | Incorporated: plain DDT title, scope explained in Advanced and where relevant |
| F10 | CV About did not match KT hierarchy | Incorporated: name, muted version, purpose, separate command-purpose rows |
| F11 | CV diagnostic window differed from KT | Incorporated: standard AceGUI Frame/MultiLineEditBox, selected read-only text, copy hint, close/reopen, fallback |
| F12 | CV Move placeholder was behind Ace settings | Incorporated: Move overlay/Done/Cancel above settings; restore strata afterward |
| F13 | CV unwanted toast locks blocked Move | Incorporated: transient Toast has no lock; Move-only positioning and position-only reset |
| F14 | CV defaults overwrote old presentation on upgrade | Incorporated: raw saved-data detection before AceDB defaults, Toast fresh/Warning existing, marker kept on reset, idempotent migration |
| F15 | CV overlapping samples/live notifications and stale demo timers | Incorporated: live wins, one selected visual, sample tokens and inert old timers, real guard never dismissed by sample cleanup |
| F16 | CV later unified style and one notification sound | Adapted: all DDT alert visuals obey one chosen style and one existing sound/channel route; preserve DDT tier/toggle/question-suppression rules, do not import CV routing sounds or conditions |
| F17 | CV preview/demo audio feedback | Adapted: at most one configured sound per sample presentation/broad demo, no volume edits or real cooldown consumption |
| F18 | CV later changed demo to real waypoint tour | Not applicable to purchase safety: DDT uses realistic drawing with inert actions; no real purchase/reset/auction tour |
| F19 | KT find with several matches should open filtered Materials | Domain-specific, not copied: DDT has no equivalent find feature; retain existing revision/class navigation and no surprise new search scope |
| F20 | Both addons added IconTexture and shipped a badge | Incorporated: AddOns list identity and two-TOC/package verification; artwork remains an implementation asset task |
| F21 | KT realistic native item previews and uncached data behavior | Adapted: real render helpers with clearly synthetic verdicts; preserve native tooltip chrome, missing names/icons/costs handled safely |
| F22 | User: log should replace export as primary report command | Incorporated: Log primary command and aliases; identical report builder/window, docs prefer log |
| F23 | Sibling data scopes and debug persistence differ | Retained DDT-specific behavior: shared profile settings, character savings, global diagnostics; debug/trace off every login; no profile unification |
| F24 | CV canonical settings text and late implementation notes disagree on some tab labels | Reconciled explicitly for DDT: Warnings, Explanations, Sound; one sound selector on Sound, no duplicate controls or copied intermediate tab list |

Source anchors:
- `../wow-closest-vendor/openspec/changes/archive/2026-11-15-cohesive-addon-presentation/implementation.md` (chronological corrections; final amendments supersede earlier ones).
- CV current `openspec/specs/{settings-interaction,notification-presentation,visual-preview,slash-interface}/spec.md` and `ClosestVendor/Options.lua`.
- CV archives `2026-11-16-addon-list-pages` and `2026-11-16-addon-list-icon`.
- KT archives `2026-11-15-settings-panel-launcher`, `2026-11-15-find-opens-filtered`, `2026-11-16-addon-list-icon`; current settings/slash/preview specs and Options/Debug source.
- Latest user requests in this conversation: root top-level settings, sibling feedback audit, log primary/export compatibility.

This audit covers feedback visible in these local repositories and this conversation. Any additional feedback outside these sources should be evaluated into the same table before implementation closes.

## Implementation evidence (2026-11-16)

Tests named are in `tests/`; "game" means a check in docs/test-plan.md is still open.

| ID | Evidence |
| --- | --- |
| F01 | options_layout "root game-options entry is Home itself"; game |
| F02 | options_layout "registering again adds no categories" |
| F03 | options_layout "classes launcher, not the class tree"; no page-switch lag in game |
| F04 | options_layout "opening selects Home explicitly, collapses the classes" |
| F05 | options_layout root size 600×460; resize checked in game |
| F06 | options_layout "controls use compact widths"; widths checked in game |
| F07 | options_layout "every page and tab states its purpose first"; options_ace real-registry validation |
| F08 | Same intro test; readable in game |
| F09 | options_layout "six landmarks" (scope text) |
| F10 | options_layout "about lists each command" |
| F11 | export "Show opens one window…", "closes on Escape", "falls back to chat" |
| F12 | toast "Move raises the placeholder above settings"; game |
| F13 | No lock setting; Move always offered (options_layout warnings tab) |
| F14 | warning_style ×5 against real AceDB (fresh, old, untouched old, reset → relog, idempotent) |
| F15 | demo "a real question ends the samples…", "a new run makes the old timers inert" |
| F16 | alert "ShowVisual: warning style uses the large banner…" |
| F17 | demo "plays the configured sound once…" |
| F18 | demo "the sample question is its own dialog…" |
| F19 | Not applicable |
| F20 | badge "both TOCs name the shipped icon", "square 32-bit TGA with alpha"; shows in the AddOns list in game |
| F21 | demo "every sample matches the price list, the skip list and the rule engine" |
| F22 | slash "log and export are the same…"; README, CONTRIBUTING, docs/localization use `/ddt log` |
| F23 | settings "debug recording is switched off whenever the addon loads" |
| F24 | options "sound tab…", options_layout "six landmarks" (tabs) |

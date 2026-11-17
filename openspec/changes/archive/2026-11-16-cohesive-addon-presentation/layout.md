# DDT screen and state reference

This is a content/layout reference, not a fabricated in-game screenshot. It uses the current siblings’ standard Ace controls. The previous browser mockup is historical; these repository-owned requirements supersede its older root, scope, lock and command details.

| Surface | Visible hierarchy | Interaction |
| --- | --- | --- |
| Game-options root DDT | Home intro → Enable → nudge options with explanations → stop-after mount → on-screen message → confirmed Reset all settings | Real controls immediately; no blank parent or launcher |
| Standalone | Don’t Do That title; 600×460 initial size; six-page tree | Explicit Home on bare command; normal resizing |
| Home | Same controls/values as root | Shared builders, derived Custom nudge description |
| What to watch | Intro; Spells, Professions, Shopping, Other | Keep actual scopes, limits, price boxes and collapsed category choices |
| Progress | Intro; Milestones, Tally, projected savings | Verified/estimated totals stay distinguished; do not change calculations |
| Appearance > Warnings | Intro; Style; Preview; Toast look/position when selected; chat record toggle | Warning explains its fixed presentation; Home controls actual message enable |
| Appearance > Explanations | Intro; pinned explanation alpha/scale; Preview | Pins stay attached to indicators; no meaningless Move |
| Appearance > Sound | Intro explaining existing coupling; sound, channel, Play sound, cooldown | One existing alert configuration, no duplicate selector on other tabs |
| Advanced | Intro/scope; Tuning, Classes launcher/tree, Debug | Large Classes only in standalone, sections start collapsed |
| About | Large name; muted version; purpose; command-purpose rows | log primary; export noted only as compatibility |
| Toast | Tier cue; neutral item/action; price; reason; earn-back if available | Dynamic height, native fonts, mouse-transparent; no action buttons |
| Native confirmation | Action/cost; exact reason; Buy anyway?/existing action wording | Real guard and one-shot callback, never replaced by a toast |
| Pinned explanation | Recommendation; reason; cost; close | Content-driven height, native dismiss, silent |
| Move overlay | Placeholder above settings; Done / Cancel | Tentative drag; Done saves, Cancel/Escape reverts; no lock |
| Diagnostic report | AceGUI title/chrome; copy hint; selected read-only multiline text | Scrolling, close/reopen, native/chat fallback |

| State | Expected controls and presentation |
| --- | --- |
| Fresh or reset profile | Toast selected; existing gameplay defaults retained |
| Existing profile without style | Warning selected once; disabled flags preserved |
| Warning selected | Toast-only controls hidden with explanation; preview available |
| Alerts/messages off | Effective dependencies explained; saved values retained; safe Preview still available |
| Demo showing, real attempt starts | Sample loses priority; real guard/callback wins |
| Background alpha 0 | No custom fill/border/texture/accent; text/icons retain independent alpha |
| Move ends or profile changes | Temporary layering/Escape registration cleaned; tentative data cannot leak |

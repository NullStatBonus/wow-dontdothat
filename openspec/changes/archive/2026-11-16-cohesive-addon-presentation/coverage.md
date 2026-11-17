# Recommendation coverage

Incorporated means specified, not implemented. Every row must receive concrete verification evidence during implementation. Sibling feedback has its own F01–F24 ledger in feedback.md; no feedback row is silently omitted.

| Approval | Recommendation | Destination | Disposition / verification |
| --- | --- | --- | --- |
| A | Local fonts/spacing/native controls, independent install | shared-presentation | Incorporated; standalone and missing API checks |
| A | Neutral content, tier labels, cost estimates, accurate reasons | shared-presentation; warning-presentation | Incorporated; long localized verdict and selected-revision tests |
| A | Black owned surfaces, independent alpha, alpha-zero removes decoration | shared-presentation | Incorporated; alpha 0/80/100 and late-created elements |
| B | Six landmarks and domain controls preserved | settings-interaction; addon-settings deltas | Incorporated; all controls reachable, no savings/rules changes |
| B | Root shows real top-level Home settings | Useful root settings entry | Incorporated; root/standalone parity and reopen tests |
| B | Useful context, dimensions, widths, titles, About and report | settings-interaction; feedback F05–F11 | Incorporated; actual Ace validation plus client captures |
| B | Existing scope and reset semantics | addon-settings; design.md | Retained except explicit position-only exception; two-character/profile migration tests |
| C | Common verbs, get/set validation and legacy compatibility | slash-interface | Incorporated; missing/surplus/invalid arguments and UI parity |
| C | log primary, export alias, clear semantics | slash-interface; debug-tools delta | Incorporated; equivalent report and diagnostic-only clearing |
| C | Broad demo, focused preview, existing test retained | visual-preview | Incorporated; coverage and no gameplay callbacks |
| D | Toast fresh, Warning choice/migration marker, chat record, no question duplicate | warning-presentation; warning-alerts deltas | Incorporated; old disabled profiles and confirmation suppression |
| D | DDT pinned indicator/explanation | purchase-warnings delta | Incorporated; hover, pin, close and Escape |
| D | CV Warning/Toast naming | warning-presentation | Adopted the same Toast/Warning names; no waypoint or CV trigger behavior |
| E | Safe samples, live priority, repeat cleanup | visual-preview | Incorporated; timer generations and real-attempt regression |
| E | Move/Done/Cancel/Escape and reset-only-position | visual-preview; addon-settings reset delta | Incorporated; above-settings layering, scope-change rollback |
| All | AddOns child pages/icon and heavy-tree safety | settings-interaction; feedback F02–F04/F20 | Incorporated; full rule-tree switching and package checks |
| All | Documentation, TOCs, localization, tests and captures | tasks.md | Incorporated; implementation checks remain unchecked |
| Future | New shared runtime library/profile unification/global skin | design.md | Excluded: independent local implementation |
| Future | Sibling tooltip ordering framework/new DDT find | feedback.md | Deferred/domain-specific; native coexistence preserved without new coupling |

## Baseline and explicit conflicts

No active DDT change existed; worktree was clean at preparation. MODIFIED requirements amend exact canonical names rather than adding contradictory parallel rules. Five-page/blank-root layout, Sound & messages under Advanced, banner-only wording, and prohibition on every additional reset are expressly updated. Existing purchase guards, exact skip reasons, model defaults, once-only flags, debug-off-at-login, ledger and rule revisions remain canonical.

## Validation record

- Strict OpenSpec validation: PASS on 2026-11-16 (`openspec validate cohesive-addon-presentation --strict --no-interactive`), no warnings. `openspec status --change cohesive-addon-presentation --json` reports planning complete. All modified names match canonical requirements; every delta requirement has scenarios.
- Runtime changes and tests: implemented on branch `cohesive-addon-presentation` (see Implementation evidence below). In-game checks: done (see Implementation evidence).
- No canonical specs, addon files, versions, release data or sibling repos modified.

## Implementation evidence (2026-11-16)

- `make test`: 662 passed, 0 failed. `make check`: TOC, embed and version checks pass.
- Tests against the real bundled libraries: warning-style marker with real AceDB (fresh -> relog, old -> relog, untouched old profile, reset -> relog; mutation-checked), every option table through the real AceConfigRegistry.
- Covered by unit tests with fakes: alert routing (Toast/Warning, question suppression, fallback), chat record (question, alerts off, cooldown, chat off, samples never), typed registry and slash commands (no partial writes, read-only get/status, aliases, topics), log/export parity, log clear with its own dialog, report chat fallback and Escape-to-close, demo fixed set with marks and tooltip, generation tokens and live priority, sample labels, toast appearance, scale-independent saved position, Move Done/Cancel/Escape/hide rollback, keyboard release, badge TOC paths and TGA format.
- Integration review: 10 findings across slices, all fixed and tested. Spec-to-code audit: 7 gaps (demo sample accuracy, registry declarations, report context, export wording in two docs, toast icon, Play sound disabled, Move in combat), all fixed.
- Codex adversarial review (2026-11-16): 3 findings, all fixed with mutation-checked tests. The upgrade check now uses the character's own AceDB profile and treats a profile created now as new. A malformed saved `alert` entry is dropped before load so defaults apply. A sample explanation never replaces a real pinned one.
- In game, passed (2026-11-16, reported by the tester): upgrade and fresh install (old profile keeps Warning, fresh is Toast, reset keeps Toast); toast look and Move (alpha, scale, Done/Cancel/Escape, combat refusal and cancel, reset position); settings (root Home, child pages, Open classes with no page-switch lag, window size); commands (settings/status/help, get/set with refusal, demo, preview, log/export, log clear); badge in the AddOns list; About page beside KeepThat and Closest Vendor draws cleanly (sibling show-through issues are theirs); Home, Appearance, toast and report beside the siblings at matching scale; warnings at a trainer (question plus chat line, toast with icon, cooldown, sound off, chat off, Warning style); explanations (wrap, close button and Escape, a preview or demo never replaces a real pin).
- Waived by the tester, covered by unit tests only: old profile with alerts off, malformed saved alert entry, derived Custom nudge (warning_style_test, options_test).

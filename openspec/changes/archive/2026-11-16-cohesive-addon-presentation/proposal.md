## Why

Don’t Do That still has the older settings and warning presentation. Shared conventions A–E were approved, DDT was paused, and its design resumed on 2026-11-16. The implemented KeepThat and Closest Vendor experiences and their follow-up feedback are now the reference. In particular, DDT’s root game-options page must show real top-level settings rather than an empty parent, and `/ddt log` must replace export in documentation while retaining export as an alias.

## What Changes

- Retain AceConfig; expose six consistent settings landmarks with useful root Home controls, matching sizing, context-first text and game-options child pages.
- Add Toast warnings for fresh installs, keep the large Warning banner for existing profiles, add a chat record of every warning, and preserve all purchase protections, tier choices, sounds and savings behavior.
- Add safe broad demo, focused previews, visible transactional positioning and consistent pinned explanations.
- Add common CLI verbs and typed get/set; make log the primary report command and export its compatibility alias.
- Match the corrected report window, controls, navigation, layering and registration behavior from the other two addons.

## Capabilities

### New Capabilities
- `shared-presentation`: Local style, semantic cues, accessible layout and custom-surface dimming.
- `settings-interaction`: Six-page settings experience, useful root entry, robust navigation and report window.
- `slash-interface`: Common command discovery, diagnostic aliases and typed setting access.
- `visual-preview`: Safe demonstrations, focused samples and transactional positioning.
- `warning-presentation`: Toast/Warning choice, migration marker, chat record and presentation without gameplay changes.

### Modified Capabilities
- `addon-settings`: Appearance, root Home, deeper controls, reset exceptions and CLI entry points.
- `warning-alerts`: Selected presentation in place of banner-only requirements.
- `purchase-warnings`: Readable pinned information without changing guard behavior.
- `debug-tools`: Primary log command and report content.

## Impact

Planning only: no runtime edits, canonical sync, version bump, commit or release. DDT is the only implementation target. KeepThat and CV are read-only references. Coverage and sibling feedback are accounted for in coverage.md and feedback.md. Runtime acceptance remains unchecked.

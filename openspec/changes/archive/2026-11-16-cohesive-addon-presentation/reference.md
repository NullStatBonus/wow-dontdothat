# Provenance and implementation entry point

Scope: DDT design/spec preparation only, resumed on 2026-11-16. A–E shared conventions were previously approved; current user steering adds useful root top-level settings, incorporation of sibling follow-up feedback, and primary `/ddt log` with `/ddt export` compatibility.

Read proposal.md, design.md, layout.md, feedback.md, coverage.md, all specs/*/spec.md and tasks.md. They are self-contained implementation requirements; sibling source references are evidence, not runtime dependencies. This change supersedes the old central handoff’s temporary DDT exclusion and any original mockup details contradicted by current feedback. No edits to either sibling are part of this change.

Current DDT anchors: Options/Options.lua (root placeholder, builders, Pages, Register, Rebuild, Open), Core/Addon.lua (AceDB defaults/scopes), Core/Slash.lua (legacy commands), Model/Settings.lua (Nudge and debug reset), UI/Helpers.lua (tier/cost/reason formatting), UI/Alert.lua and AlertBanner.lua (attempt/cooldown/render), UI/InfoBubble.lua (hover/pin), UI/ConfirmPopup.lua (one-shot real callbacks), Debug/Export.lua and Log.lua (report/clear).

Original review: REVIEW.md in the sibling wow-addon-style-review project. Shared historical handoff: CLAUDE-HANDOFF.md beside it. Current sibling evidence is enumerated in feedback.md. DDT baseline is the current canonical specs with no active-change dependency.

Implementation prompt: Implement this repo’s cohesive-addon-presentation change only. Account for every coverage/feedback row; preserve gameplay and saved data; run required tests and identify in-game checks for the user. Do not treat planning validation as implementation completion or archive/commit/release authorization.

Badge: `DontDoThat/Media/icon.tga` is `DontDoThatSmall_64.tga` from the project's shared 64×64 badge set (the same set as KeepThat's and Closest Vendor's icons), made for this addon and covered by the repository LICENSE. 64×64, uncompressed 32-bit TGA with alpha; `tests/badge_test.lua` checks format and TOC paths.

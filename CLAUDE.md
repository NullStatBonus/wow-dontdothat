# Don't Do That

## Delegation
- Use subagents for self-contained work that would clutter the main context: broad codebase searches, independent research threads, parallel edits across unrelated files, and reviews.
- Pick the subagent model by difficulty: haiku for search and lookup, sonnet for routine implementation, opus (or inherit) for design, debugging, and anything requiring judgment.
- Do small or tightly coupled work inline. Don't delegate just to delegate.

## Documentation

Update the supporting docs in the same change as any user-visible addon behavior, setting or command:

- `README.md`: features, settings page, command list, and "Good to know" limits.
- `docs/listing.md`: the CurseForge/Wago listing text, including the summary line if the headline behavior changes.
- `docs/test-plan.md`: manual in-game checks for the new behavior; keep section numbers unique and in order.
- The debug report (`Debug/Export.lua`) dumps the whole profile and the per-character answers, so a new setting shows there without a change; a new per-character key needs adding to `sourceProvider` in `Core/Addon.lua`.
- `CHANGELOG.md` is written at archive (see Releases), not before.

## Git and PRs

- **Archive before git.** Before any commit, push or PR for a change, run `/opsx:archive` first (sync specs, bump the version, write the CHANGELOG section), so the archive and the code ship in the same commit/PR. Commit nothing for a change that is still active in `openspec/changes/`.

## Releases

Bump the addon's semantic version every time a change's specs are applied to `openspec/specs/` (at `/opsx:sync` or `/opsx:archive`).

- Set `## Version:` in **both** `DontDoThat/DontDoThat_Vanilla.toc` and `DontDoThat/DontDoThat_Camelot.toc` to the same value. Do not hard-code the version anywhere else.
- Below 1.0.0: a change that adds a capability or user-visible feature raises the minor number (0.2.0 -> 0.3.0); a change that only modifies or fixes existing behavior raises the patch number (0.2.0 -> 0.2.1). From 1.0.0, use the usual major.minor.patch meaning, and a change that breaks saved settings or data is a major bump.
- Make the bump part of the same commit as the archive, and name the new version in the commit message.
- To publish, tag the archive commit `vX.Y.Z` (the version without the `v` must equal the TOC version) and push the tag; see `docs/publishing.md`. Add the version to `CHANGELOG.md` in the same commit as the archive.

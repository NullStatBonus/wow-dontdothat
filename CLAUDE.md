# Don't Do That

## Releases

Bump the addon's semantic version every time a change's specs are applied to `openspec/specs/` (at `/opsx:sync` or `/opsx:archive`).

- Set `## Version:` in **both** `DontDoThat/DontDoThat_Vanilla.toc` and `DontDoThat/DontDoThat_Camelot.toc` to the same value. Do not hard-code the version anywhere else.
- Below 1.0.0: a change that adds a capability or user-visible feature raises the minor number (0.2.0 -> 0.3.0); a change that only modifies or fixes existing behavior raises the patch number (0.2.0 -> 0.2.1). From 1.0.0, use the usual major.minor.patch meaning, and a change that breaks saved settings or data is a major bump.
- Make the bump part of the same commit as the archive, and name the new version in the commit message.
- To publish, tag the archive commit `vX.Y.Z` (the version without the `v` must equal the TOC version) and push the tag; see `docs/publishing.md`. Add the version to `CHANGELOG.md` in the same commit as the archive.

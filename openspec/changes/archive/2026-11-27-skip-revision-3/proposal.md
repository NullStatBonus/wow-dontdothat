## Why

Revision 2 of the rank-skip list uses Wowhead's Classic Era leveling guides. Wowhead and Method now publish leveling guides written for WoW Forever, with per-spec lists of the abilities to train. Where those guides disagree with revision 2, the Forever guides are the better source.

## What Changes

- **Revision 3** of the skip list, the new default. It builds on revision 2 and changes 243 of its 795 skipped (rank, spec) decisions: 107 are newly skipped and 136 are no longer skipped. Another 78 keep their skip with a new source label.
- Each decision is a statement read from one Forever guide page for one spec (Wowhead for 18 specs that have training statements, from 26 guide pages read; Method for one Hunter sentence). The statements, their pages and dates are in `tools/skip-revision/revision3.json`.
- Two new skip sources (`guideForever`, `guideMethod`) and one new reason, "not worth upgrading after level N". The Rules page and the trainer tooltip name them.
- The load notice shows once more per profile and says revision 3 updates the skip list from the newest Forever guides.
- Revisions 1 and 2 are unchanged. A player who picked either keeps it.
- The generator splices revision 3 into `Data/SkipRevisions.lua` and no longer rebuilds revisions 1 and 2 (`--rebuild-old` does).

## Capabilities

### Modified Capabilities
- `rank-skip-revisions`: revision 3, its rules, the new sources, the default and the notice.
- `addon-settings`: the Tuning choice lists revision 3 as the default.

## Impact

- `Data/SkipRevisions.lua` (generated), `Rules/Schema.lua`, `Rules/Engine.lua`, `Model/SkipRevision.lua`, `Locales/Example.lua`, `tools/build-skip-revisions.py`, `tools/skip-revision/`, tests, README, `docs/contracts.md`.
- Players on the default move from revision 2 to revision 3 at 1.0.0. Saved settings do not change.

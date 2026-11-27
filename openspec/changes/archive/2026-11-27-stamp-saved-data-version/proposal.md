## Why

Saved data has no record of which addon version wrote it. Migrations rely on ad hoc marks, and from 1.0 a break in saved data needs a major version. A later migration and a bug report need to know where a player's data came from (issue #79).

## What Changes

- On load, the running version is written to `db.global.version`, and the one it replaces to `db.global.previousVersion` when they differ. An unknown version never overwrites what was recorded.
- The debug report shows `saved data version: <current> (earlier: <previous>)`.
- Additive: plain strings with no default; an older version ignores them, so a downgrade is safe. The TOC stays at 0.15.0 until 1.0.0 is released.

## Capabilities

### Modified Capabilities
- `debug-tools`: the report shows the saved-data version.

## Impact

- `Model/Settings.lua` (`StampVersion`), `Core/Addon.lua`, `Debug/Export.lua`, tests, README.

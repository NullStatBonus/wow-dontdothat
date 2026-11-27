# Don't Do That

## Documentation

When player-visible behavior, a setting, or a command changes, update the supporting docs in the same change.

- Cover affected features, settings, commands, and “Good to know” limits in `README.md`.
- Update the CurseForge/Wago text in `docs/listing.md`. Update its summary when the headline behavior changes.
- Update `docs/test-plan.md` with the relevant manual checks, or the CheckThat plan that covers them. Keep section numbers unique and in order.
- Document every new setting in the README and include its value in the debug report.
- Keep the report’s settings summary current in `DontDoThat/Debug/Export.lua` (`Export.Build`).

## Testing

- Cover each new behavior with an automated test. Temporarily break the behavior, verify the test fails for the expected reason, then restore the behavior and verify it passes.
- Run the focused test during implementation. Use `make test` for the full suite and `make check` for packaging and version checks.
- Keep manual checks short and few. Give each check one player action, then a `Check:` line that states the expected result in words a player understands. Put the log line or saved variable that proves it on a separate `Log:` line for the reviewer. Never ask the player to read or interpret a log line. Log a distinct line for each behavior the check verifies.
- Give only essential setup before the action, but name everything the check depends on: a profession, an installed addon, and turning on debug logging followed by `/reload`. Avoid old versions, disabled addons, and staged characters or items.
- Verify the result from debug logs or saved variables wherever possible. Add missing evidence in the same change.
- Keep raw saved variables and debug output out of Git. Anonymize any fixture derived from them.
- In-game checks live in CheckThat plans under `plans/`; `docs/test-plan.md` points there. All CheckThat calls sit in `DontDoThat/CheckThat.lua`, which reaches CheckThat only through `Adapter.checkThat()` with each call guarded and in `pcall`, so the addon works with CheckThat missing or old. An entry reads state only and writes no log line. Log lines, entries and the test-settings record are listed in `docs/contracts.md`. When a CheckThat run needs the player's settings out of the way, it uses `/ddt testsettings` (a temporary AceDB profile that is never saved).
- Prefer checks the player can complete through ordinary play.
- Read the player’s copied saved variables in `../shared-addon-resources/saved` under `Account/<account>/SavedVariables/` before asking for more in-game steps.
- When simple reproduction is impractical, cover the case with automated tests, use real bundled libraries where it matters, and say which case they cover.

## Backlog

- Track deferred work and future ideas as GitHub issues (`gh issue create`), not in repo files. When a change or review defers something, open the issue in the same session and name it in the change's `design.md` (Non-Goals) when there is one.
- Issue text describes the gap, the code involved and a possible approach; no personal names.
- Check open issues (`gh issue list`) before proposing new work.

## Conventions

- Route game API calls through an adapter. For intercepts, use `DontDoThat/Intercepts/Adapter.lua`. Keep behavior logic free of WoW globals so it runs under LuaJIT with a fake adapter where needed.
- Use a complete English literal as the key for each player-facing sentence, as in `L["The whole English sentence"]`. Cover dynamically assembled keys with a test that rejects them. See `docs/localization.md` for translation rules and the English-only debug output convention.
- Choose game API code paths by checking whether the function exists, never by the client's name.
- Persistent visuals default to a pure black background, with a user-selectable color. Draw no fill, border, or texture at zero opacity. Keep text and icons dimmable and avoid bright fixed-position fills.
- For each new UI control or screen, check Blizzard UI source and popular addons for an established pattern. Use a standard control when available. If a custom control is necessary, keep the standard fallback where the custom control is unavailable.

## OpenSpec, Git, and releases

- Follow the matching workflow under `.claude/skills/`. The archive procedure is in `.claude/skills/openspec-archive-change/SKILL.md` (`/opsx:archive` in Claude Code).
- Bump the version once per OpenSpec change when its specs are applied to `openspec/specs/` during sync or archive. If `/opsx:sync` already set the version, keep it at archive. Exception: the changes of issue #73 (CheckThat integration, plans and Always Allow) and the fixes that ship with them leave the TOC at 0.15.0. They ship together as 1.0.0, and the user asks for that release.
- Set the same `## Version:` in `DontDoThat/DontDoThat_Vanilla.toc` and `DontDoThat/DontDoThat_Camelot.toc`. These are the only files that hard-code the addon version.
- Before 1.0, bump minor for a new capability or player-visible feature and patch for a fix or modification to existing behavior. From 1.0 onward, follow semantic versioning. Breaking saved settings or data requires a major bump from 1.0 onward.
- Archive before committing, pushing, or opening a PR for the change. Keep the code, synced specs, archive, version bump, and matching `## X.Y.Z` changelog section in the same commit. Name the new version in the commit message. A change still active in `openspec/changes/` is ineligible for commit.
- Write `CHANGELOG.md` at archive. Order entries by `New:`, `Changed:`, `Fixed:`, and `Removed:`. Bold the main item. For each fix, say what players saw before. Write one short line per entry in ASD-STE100 Simplified Technical English. Use active voice, simple tenses, common words, one fact per sentence, and at most 20 words per sentence. Describe what players see. Put settings-page, debug-report, and implementation details in the README.
- To publish, tag the archive commit `vX.Y.Z`, matching the TOC version, and push the tag as described in `docs/publishing.md`.

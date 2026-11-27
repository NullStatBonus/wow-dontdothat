## 1. Data

- [x] 1.1 Write `tools/skip-revision/revision3.json`: one statement per spell and spec, with page and date.
- [x] 1.2 `tools/skip-revision/revision3.py` combines the statements with revision 2.
- [x] 1.3 `build-skip-revisions.py` reads revisions 1 and 2 from the shipped file and splices revision 3 in; `--rebuild-old` keeps the old pipeline.
- [x] 1.4 Regenerate `Data/SkipRevisions.lua`; confirm revisions 1 and 2 are unchanged.

## 2. Addon

- [x] 2.1 Schema: sources `guideForever` and `guideMethod`, reason `guideUselessAfter`.
- [x] 2.2 Engine: the sentences for the new sources and reason.
- [x] 2.3 `SkipRevision`: describe revision 3 and reword the notice.
- [x] 2.4 `Locales/Example.lua` lists the new strings.

## 3. Tests

- [x] 3.1 Update the tests that assumed revision 2 is the newest.
- [x] 3.2 New tests: per-spec decisions, sources, the level reason, carry-over from revision 2, schema.
- [x] 3.3 Break the data three ways and confirm a test fails each time.

## 4. Docs

- [x] 4.1 README, `docs/contracts.md`, `tools/skip-revision/README.md`, CHANGELOG.
- [x] 4.2 Open issue #83 for the gaps.

## 5. Verify

- [x] 5.1 `make test` and `make check`.

# Publishing

Releases are built by [BigWigsMods/packager](https://github.com/BigWigsMods/packager) from `.github/workflows/release.yml` and uploaded to CurseForge, WoWInterface and Wago, plus a GitHub release.

## One-time setup

1. Create the addon project on each site and note its ID.
2. Add the IDs to the TOC files (both of them, `DontDoThat/DontDoThat_Vanilla.toc` and `DontDoThat/DontDoThat_Camelot.toc`):

   ```
   ## X-Curse-Project-ID: <CurseForge project ID>
   ## X-WoWI-ID: <WoWInterface addon ID>
   ## X-Wago-ID: <Wago project ID>
   ```

   The packager skips any site whose ID is missing.
3. Add these repository secrets (Settings > Secrets and variables > Actions): `CF_API_TOKEN`, `WOWI_API_TOKEN`, `WAGO_API_TOKEN`. `GITHUB_TOKEN` is provided by GitHub.
4. Pick MIT as the license on each site. The repository's `LICENSE` ships inside the package; the Ace3 libraries keep their own in `DontDoThat/Libs/LICENSE-Ace3.txt`.

## Releasing

1. Archive the change and bump `## Version:` in both TOC files (see `CLAUDE.md`), and add the version to `CHANGELOG.md`.
2. Commit, then tag the commit `vX.Y.Z` (the version without the `v` must equal the TOC version) and push the tag.
3. The workflow runs the tests and `tools/check-*.sh`, checks the tag against both TOC versions, then packages and uploads.

To try the packaging without uploading anything, run the Release workflow by hand from the Actions tab (it defaults to a dry run).

## How the package is laid out

- The addon lives in `DontDoThat/` inside the repository, so `.pkgmeta` moves it to the top of the zip and ignores everything else (tests, tools, docs, openspec).
- The Ace3 libraries are committed under `DontDoThat/Libs`, so no externals are fetched.
- The packager treats `DontDoThat_Camelot.toc` as the WoW Forever TOC (its name for the Forever client; the game also accepts `_Forever`) and `DontDoThat_Vanilla.toc` as Classic Era. A TOC named `_Forever` would not be recognized, so Forever would not be offered as a game version.
- `CHANGELOG.md` is used as the changelog on every site (`manual-changelog` in `.pkgmeta`).

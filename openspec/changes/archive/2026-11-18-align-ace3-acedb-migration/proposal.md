# Proposal

## Why

Don't Do That, Closest Vendor and KeepThat embed different Ace3 versions (NullStatBonus/wow-closestvendor#32). Don't Do That ships Release-r1403, whose AceGUI ColorPicker (minor 28) inverts alpha on WoW Forever; upstream commit ac3d122 (ColorPicker 29) fixes it and is what Closest Vendor already ships. The same commit moves AceDB-3.0 from minor 33 to 40, which on WoW Forever changes the character key from `Name - Realm` to `Name Surname` with no migration. Because LibStub loads the highest AceDB minor from any installed addon, a Forever player can already lose this character's ledger, cost cache and profile choice today when another addon brings AceDB 40.

## What Changes

- Replace every embedded Ace3 file in `DontDoThat/Libs` with upstream WoWUIDev/Ace3 commit ac3d122 (21 commits past Release-r1403, no newer tag). Same module set: LibStub, CallbackHandler-1.0, AceAddon-3.0, AceDB-3.0, AceHook-3.0, AceEvent-3.0, AceConsole-3.0, AceConfig-3.0 (Registry, Cmd, Dialog), AceGUI-3.0 and its widgets. Only versions change (notably AceDB 40, AceConfigDialog 93, AceGUI ColorPicker 29, Heading 21, Icon 22, Label 29).
- Add a one-time character-key migration right after `AceDB:New`: when the key the loaded AceDB uses differs from the old `Name - Realm` key, move this character's saved data and profile choice to the new key. It works whichever AceDB minor is loaded, and does nothing on Classic Era.
- Rewrite `DontDoThat/Libs/VERSIONS.txt` into a shared provenance format (upstream URL and commit, each module's MAJOR and MINOR, license file, local patches, update steps). Keep the license file.
- Patch release at archive (0.13.0 -> 0.13.1).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `addon-settings`: adds a requirement that a character's saved data and profile choice survive a change of the character key used by the settings library.

## Impact

- Code: `DontDoThat/Core/Addon.lua` (`OnInitialize`), `DontDoThat/Model/Settings.lua` (migration logic), `DontDoThat/Intercepts/Adapter.lua` (old-key reader).
- Libraries: all of `DontDoThat/Libs` (files replaced, possibly widget/XML lists), `VERSIONS.txt`.
- Tests: new migration tests; `tests/warning_style_test.lua` loads the bundled AceDB and needs stubs for the new globals AceDB 40 calls (`UnitNameUnmodified`, `RegionalUniqueNamesEnabled`).
- Saved data: `DontDoThatDB.char` and `DontDoThatDB.profileKeys` on WoW Forever, moved once per character.
- Other addons: Closest Vendor and KeepThat share the same library copies through LibStub.

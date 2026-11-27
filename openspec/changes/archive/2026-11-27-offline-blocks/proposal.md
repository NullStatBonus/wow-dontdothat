## Why

The foundation plan runs only in game, so a break that a fake client could show (an entry that no longer answers, a trainer row shape read wrongly on one client, a saved setting lost at load) waits for a tester. CheckThat can replay the addon offline on each client's TOC with recorded calls (issue #73).

## What Changes

- An `offline:` block in `plans/dontdothat.yaml` runs at level 6 on the Classic Era and Forever TOCs (`ct offline --client both`): the entries at a plain load, the recorded class-trainer rows on each client after `TRAINER_SHOW` and `TRAINER_UPDATE`, and a saved setting read at load. `predicts` links five foundation steps to their offline steps.
- A new CheckThat entry `trainer` returns `rows=<n>` for the open trainer window, or nothing when none is open. It reads through the adapter and writes nothing. In game it can also serve as evidence.
- `make plan` validates, compiles, replays, checks the lines and runs the offline block of each plan, with the CheckThat tools installed.
- No saved data changes. The TOC stays at 0.15.0 until 1.0.0 is released.

## Capabilities

### Modified Capabilities
- `checkthat-integration`: a fourth entry, `trainer`.

## Impact

- `DontDoThat/CheckThat.lua`, `Core/Addon.lua`, `plans/dontdothat.yaml`, `Makefile`, tests, README, `docs/contracts.md`.
- Merchant and auction rows are not in the block: the vendor row call differs by client (`GetMerchantItemInfo` on Era, `C_MerchantFrame.GetItemInfo` on Forever), and a block cannot mock a call the client lacks.

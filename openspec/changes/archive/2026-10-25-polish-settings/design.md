## Context

Home is built in `Options.Home()` with a radio select whose labels are bare names, a separate list of explanations below it, and a note shown when the derived level is Custom. Resets are separate buttons on Tuning, What to watch, Rules (per class and for all) and Tally. Debug recording is stored in the profile (`debug`, `traceItems`), so it persists once switched on. Progress embeds the Milestones and Tally groups inline, each with its own title.

## Decisions

1. **Explanations on the options.** The radio labels carry a gray one-line description each, so the separate list goes. The Custom label carries the explicit state from the saved values: marks on or off, "never asks" or "asks about <tier names>", using the existing tier names (Save your gold, Not worth buying yet, Optional). The note under the radio says choosing a level resets these or they can be fine-tuned under Advanced > Tuning.
2. **Reset-all keeps what is not a preference.** `Settings.ResetAll(profile)` clears every key of the profile except `professionAsked` and `milestoneOverride`; with AceDB the defaults show through again. It also turns debug logging off and refreshes the open window and trainer overlays. The Tally's "Start the count over" stays because it clears data, not settings.
3. **Remove, don't hide.** The reset controls on Tuning, What to watch and the Rules page (per class and all) are deleted along with their spec scenarios.
4. **Progress headings.** The inline Milestones and Tally groups drop their own title description; the box heading remains.
5. **Debug off at login.** `Settings.ClearDebug(profile)` sets `debug` and `traceItems` to false and is called when the database loads, before logging is enabled. The recorded data (log and item trace) is kept until cleared.

## Risks / Trade-offs

- Reset-all also wipes rule switches, spec choices, tuning and watch areas; the confirmation text says so.
- Switching debug off at every login means a reproduction that spans a relog needs recording turned on again.

## Migration Plan

No saved-settings changes. Version 0.8.0 becomes 0.8.1 at archive.

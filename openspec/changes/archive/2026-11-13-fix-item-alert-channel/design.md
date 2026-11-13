# Design

## Context

`Intercepts/ItemGuard.lua` builds its own alert settings and leaves out `alertChannel`, which `Intercepts/Confirm.lua` includes. `UI/Alert.lua` falls back to Master when the field is missing.

## Decisions

- Add `alertChannel = a.channel` to ItemGuard's `alertSettings`. Reusing `ns.TrainerConfirm.AlertSettings` would tie ItemGuard to Confirm's load order; sharing a helper is a larger refactor left for later.

## Risks / Trade-offs

- The two settings builders can drift again. The new test guards the channel field.

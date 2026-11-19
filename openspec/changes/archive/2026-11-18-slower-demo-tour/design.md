# Design

## Context

`Demo.Run` (`UI/Demo.lua`) draws the marks, tooltip and question at once, then four notices at `STEP` = 2 s, and ends everything at `LIFETIME` = 10 s.

## Decisions

- **One step at a time.** Seven steps, `TOUR_STEP` = 5 s apart. Each step first clears the earlier samples (the existing `cleanup`), then draws its own. A notice holds 2.5 s and fades 1.5 s, so it is gone before the next one comes.
- **Caption per step.** One chat line through `Prompt.Say` names the step, so the player can match the message to its meaning. Chat stays as a record after the tour.
- **Order.** Notices first (the thing players see most), then the explanation, the marks with their tooltip, and the question last, because it waits for a click.
- **End.** The tour ends `LIFETIME` (10 s) after the last step starts: 40 s in total. Previews are unchanged.

## Risks / Trade-offs

- A longer tour. A real warning or question still ends it at once (`Demo.Interrupt`), and `/ddt demo` again restarts it.

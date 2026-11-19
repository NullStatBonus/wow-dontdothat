# visual-preview Specification

## Purpose
Safe ways to see the addon's warnings without buying anything: the /ddt demo tour, focused /ddt preview samples that always give way to a real warning, and moving the toast with Done, Cancel and Escape.

## Requirements

### Requirement: Broad safe demo
`/ddt demo` SHALL exercise representative marks, hover tooltip, pinned reason, selected warning style and an inert confirmation using synthetic data. The tour SHALL show one sample at a time, at least five seconds apart, and SHALL add one chat line per step that names what that step shows. Samples SHALL be labeled; the tour SHALL end within 45 seconds or close explicitly, and a single preview SHALL expire within ten seconds; normal warning fade MAY finish earlier. Real disabled states MAY be bypassed for samples only. Gameplay, settings, ledger, one-time profession flags and real cooldown/deduplication SHALL remain unchanged.

#### Scenario: No purchase
- **WHEN** any demo prompt is accepted or cancelled
- **THEN** only the sample dismisses; no production purchase, training, reset, auction or profession callback is called

#### Scenario: Disabled alerts
- **WHEN** demo runs while real alerts/messages are disabled
- **THEN** samples show without enabling real features; at most one sound uses the selected sound/channel and no volume setting changes

#### Scenario: Representative tiers
- **WHEN** demo runs
- **THEN** it shows the same fixed set every time: one informational, one defer-low-value, one defer, one skipped rank and one estimated-price/earn-back sample, each with accurate reasons and costs and without fabricating live decisions

#### Scenario: One sample at a time
- **WHEN** demo runs
- **THEN** each step starts at least five seconds after the one before, only that step's sample is new on screen, and a chat line names it

### Requirement: Focused preview and live priority
`/ddt preview` SHALL list toast, warning, mark, tooltip, explanation and prompt. A named preview SHALL show that surface using the production drawing helpers with injected sample data. Alternate styles SHALL NOT save preferences. Existing `/ddt test` SHALL retain its integration-test behavior. Real user actions and live warnings/questions SHALL take priority and cancel conflicting samples.

#### Scenario: Real attempt during preview
- **WHEN** a real purchase opens a guarded confirmation while a sample is showing
- **THEN** the sample is dismissed and the real question/callback remains intact; no sample timeout may cancel it

#### Scenario: Repeat
- **WHEN** a new demo or preview starts before the old one ends
- **THEN** old timers become inert and only current samples remain; ending restores current live state

#### Scenario: Alternative style
- **WHEN** warning is previewed while Toast is saved
- **THEN** only the sample style changes and the saved Toast preference remains

#### Scenario: Sound sample
- **WHEN** a warning Preview action is used
- **THEN** the selected alert sound/channel is previewed once with graceful missing-sound fallback and without consuming real alert cooldown

### Requirement: Transactional positioning
Appearance SHALL offer Move for the toast anchor with a clamped placeholder and visible Done/Cancel above settings. Position SHALL commit only on Done; Cancel/Escape SHALL restore the start. Reset position SHALL affect only the anchor. Profile switches, logout or closing the move session unexpectedly SHALL cancel tentative changes. No toast lock SHALL be required.

#### Scenario: Layering
- **WHEN** Move starts while AceGUI settings are open
- **THEN** the placeholder and Done/Cancel draw above settings and accept input; normal strata/input are restored on completion

#### Scenario: Rollback
- **WHEN** the placeholder moves then Cancel or Escape is used
- **THEN** the starting position returns with no persisted move

#### Scenario: Commit and reset
- **WHEN** Done is used then Reset position is selected
- **THEN** Done saves in the active profile; Reset changes only position, preserving scale, alpha, style and gameplay settings

#### Scenario: Scope change
- **WHEN** the active profile changes during Move
- **THEN** the old transaction cancels without writing its tentative position into either profile

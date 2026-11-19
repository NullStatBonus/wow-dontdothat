## MODIFIED Requirements

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

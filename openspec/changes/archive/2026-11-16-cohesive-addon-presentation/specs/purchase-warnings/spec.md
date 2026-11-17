## MODIFIED Requirements

### Requirement: Information bubble
The information indicator SHALL show the tier recommendation, accurate reason and cost on hover and pin the same explanation on click. Pinned content SHALL use the shared readable hierarchy and dimmable black surface with native close action, grow for long text and clamp to screen. Hover SHALL remain silent; pinning SHALL NOT be mistaken for a purchase attempt.

#### Scenario: Mouseover
- **WHEN** the information indicator is hovered
- **THEN** the reason and cost appear with native tooltip chrome and no alert sound

#### Scenario: Click to pin
- **WHEN** the indicator is clicked
- **THEN** details remain visible until close, Escape or the same indicator toggles them off, without triggering a purchase

#### Scenario: Long pinned text
- **WHEN** a localized reason or earn-back line is long
- **THEN** height grows and all content stays readable and on screen; closing does not affect a real confirmation

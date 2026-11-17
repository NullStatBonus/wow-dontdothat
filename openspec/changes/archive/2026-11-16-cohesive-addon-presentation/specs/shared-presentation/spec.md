## ADDED Requirements

### Requirement: Local visual contract
The addon SHALL define local visual tokens, use existing game font objects with guarded fallbacks, and retain standard AceGUI and game control chrome. It SHALL install independently without sibling addons or a new shared library. New UI SHALL use verified standard controls before custom ones and SHALL NOT reskin game or third-party frames.

#### Scenario: Geometry and text
- **WHEN** owned compact UI is drawn
- **THEN** spacing follows a 4-unit base, 8-unit compact padding, 12-unit content padding and 16-unit section gaps; GameFontHighlightSmall, GameFontHighlight and GameFontNormal provide supporting, body and heading roles

#### Scenario: Missing font or control
- **WHEN** a preferred font object or standard control is absent
- **THEN** an available guarded fallback is used without disabling purchase safeguards

#### Scenario: Standalone
- **WHEN** only DDT is installed
- **THEN** its settings and owned UI work with its bundled dependencies

### Requirement: Semantic hierarchy and content safety
Owned UI SHALL use neutral primary text and restrained tier accents with visible tier/recommendation wording. Existing Keep, Optional, Not worth buying yet and Save your gold meanings SHALL remain. Text SHALL wrap or grow without hiding essential names, prices, reasons or actions. Native tooltip sections SHALL coexist with other addons without global hooks.

#### Scenario: Long reason
- **WHEN** a long localized item name and revision-specific reason are displayed
- **THEN** the full recommendation and actions remain reachable and no fixed-height clipping hides them

#### Scenario: Color independent
- **WHEN** a warning is viewed without distinguishing its tier color
- **THEN** visible wording still communicates the recommendation and estimated costs remain identified as estimates

#### Scenario: Neutral ink
- **WHEN** owned content is drawn on black
- **THEN** primary and secondary ink approximate #DDDDDD and #AAAAAA while retaining readable contrast

### Requirement: Independent custom-surface dimming
Toasts and pinned explanations SHALL default to pure black custom backgrounds with independent background and text/icon alpha. Background alpha zero SHALL draw no fill, border, texture or decorative accent; text/icons SHALL retain their own alpha. Native tooltip and confirmation chrome SHALL remain native. Appearance changes SHALL NOT alter enabled states or verdicts.

#### Scenario: Background off
- **WHEN** background opacity is zero with any supported color
- **THEN** only text/icons at their own opacity remain, including newly created elements

#### Scenario: Dimming
- **WHEN** text/icon opacity changes
- **THEN** all owned content for that surface dims consistently while background alpha is unchanged

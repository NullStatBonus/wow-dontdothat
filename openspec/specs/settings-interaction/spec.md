# settings-interaction Specification

## Purpose
How the settings are organized and reached: the landmark pages, a useful root entry in the game's options, the standalone Classes window, page layout, shared controls that apply at once, the diagnostic report window and the addon's identity in the AddOns list.

## Requirements

### Requirement: Settings landmarks
DDT SHALL expose Home, What to watch, Progress, Appearance, Advanced and About in that order using AceConfig/AceConfigDialog. Appearance SHALL have Warnings, Explanations and Sound tabs. Advanced SHALL retain Tuning, Classes and Debug plus scope information. Existing rules, purchasing, milestones and savings controls SHALL remain reachable.

#### Scenario: Direct entry
- **WHEN** a page or Appearance tab opens directly
- **THEN** purpose text precedes controls and the relevant next action is visible without hovering

#### Scenario: About
- **WHEN** About opens
- **THEN** the name, muted version, purpose sentence and individual command-purpose rows follow the siblings’ hierarchy

### Requirement: Useful root settings entry
The root Don’t Do That entry in Options > AddOns SHALL render Home’s top-level controls directly, not a blank parent, navigation-only placeholder or launcher. Bare `/ddt`, `/dontdothat` and settings without a page SHALL select Home explicitly. Root and child pages SHALL use the same effective values, validation and refresh paths.

#### Scenario: Root content
- **WHEN** the player selects Don’t Do That in Options > AddOns
- **THEN** enable, nudge level, stop-after mount and Reset all settings are usable directly on the root page with Home guidance

#### Scenario: Root parity
- **WHEN** nudge is changed on the root game-options page then standalone Home opens
- **THEN** the same effective selection appears and gameplay behavior agrees

#### Scenario: Reopen
- **WHEN** standalone settings were last closed on Classes then `/ddt` opens
- **THEN** Home is selected rather than a blank root or the last nested page

### Requirement: Registration and large-tree isolation
Game-options registration SHALL list What to watch, Progress, Appearance, Advanced and About beneath the root in tree order where supported. DDT SHALL keep class/rule trees out of the game Settings panel by using a contextual Classes launcher into standalone Advanced > Classes. Standalone classes SHALL start collapsed on normal open; targeted navigation MAY expand only the requested path.

#### Scenario: Large rule tree
- **WHEN** Classes is requested from the game-options Advanced panel
- **THEN** a labeled Open classes action closes game Settings when possible and opens standalone Classes without embedding its large tree

#### Scenario: Repeated registration
- **WHEN** pages rebuild or reopen repeatedly
- **THEN** the root Home and children stay current with no duplicate categories, callbacks or stale parent table

#### Scenario: Missing game registration
- **WHEN** game-options registration fails or APIs are absent
- **THEN** the standalone tree remains available and supported commands still work

### Requirement: Corrected settings layout
Standalone settings SHALL start at 600 by 460 units and remain resizable. Standard dropdowns, sliders and buttons SHALL use compact content-appropriate widths; explanatory text and checkbox labels SHALL use the full row. Introductions SHALL sort before controls, not through negative Ace orders. Titles SHALL show only Don’t Do That; Advanced SHALL explain settings scope.

#### Scenario: Small window
- **WHEN** settings open at the default size
- **THEN** choices and complete labels fit or wrap and scrolling keeps all actions reachable

#### Scenario: Context ordering
- **WHEN** a page is rendered through the actual Ace registry
- **THEN** its introduction is first, followed by section guidance then choices, with no duplicated headings or consecutive blank gaps

#### Scenario: Scope
- **WHEN** Advanced opens
- **THEN** it explains shared profile settings, per-character savings/cost data and account-wide diagnostics without adding a new profile system

### Requirement: Common controls and immediate parity
Applicable controls SHALL use Background opacity, Text and icon opacity, Scale, Preview, Move, Reset position, Record debug information and Show debug report. Dependent controls SHALL retain values and explain prerequisites; inapplicable style-specific controls SHALL be hidden with a concise explanation. UI and CLI SHALL share validation and refresh without reload.

#### Scenario: Inactive style
- **WHEN** Warning is selected
- **THEN** toast appearance/position controls are hidden with an explanation and their values remain saved

#### Scenario: Disabled feature
- **WHEN** alerts or on-screen messages are off
- **THEN** controls explain their disabled state without resetting choices; explicit previews remain available

#### Scenario: Live update
- **WHEN** a setting changes in the CLI while its page is open
- **THEN** the current effective value and visible real UI update consistently

### Requirement: Matched diagnostic window
The primary report SHALL use an AceGUI Frame and scrolling MultiLineEditBox with title, copy hint, selected read-only text and no submit action, matching the siblings. If AceGUI fails, a new chat fallback SHALL print the full report in chunks. Close and reopen SHALL release or reuse resources correctly and rebuild current report content.

#### Scenario: Copy and reopen
- **WHEN** report text is accidentally edited, closed then reopened
- **THEN** data remains unchanged, current diagnostics are shown and no duplicate report windows survive

#### Scenario: Window unavailable
- **WHEN** the report window cannot be created
- **THEN** the full report text is printed to chat in chunks and nothing is lost

#### Scenario: Fallback
- **WHEN** AceGUI report creation fails
- **THEN** a native or chat fallback still exposes useful diagnostics without a Lua error

### Requirement: AddOns list identity
Both TOCs SHALL declare the same DDT badge through IconTexture and ship its local square power-of-two alpha-enabled texture. The asset SHALL be appropriate for DDT and independent of sibling installs, with source/license provenance. Missing icon data SHALL NOT prevent loading or settings access.

#### Scenario: AddOns badge
- **WHEN** the game AddOns list opens on either supported client
- **THEN** DDT has its own badge next to its name, with the same asset declared in both TOCs

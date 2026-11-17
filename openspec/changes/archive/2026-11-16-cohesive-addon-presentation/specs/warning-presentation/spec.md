## ADDED Requirements

### Requirement: Warning style choice
Appearance SHALL offer two warning styles: Toast and Warning (the existing large centered raid-warning banner). Fresh installs, newly created profiles and profiles reset with Reset all settings SHALL use Toast. Existing alert, message, sound, cooldown and question settings SHALL remain intact.

#### Scenario: New install
- **WHEN** no DDT saved profile exists
- **THEN** Toast is selected without changing existing gameplay defaults

### Requirement: Warning style upgrade marker
A profile saved before this version SHALL be classified once as Warning; valid saved choices SHALL remain. Classification SHALL run on raw saved data before AceDB defaults are applied, SHALL record a per-profile marker whose value never equals a default so AceDB does not strip it, and SHALL be idempotent. Reset all settings SHALL keep the marker.

#### Scenario: Fresh install after relog
- **WHEN** a fresh install on Toast logs out and back in
- **THEN** Toast is still selected and the profile is not reclassified as Warning

#### Scenario: Old profile
- **WHEN** a pre-change profile has no style and messages are disabled
- **THEN** Warning is selected and messages remain disabled

#### Scenario: Reset then relog
- **WHEN** an old profile classified as Warning runs Reset all settings, then logs out and back in
- **THEN** Toast is selected and remains selected after the relog

#### Scenario: Saved choice
- **WHEN** a valid saved style exists and initialization reruns
- **THEN** it remains; switching profiles never migrates unrelated profile data

### Requirement: Presentation-only routing
All enabled alert visuals SHALL use the selected style and shared verdict content. A real question for an attempt SHALL suppress its alert visual, in either style. When a question is wanted but cannot be shown, the selected visual SHALL appear instead. Existing tier gates, master/area/message toggles, cooldowns, chosen sound/channel and ledger behavior SHALL remain. Styling SHALL NOT enable warnings or sound, change interception, or merge notification and question roles.

#### Scenario: Question
- **WHEN** a flagged attempt opens a real question
- **THEN** the existing alert sound rules apply but no Toast or Warning duplicates it

#### Scenario: No question
- **WHEN** a flagged purchase proceeds without a question
- **THEN** one visual in the selected style shows when alerts and messages are enabled, and the original alert sound/cooldown rules remain

#### Scenario: Hover
- **WHEN** a marked row is hovered
- **THEN** no attempt alert, sound or chat line is produced

#### Scenario: Style change
- **WHEN** the user changes Toast to Warning
- **THEN** future visuals change style only and no sound, attempt, chat line or ledger entry is generated

### Requirement: Chat record of warnings
Every flagged attempt that passes the addon enable, tier and cooldown gates SHALL print one chat line naming the item or action, cost and reason, whether a question, Toast, Warning or nothing is shown. A "Also note warnings in chat" setting SHALL control it, defaulting on for new and existing profiles. The alerts toggle SHALL NOT suppress it. Samples from demo or preview SHALL NOT print it.

#### Scenario: Question shown
- **WHEN** a flagged attempt opens a question
- **THEN** exactly one chat line is printed alongside the question

#### Scenario: Alerts off
- **WHEN** alerts are disabled and chat is enabled
- **THEN** no sound or visual appears but the chat line is printed

#### Scenario: Cooldown
- **WHEN** the same flagged action is attempted repeatedly within the cooldown
- **THEN** only the first attempt prints a chat line

#### Scenario: Chat off
- **WHEN** the chat setting is off
- **THEN** no chat line is printed and sound, visuals and questions are unchanged

### Requirement: Toast content
Toasts SHALL use a 320-unit starting width, content-driven height, neutral title, small tier accent and icon when known. They SHALL include recommendation, item/action, price with estimate marker, reason and existing earn-back line when available. They SHALL remain mouse-transparent outside Move and use the existing four-second hold/fade lifecycle; latest eligible warning SHALL replace the previous one.

#### Scenario: Complete verdict
- **WHEN** a sample verdict has a long reason, estimated price and earn-back line
- **THEN** all fields are legible without clipping; missing price or icon is handled without inventing a zero price

#### Scenario: Replacement
- **WHEN** another eligible real warning arrives
- **THEN** the current visual is replaced without duplicate sound or presentation paths

#### Scenario: Tier content
- **WHEN** a skipped rank is displayed
- **THEN** the currently selected revision’s true reason is shown without adding a data-source label

### Requirement: Toast positioning and appearance
Toast Appearance SHALL offer independent background/text alpha (0–100 percent), scale (50–200 percent), Preview, Move and Reset position. Default alpha and scale SHALL be 100 percent. The default anchor SHALL be near the current warning location and clamped to screen. Transient toasts SHALL have no lock control; only explicit Move mode SHALL reposition them.

#### Scenario: No unnecessary lock
- **WHEN** toast controls are displayed
- **THEN** Move is available without an unlock prerequisite and no persistent toast-lock setting can block it

#### Scenario: Inactive values
- **WHEN** the user switches to Warning then back
- **THEN** toast position, alpha and scale retain their prior values

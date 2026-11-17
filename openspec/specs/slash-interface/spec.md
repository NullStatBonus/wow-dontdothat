# slash-interface Specification

## Purpose
The /ddt command surface: discoverable commands and help topics, /ddt log with its aliases, and a typed registry of public settings that /ddt get and /ddt set read and change safely.

## Requirements

### Requirement: Common command discovery
DDT SHALL expose settings [page], status [nudge|warnings|explanations|sound], help [appearance|rules|diagnostics], demo, preview [kind], typed get/set, debug on/off, log and log clear under both slash names. Bare commands SHALL open Home; help SHALL explain purpose and group commands. Existing test, probe, trainerids, revision and version commands SHALL remain valid. Names/search input SHALL retain case; only command words/enums SHALL be normalized.

#### Scenario: Page aliases
- **WHEN** settings receives home, watch, progress, appearance, warnings, explanations, sound, advanced, classes, debug or about
- **THEN** the named page/tab opens; unknown pages list choices without mutation

#### Scenario: Topics
- **WHEN** help or status is requested
- **THEN** help groups appearance/rules/diagnostics and documents demo; bare status prints a one-line summary of each status topic; status nudge reports effective scope and nudge/custom details; status warnings, explanations and sound report that area's current values

#### Scenario: Invalid syntax
- **WHEN** missing or surplus arguments or unsupported topics are supplied
- **THEN** targeted syntax and valid choices appear with no changes

### Requirement: Log primary command and aliases
`/ddt log` SHALL be the primary documented diagnostic report command. `/ddt export` SHALL remain an exact compatibility alias invoking the same report builder and window, without changing settings, savings or gameplay data and without clearing. Rank observations the report builder already records SHALL remain permitted. `/ddt log clear` SHALL confirm diagnostic-only clearing; existing `/ddt clear` SHALL retain immediate log-only clearing for compatibility and SHALL be labeled a legacy command.

#### Scenario: Equivalent report
- **WHEN** log and export run against the same state
- **THEN** both show the same full diagnostic report and copy window without changing settings, savings or gameplay data

#### Scenario: Cancel clear
- **WHEN** log clear is requested then cancelled
- **THEN** no diagnostics, settings or savings are cleared

#### Scenario: Legacy clear
- **WHEN** clear runs
- **THEN** only existing log entries are emptied immediately, without touching ledger, probe snapshots or settings

#### Scenario: Docs
- **WHEN** About, help, README or a debugging instruction is shown
- **THEN** log is the main report command and export is identified as a compatibility alias

### Requirement: Typed public setting registry
Public keys SHALL be independent of raw storage paths and declare type, bounds/enums, scope, getter, setter and refresh. UI and CLI SHALL use equivalent validation and effects. Get SHALL be read-only. Unknown keys, invalid values and surplus arguments SHALL not write. No arbitrary Lua evaluation SHALL be allowed. One successful setter SHALL print one concise acknowledgement.

#### Scenario: Derived nudge
- **WHEN** set nudge ask runs
- **THEN** the existing Nudge model updates its underlying flags/tiers; get returns the effective nudge rather than a separately stored value

#### Scenario: Invalid value
- **WHEN** set receives custom for nudge, an out-of-range alpha, fraction for integer or surplus input
- **THEN** nothing changes and allowed values/bounds are explained

#### Scenario: Profile values
- **WHEN** a valid public key changes
- **THEN** it affects only the active profile and triggers the same refresh as its UI control

### Requirement: Initial public settings
The initial public keys SHALL match the Public registry scenario. Existing saved values SHALL override defaults. Public setters SHALL reuse current model limits and canonical enum mappings; channel input MAY be case-insensitive but SHALL resolve to existing canonical channel names.

#### Scenario: Public registry
- **WHEN** a supported key is read or written
- **THEN** the following types, defaults and scopes apply:

| Key | Type / values | New-install default | Scope |
| --- | --- | --- | --- |
| enabled | on/off | on | profile |
| nudge | mark/ask/everything; get may return custom | ask | derived profile |
| watch.spells | on/off | on | profile |
| watch.professions | on/off | on | profile |
| watch.shopping | on/off | on | profile |
| alerts | on/off | on | profile |
| appearance.message | on/off | on | profile |
| appearance.warning-style | toast/warning | toast new; warning migrated | profile |
| appearance.chat | on/off | on | profile |
| appearance.toast.background-opacity | integer 0–100 | 100 | profile |
| appearance.toast.text-opacity | integer 0–100 | 100 | profile |
| appearance.toast.scale | integer 50–200 | 100 | profile |
| appearance.explanation.background-opacity | integer 0–100 | 100 | profile |
| appearance.explanation.text-opacity | integer 0–100 | 100 | profile |
| appearance.explanation.scale | integer 50–200 | 100 | profile |
| alert.cooldown | integer 1–30 seconds | 3 | profile |
| alert.channel | Master/SFX/Music/Ambience/Dialog | Master | profile |

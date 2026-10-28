## ADDED Requirements

### Requirement: Text goes through a locale table
The system SHALL show every player-facing sentence (settings, warnings, tooltips, alerts, slash command replies) from a locale table keyed by its English text. Debug report text SHALL stay English.

#### Scenario: English client
- **WHEN** the client locale has no translation file
- **THEN** every sentence reads exactly as the English text

#### Scenario: Translated client
- **WHEN** a locale file translates a sentence
- **THEN** that sentence is shown in the translation

### Requirement: Missing translations fall back to English
The system SHALL show the English text for any sentence a locale file does not translate, and SHALL NOT raise an error.

#### Scenario: Partial translation
- **WHEN** a locale file translates only some sentences
- **THEN** the translated ones show in that language and the rest show in English

### Requirement: A language is added by one file
The system SHALL load a locale from a single file named for the client locale, with no code change, and SHALL document how to add one.

#### Scenario: New locale file
- **WHEN** a contributor adds a file for a locale and the client runs in it
- **THEN** its translations are used

### Requirement: Format placeholders are protected
The system SHALL keep each sentence with its values as one translatable unit, and a translation SHALL carry the same placeholders as its English key. A test SHALL fail on a translation key the source does not use, or on a mismatched placeholder count.

#### Scenario: Placeholder mismatch
- **WHEN** a translation has a different number of placeholders than its key
- **THEN** the test suite fails and names the key

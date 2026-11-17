# Addon presentation and interaction design

Don't Do That (DDT)'s take on the shared presentation contract **v1**, documented on 2026-11-16 for version 0.12.0.

This document describes how DDT applies the design vocabulary that KeepThat (KT) documents in its own `DESIGN.md`. It covers settings, tooltips, warnings, previews and positioning. **Shared** means a common design vocabulary. It does not mean shared SavedVariables, a suite launcher or a required runtime library.

KT is the reference implementation. DDT adopts its principles and keeps what is its own: gameplay, purchase questions, warning tiers, defaults and persistence. Where DDT differs from KT on purpose, this document names the difference and the reason. The values below are code decisions. In-game checks are recorded in `openspec/changes/archive/2026-11-16-cohesive-addon-presentation/coverage.md`.

## 1. Product principles

1. **Explain each decision.** State the page purpose and the next action. Keep the text short.
2. **Stay recognizably native.** Use existing Blizzard and Ace controls, tooltip chrome and StaticPopup dialogs. Do not reskin the game or other addons.
3. **Keep the interface compact.** Size controls for their contents. Use the available width for readable explanations, not for oversized sliders and buttons.
4. **Use color for meaning.** Name the tier as well as coloring it. A red mark always says "Save your gold" in words.
5. **Only ever ask.** DDT never blocks a purchase. A question can always be answered yes, and every part of the addon can be turned off.
6. **Preserve player choices.** Disabled controls keep their values. Appearance changes do not reset gameplay choices. An upgrade keeps the look a player already had.
7. **Make experiments safe.** Previews use the real drawing code with isolated sample state. Move has an explicit save and rollback.
8. **Remain independently installable.** Missing APIs, fonts, icons or templates have a fallback. A failure to draw never stops a purchase safeguard.

### Help text

KT writes its help text to ASD-STE100. DDT follows the same goals: one instruction per sentence, active voice, short paragraphs, the same term for the same function, and labels that match the controls exactly.

**Difference:** DDT keeps a conversational voice, with contractions ("You won't need this until level 60."). That voice is part of the addon's identity, so KT's no-contraction rule does not apply. Keep sentences short and plain anyway.

| Context | DDT copy |
| --- | --- |
| Page purpose | "How warnings, explanations and the warning sound look and sound. What is warned about is set on Home and What to watch." |
| Addon purpose | "Keeps you from spending gold on things you don't need yet, so you can afford your level 40 and level 60 mounts." |
| Disabled feature | Name the reason and the control that turns it back on. |
| Active Move | "Drag the sample. Select Done to save. Select Cancel or press Escape to discard changes." |
| Move in combat | "Don't Do That: leave combat to move warnings." |
| Sample question | "This is a sample. Nothing will be bought." |
| Troubleshooting | Turn recording on with `/ddt debug on`. Repeat the problem. Open `/ddt log`. Press Ctrl+A, then Ctrl+C. |

## 2. Visual vocabulary

All dimensions are logical UI units at normal addon scale. The tokens live in `DontDoThat/UI/Helpers.lua`.

| Role | DDT value | Token |
| --- | --- | --- |
| Spacing base | 4 units | `SPACE` |
| Compact inset | 8 units | `PAD` |
| Content inset | 12 units | `CONTENT_PAD` |
| Section separation | 16 units | `SECTION` |
| Primary content | `#DDDDDD` | `INK.primary` |
| Supporting text | `#AAAAAA` | `INK.secondary` |
| Cost | Gold `(1, 0.82, 0)` | `INK.cost` |
| Persistent custom surface | Pure black, `#000000` | |
| Toast | 320 wide; height follows text | |
| Toast icon | 24 × 24 | |
| Pinned explanation | 300 wide; height follows text | |

### Typography

DDT uses client font objects. It ships no font. `UI/Style.lua` resolves each role, then falls back to the body font, then to the heading font, then to `Fonts\FRIZQT__.TTF` at a role size.

| Text role | DDT implementation |
| --- | --- |
| Settings body | AceConfig medium description → `GameFontHighlight` |
| Settings notes | AceConfig small description, supporting ink |
| Page title | AceConfig large description in the accent color |
| Section header | Native AceConfig header |
| Toast recommendation and detail | `GameFontHighlightSmall` (supporting) |
| Toast title | `GameFontHighlight` (body) |
| Warning banner | `GameFontNormalHuge` title, `GameFontNormalLarge` recommendation and detail |

Essential copy wraps and grows its surface. Nothing important depends on truncation or on a hover tooltip.

### Semantic color: tiers

DDT's colors are warning tiers. They are not category colors like KT's Endgame and Leveling.

| Tier | Label | Color | Meaning |
| --- | --- | --- | --- |
| `defer` | **Save your gold** | Red `(1, 0.2, 0.2)` | Wait. A sound plays and, by default, the addon asks before you buy. |
| `deferLow` | **Not worth buying yet** | Yellow `(1, 0.82, 0)` | Marked, but by default it never gets in your way. |
| `info` | **Optional** | Blue `(0.4, 0.7, 1.0)` | Handy now and then. Marked only. |
| `keep` | Keep | Green `(0.2, 0.9, 0.2)` | Never warned about. |

- Every colored surface also names the tier in words, so the tier reads without its color.
- The item or spell name stays neutral. Costs use the gold cost ink, and an estimated cost starts with `~`.
- The "Don't Do That:" chat prefix uses `|cffff3333`.
- Do not reuse the tier colors for unrelated states.

## 3. Settings window and control sizing

DDT keeps **AceConfig and AceGUI**, with a tree sidebar and a scrolling content pane.

| Element | DDT decision |
| --- | --- |
| Standalone initial window | **600 × 460** |
| Window title | **Don't Do That** |
| Navigation | Ace tree; Classes collapses on ordinary opens |
| Window behavior | Resizable; content scrolls |
| Appearance sliders and selects | 1.5 Ace control widths |
| Skip-list choice | Double width |
| Toggles with explanations | Full width, inline description |
| Body and notes | Full width; prose wraps |
| Nudge choice | Full-width radio group |

### Choosing a control

- A boolean uses a checkbox, a bounded number uses a slider, and a short fixed list (sound, channel, message style) uses a dropdown.
- The nudge level uses a radio group because each choice needs a sentence of explanation. A fourth choice, **Custom**, appears only when the saved settings match no preset. It describes what those settings do.
- Short actions (Preview, Move, Done, Cancel, Reset position, Open classes) are standard buttons, not full-width bars.

## 4. Page context and information architecture

Every page works when opened directly. Settings use the shared **Default** profile. DDT has no settings scope choice, so no page shows a scope notice. Ledger, cost cache and catalog are per character. Logs and probe data are global.

The reading order is: page title, a one- or two-sentence purpose, a section for each task, then current-state guidance where it changes the next action.

### Pages

| Order | Page | Purpose |
| --- | --- | --- |
| 1 | Home | Turn the addon on, pick how hard it nudges (Mark only, Ask, Ask about everything, or Custom), and choose what the messages do |
| 2 | What to watch | Spells, professions and shopping, the item kinds watched at vendors and the auction house, the minimum price, and the bank, stable and COD guards |
| 3 | Progress | Mount milestones, projected savings and the Tally of gold kept by waiting |
| 4 | Appearance | Tabs for Warnings, Explanations and Sound |
| 5 | Advanced | Tuning, Classes and Debug |
| 6 | About | Purpose, version, what the marks mean, how to use it, and commands |

The game's own options panel shows the Home controls on the root entry, not a placeholder. Its child entries are the other pages. Classes is too large for that panel, so Advanced there shows an **Open classes** button that opens the class list in the `/ddt` window.

### Appearance

Visual choices are kept apart from what is warned about.

1. **Warnings**: Message style (Toast or Warning), Also note warnings in chat, toast background opacity, text opacity and scale, Move and Reset position, and Preview.
2. **Explanations**: the pinned explanation's background opacity, text opacity and scale, and Preview.
3. **Sound**: Play a warning sound, the sound, the volume channel, seconds between warnings for the same thing, and a test button. The test button works even while sounds are off.

### Advanced

- **Tuning**: which tiers ask and warn, the level the advice stops at, and the skip list revision.
- **Classes**: one page for each class. It shows what is marked and why. Each rule has a toggle, so the player decides what they are told about.
- **Debug**: recording, the report and clearing. The steps are: record, repeat the problem, open the report, then Ctrl+A and Ctrl+C. Recording turns off at every login.

### About

About shows the name, version and purpose, then what each mark means, how to use the addon, and the common commands. Each command takes one row.

## 5. Warnings

DDT's warnings are about purchases, so they work differently from KT's loot toasts.

| Situation | What the player sees |
| --- | --- |
| A question is needed ("Ask before buying" is on and the tier asks) | DDT's "Buy anyway?" question, or the game's own dialog with DDT's warning added. No toast or banner. |
| No question | The chosen message style: **Toast** or **Warning** |
| Always (unless turned off) | One chat line: "Don't Do That: …" |
| A question cannot be shown | The chosen message style instead |

The checks run in this order: tier gate, then cooldown (3 seconds by default, per item or spell), then end any running samples, then the chat line. After that come the alerts toggle, the sound, and finally the toast or banner. Turning sounds off leaves the chat line. The chat line has its own toggle.

**Do not turn a question into a toast.** A question is the only place a purchase waits for the player. It keeps its buttons and stays until it is answered.

### Toast

| Part | Geometry and behavior |
| --- | --- |
| Panel | 320 wide; pure black background; height follows the text |
| Tier edge | 4 wide, full height, tier color |
| Icon | 24 × 24 at the content inset; the item or spell icon when known |
| Text | Recommendation (supporting), name and cost (body), reason (supporting) |
| Text column | Starts after the icon plus 8; ends 12 from the right |
| Default anchor | TOP, x = 0, y = −160 |
| Strata | HIGH for real warnings; TOOLTIP for samples and during Move |
| Lifetime | 2.5 seconds held, then a 1.5-second fade |
| Count | One at a time; a new warning replaces the one showing |
| Mouse | Ignores the mouse, except during Move |

**Differences from KT:**
- The toast is wider (320, not 280) because purchase reasons are longer than loot lines.
- There is no stack and no queue, because DDT has the per-item cooldown.
- The toast has no fade-in, so a purchase warning is readable at once.

### Warning banner

The **Warning** style is the large banner that DDT has always used. It is 700 × 80, centered 200 above the middle of the screen, at FULLSCREEN_DIALOG strata, with the tier label above the title. It is kept for players who prefer it. Profiles from before 0.12.0 keep it through a one-time upgrade (§6).

### Marks, tooltips and the pinned explanation

- An outlined **(i)** in the tier color marks a trainer row. Hovering it shows a native GameTooltip with the tier label, the reason and the cost. The tooltip has a minimum width of 230.
- Clicking the mark pins the explanation: a 300-wide black panel at TOOLTIP strata, beside the mark. It has a native close button, and Escape also closes it. The text wraps and the panel grows to fit.
- Item tooltips gain DDT's lines without rebuilding other rows.

### Dialogs and the report

- Questions and confirmations use StaticPopup. `/ddt log clear` has its own dialog, and Cancel or Escape keeps the log.
- The report is a standard AceGUI Frame titled "Don't Do That: log". It holds a fill-layout MultiLineEditBox, and its footer reads "Ctrl+A selects everything, then Ctrl+C copies it." Edits are undone. Escape closes the report. If the window cannot open, the report prints to chat in chunks.

## 6. Opacity, scale and upgrades

The toast and the pinned explanation have the same three controls, stored as percentages.

| Control | Units | Default |
| --- | --- | --- |
| Background opacity | Whole number 0–100 | 100 |
| Text and icon opacity | Whole number 0–100 | 100 |
| Scale | Whole number 50–200; 100 is normal | 100 |

Background opacity covers the panel and the tier edge. At zero, neither draws. Text opacity is separate. The fade multiplies both layers, and it is not a setting. The Move placeholder always draws at full opacity, so it can be found and dragged.

**Upgrades.** Before AceDB loads, DDT reads the raw saved data. A profile that existed before 0.12.0 and has no valid style gets **Warning** once. New and reset profiles get **Toast**. DDT checks the profile the character actually uses. A marker, `styleMarked`, records that the check ran. It has no default, so AceDB never strips it at logout, and Reset all settings keeps it. A saved alert entry that is not a table is dropped before load, so the defaults apply. A read-only `/ddt get` never writes.

## 7. Preview and demo fidelity

Previews draw through the same code as real warnings.

| Entry point | Output |
| --- | --- |
| Appearance > Warnings: Preview | One sample in the chosen style |
| Appearance > Explanations: Preview | One pinned sample explanation |
| `/ddt preview` | Lists toast, warning, mark, tooltip, explanation and prompt |
| `/ddt preview <kind>` | One sample of that kind |
| `/ddt demo` | Plays a sound, then shows a row of marks with a "Sample" caption, a hover tooltip and a sample question. Toasts follow at 2-second steps, with one explanation |
| `/ddt test` (legacy) | Still supported |

Every sample is gone within 10 seconds. A repeat replaces the samples and restarts the time.

### Sample set

The demo uses the same five real Mage spells every time. Each sample's tier, reason and trainer price match what the rule engine and `Data/TrainerPrices.lua` say for a level 20 to 40 Mage. `tests/demo_test.lua` checks them.

| Sample | Spell | Tier |
| --- | --- | --- |
| info | Slow Fall | Optional |
| deferLow | Frostbolt (Rank 4), as an Arcane Mage sees it | Not worth buying yet |
| defer | Portal: Stormwind | Save your gold |
| skip | Frost Nova (Rank 2) | Save your gold (skipped rank) |
| estimate | Frost Nova (Rank 3), estimated price | Save your gold (skipped rank) |

Every sample is labelled "Sample: <name>".

### Isolation

- Samples never buy, train, reset, mail or auction anything.
- Samples never write a setting, the ledger, the cooldowns or the once-only flags.
- The sample question is its own dialog, `DONTDOTHAT_SAMPLE`. Both of its buttons only close it.
- Each run takes a new generation number, and timers from an older run do nothing.
- A real warning or question ends the samples first. A sample explanation never replaces a real pinned one.
- Samples show even while the real feature is off. A preview never turns a feature on.

## 8. Transactional positioning

The terms are **Move**, **Done**, **Cancel** and **Reset position**.

| State or action | Result |
| --- | --- |
| Start Move | Shows a placeholder at the saved position, with Done and Cancel buttons (96 × 24 each) 8 below it |
| Start Move in combat | Refused, with "Don't Do That: leave combat to move warnings." |
| Drag | Changes only the tentative position |
| Done | Saves the clamped position, then leaves Move |
| Cancel or Escape | Discards the tentative position. Escape is caught by the placeholder, so it does not close the settings window or open the game menu |
| Entering combat during Move | Cancels the move |
| A real warning during Move | Cancels the move without saving, then shows the warning |
| Hiding the placeholder | Cancels the move |
| Reset position | Puts back only the anchor: TOP, 0, −160 |

The position is saved in UIParent units, so changing the scale does not move the toast. Other keys pass through to the game during Move.

**Difference from KT:** DDT has no Lock position. The toast takes the mouse only during Move, so there is nothing to lock.

## 9. Commands, settings parity and diagnostics

| Command | Purpose |
| --- | --- |
| `/ddt` | Open Home |
| `/ddt settings [page]` | Open a page: watch, progress, appearance, warnings, explanations, sound, advanced, classes, debug or about |
| `/ddt help [topic]` | Topics: appearance, rules, diagnostics |
| `/ddt status [topic]` | Topics: nudge, warnings, explanations, sound. Read-only |
| `/ddt get <key>` / `/ddt set <key> <value>` | Read or change a public setting |
| `/ddt preview [kind]` | List the sample kinds, or show one |
| `/ddt demo` | Show the sample tour |
| `/ddt debug on\|off` | Turn recording on or off |
| `/ddt log` | Open the copyable report. `/ddt export` is the same |
| `/ddt log clear` | Clear the log after a confirmation |

Legacy commands still work: `test`, `probe`, `trainerids`, `revision`, `version` and `clear`.

Commands and settings share one typed registry (`Core/Registry.lua`). The registry rejects unknown keys, invalid values, fractions, out-of-range numbers, missing arguments and extra input, and it writes nothing when it rejects. A successful set refreshes the same views that the matching control refreshes.

| Key | Values |
| --- | --- |
| `enabled`, `alerts` | on, off |
| `nudge` | mark, ask, everything |
| `watch.spells`, `watch.professions`, `watch.shopping` | on, off |
| `appearance.message`, `appearance.chat` | on, off |
| `appearance.warning-style` | toast, warning |
| `appearance.toast.background-opacity`, `.text-opacity` | 0–100 |
| `appearance.toast.scale` | 50–200 |
| `appearance.explanation.background-opacity`, `.text-opacity` | 0–100 |
| `appearance.explanation.scale` | 50–200 |
| `alert.cooldown` | 1–30 seconds |
| `alert.channel` | Master, SFX, Music, Ambience, Dialog |

The report includes every saved setting. It also lists the profile name, each public key's effective value, the toast position, whether a Move is in progress and whether samples are showing.

## 10. AddOns list identity

Both TOCs set `## IconTexture: Interface\AddOns\DontDoThat\Media\icon.tga`. The icon is a square 32-bit TGA with alpha.

## 11. Reuse boundaries and validation

DDT adopts the shared terms, tokens and interaction contracts locally. Its warning tiers, questions, cooldowns, defaults and Default-profile persistence stay its own. The Toast and Warning choice, and the question flow, are specified in DDT's own `openspec/specs/warning-presentation` and `warning-alerts`.

Implementation sources:

- [Tokens and pure helpers](DontDoThat/UI/Helpers.lua)
- [Fonts, buttons, surfaces and Escape](DontDoThat/UI/Style.lua)
- [Alert flow](DontDoThat/UI/Alert.lua)
- [Toast and Move](DontDoThat/UI/Toast.lua)
- [Warning banner](DontDoThat/UI/AlertBanner.lua)
- [Marks and pinned explanation](DontDoThat/UI/InfoBubble.lua)
- [Demo and previews](DontDoThat/UI/Demo.lua)
- [Settings pages](DontDoThat/Options/Options.lua)
- [Public setting registry](DontDoThat/Core/Registry.lua)
- [Slash commands](DontDoThat/Core/Slash.lua)
- [Report window](DontDoThat/Debug/Export.lua)
- [Style upgrade](DontDoThat/Model/Settings.lua)

Automated validation uses `make test`, `make check` and `openspec validate --strict`. The test harness loads the real AceDB and AceConfig. It covers the style upgrade through logout and relog, UI and command parity, sample isolation, Move rollback and the alert flow.

Before claiming visual acceptance, check on Classic Era and WoW Forever at matching UI scale (see `docs/test-plan.md`):

- Every page opened directly, from `/ddt` and from the game's options.
- The compact window, resizing and scrolling.
- Opacity at 0, 80 and 100, and scale at 100 and 150, for the toast and the explanation.
- Move with Done, Cancel and Escape, in and out of combat.
- Warnings at a trainer and a vendor: a question, a toast, the banner and the chat line.
- Samples while a real warning or a pinned explanation is showing.
- Home, Appearance, the toast and the report side by side with KeepThat and Closest Vendor.

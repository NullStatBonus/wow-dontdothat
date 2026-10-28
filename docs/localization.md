# Adding a language

The addon's own text is English. Spell names come from the game, so on a client in another language the trainer marks, the Rules page and the spell switches already work with that language's spell names. A translation file changes the addon's sentences: settings, warnings, tooltips and chat replies.

## How it works

Every sentence the player reads is written in the code as `L["English sentence"]`. English is the key, so a sentence without a translation shows as written and a missing entry never raises an error. A language is one file in `DontDoThat/Locales/` that assigns translations when the game runs in that locale.

## Steps

1. Copy `DontDoThat/Locales/Example.lua` to `DontDoThat/Locales/<locale>.lua`, using the game's locale name: `deDE`, `frFR`, `esES`, `esMX`, `itIT`, `ptBR`, `ruRU`, `koKR`, `zhCN`, `zhTW`.
2. Change `"xxXX"` on the `GetLocale()` line to that locale.
3. Add one line per sentence: `L["English sentence"] = "Your translation"`. Copy the English exactly, including punctuation, from the code or from `grep -rhoE 'L\["[^"]*"\]' DontDoThat --include='*.lua'`.
4. List the file in **both** `DontDoThat_Vanilla.toc` and `DontDoThat_Camelot.toc`, right after `Locales\enUS.lua`.
5. Run `luajit tests/run.lua locale` (or the whole suite). It fails if a key is not a sentence the code asks for, or if a translation has a different number of `%s`/`%d` than its English.

You do not have to translate everything. Anything you leave out shows in English.

## Rules for translators

- **Keep placeholders.** `%s` and `%d` are replaced with a name or a number. Keep the same count. When the order has to change, use positions: `"%2$s costs %1$s."`.
- **Keep markup.** A few sentences keep a color code or a leading marker outside the key, so the key is only the words. Do not add `|c...|r` codes to a translation.
- **Whole sentences.** Each key is a complete sentence so it can be reordered; do not split one.
- **Spell names** are not translated here. The game supplies them.
- **Debug text** (`/ddt export` and the debug log) stays English so reports are readable by everyone.

## Nothing is matched by English text

Spells, talents, professions, trainers and items are all recognised by ID, never by name, so every warning works on a client in any language. Only the addon's own sentences need translating.

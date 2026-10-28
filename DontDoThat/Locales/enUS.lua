local addonName, ns = ...

-- Every sentence the player reads is looked up as L["English sentence"]. English is the key, so a sentence with
-- no translation shows as written and a missing entry can never raise an error. To add a language, copy
-- Locales/Example.lua to Locales/<locale>.lua (see docs/localization.md) and list it in both TOC files.
ns.L = setmetatable({}, { __index = function(_, key) return key end })

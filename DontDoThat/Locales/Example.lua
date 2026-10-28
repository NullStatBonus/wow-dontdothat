local addonName, ns = ...

-- Template for a translation: copy this file to Locales/deDE.lua (or frFR, esES, ...), change the locale below,
-- translate the right-hand sides, and add the file to both TOC files after Locales\enUS.lua.
-- Keep every %s and %d in a translation, as many as the English has; a test checks the count.
-- Leave out any sentence you do not translate: it shows in English.
if type(GetLocale) ~= "function" or GetLocale() ~= "xxXX" then return end

local L = ns.L
-- L["Buy anyway?"] = "..."
-- L["Costs about %s"] = "..."

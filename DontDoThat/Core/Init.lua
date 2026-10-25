local addonName, ns = ...

ns.name = addonName

local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
-- Changes with each build, so /ddt version shows whether the game loaded the newest files.
ns.build = "2026-10-24b: reset dialogs, sound list"
ns.version = getMetadata and getMetadata(addonName, "Version") or "unknown"

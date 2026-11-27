local addonName, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")

local addon = AceAddon:NewAddon(addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
ns.addon = addon

ns.defaults = {
    profile = {
        enabled = true,
        blockingConfirmations = true,
        warnings = true,
        alerts = true,
        recommendedFilter = true,   -- the filter is offered (What to watch page)
        recommendedActive = true,   -- its checkbox in the trainer's Filter menu is ticked
        -- Where each kind of item is warned about: off | vendor | ah | both. Keys match Model/ItemCategory.lua.
        itemModes = {
            armor = "both", weapons = "both", vanity = "both",
            bags = "ah", recipes = "ah", potions = "ah", gems = "ah", food = "ah",
            trade = "ah", ammo = "ah", reagents = "ah",
            mounts = "off", misc = "off",
        },
        watch = { spells = true, professions = true, shopping = true }, -- the areas of What to watch
        guard = { bank = true, stable = true, cod = true, talent = true, pet = true }, -- one-click sinks asked about (What to watch page, Other)
        minPrice = 100,             -- copper; cheaper purchases are never warned about (1 silver)
        alert = {
            sound = "raidwarning",
            channel = "Master",
            banner = true,          -- show the on-screen message (Toast or Warning) when nothing asks
            style = "toast",        -- toast | warning; profiles from before the choice are set to warning once
            chat = true,            -- also note every warning in chat
            cooldown = 3,
        },
        -- Look of the small warning (Appearance > Warnings). Percentages; point is nil until moved.
        toast = { bgAlpha = 100, textAlpha = 100, scale = 100 },
        -- Look of the pinned explanation (Appearance > Explanations).
        explanation = { bgAlpha = 100, textAlpha = 100, scale = 100 },
        -- Rules the player switched off (Advanced > Classes). A present key means off, so rules added later are on.
        ruleOff = { abilities = {}, tags = {}, kinds = {} }, -- abilities/tags: class -> name -> true; kinds: kind -> true
        specOverride = {},          -- class -> spec key; absent means inferred from talents
        tuning = { stopAfter = 60, promptTiers = { defer = true, deferLow = false, info = false } },
        debug = false,
        traceItems = false,         -- keep a saved record of each vendor and auction decision (Debug page)
    },
    char = {
        ledger = {},
        costCache = {},
        catalog = {},
        milestoneOverride = {}, -- [40] / [60] = true: mounts this character marked as bought
        professionAsked = {},   -- profession ID -> true: asked once already on this character
        allowedItems = {},      -- item ID -> { name, icon }: never asked about on this character (Always Allow)
    },
    global = {
        log = {},
        probe = {},
        icons = {}, -- spell family ID -> icon, learned from trainer windows
        itemTrace = {}, -- recent vendor and auction decisions, shown by /ddt export
    },
}

function addon:OnInitialize()
    -- Read before AceDB fills in defaults: a saved database means this player used an older version.
    local before = ns.Settings and ns.Settings.StyleBefore(_G.DontDoThatDB)
    self.db = AceDB:New("DontDoThatDB", ns.defaults, true)
    ns.db = self.db
    self.styleBefore = before
    if ns.TestSettings then
        -- Before the game saves: the profile key names the player's own profile, never the temporary one.
        self.db.RegisterCallback(self, "OnDatabaseShutdown", function() ns.TestSettings.Shutdown(self.db) end)
        -- A profile switch made elsewhere (the Profiles page): one chat line, the pages redrawn, debug carried over.
        self.db.RegisterCallback(self, "OnProfileShutdown", function() self.debugFlags = { debug = self.db.profile.debug, traceItems = self.db.profile.traceItems } end)
        self.db.RegisterCallback(self, "OnProfileChanged", function()
            local deps = self:TestSettingsDeps()
            if not deps.busy then
                local p = self.db.profile
                -- A profile first used now is not an old one: mark it, so a later load keeps its alert style.
                if ns.Settings then ns.Settings.ClassifyStyle(p, nil, self.db:GetCurrentProfile()) end
                if self.debugFlags then p.debug, p.traceItems = self.debugFlags.debug, self.debugFlags.traceItems end
            end
            ns.TestSettings.ProfileChanged(self.db, deps)
        end)
        -- A reset profile is not an old one either (Reset clears the marks).
        self.db.RegisterCallback(self, "OnProfileReset", function()
            if ns.Settings then ns.Settings.ClassifyStyle(self.db.profile, nil, self.db:GetCurrentProfile()) end
        end)
    end
    -- Before anything reads db.char or classifies the profile: follow a change of the character key.
    if ns.Settings and ns.Adapter then
        local okKeys, keys = pcall(ns.Adapter.ReadCharKeys, _G)
        if okKeys then pcall(ns.Settings.MigrateCharKeys, self.db.sv, self.db, keys) end
    end
    if ns.Settings then
        local ok, name = pcall(self.db.GetCurrentProfile, self.db)
        ns.Settings.ClassifyStyle(self.db.profile, before, ok and name or nil)
    end
    if ns.Settings then ns.Settings.ClearDebug(self.db.profile) end
    if ns.Tally then ns.Tally.Init(self.db) end

    if ns.Log then
        ns.Log.Init(self.db.global.log, { printer = function(msg) self:Print(msg) end })
        ns.Log.SetEnabled(self.db.profile.debug)
    end
    if ns.Probe then
        ns.Probe.Init(self.db.global.probe)
    end
    if ns.Export then
        ns.Export.sourceProvider = function()
            return {
                settings = self.db.profile,
                profileName = (function()
                    local ok, name = pcall(self.db.GetCurrentProfile, self.db)
                    return ok and name or nil
                end)(),
                testSettings = ns.TestSettings and ns.TestSettings.IsOn(self.db) and ns.TestSettings.OwnProfile(self.db) or nil,
                checkThat = ns.CheckThat and ns.CheckThat.Status() or nil,
                ledger = self.db.char.ledger,
                log = ns.Log and ns.Log.Entries() or {},
                items = function() return ns.ItemGuard and ns.ItemGuard.Report(_G) or nil end,
                probe = function() return ns.Probe.Run(nil, self.db.global.probe) end,
                presentation = function()
                    return {
                        "moving toast: " .. tostring(ns.Toast and ns.Toast.IsMoving and ns.Toast.IsMoving() or false),
                        "samples showing: " .. tostring(ns.Demo and ns.Demo.Active and ns.Demo.Active() or false),
                        "mounts marked bought (this character): " .. (function()
                            local o = self.db.char.milestoneOverride or {}
                            local t = {}
                            if o[40] then t[#t + 1] = "40" end
                            if o[60] then t[#t + 1] = "60" end
                            return #t > 0 and table.concat(t, ", ") or "none"
                        end)(),
                    }
                end,
            }
        end
    end
end

-- What the test-settings logic needs from the game and the addon (Model/TestSettings.lua).
function addon:TestSettingsDeps()
    if self.testDeps then return self.testDeps end
    self.testDeps = {
        say = function(msg) self:Print(msg) end,
        log = function(msg) if ns.Log then ns.Log.Add("%s", msg) end end,
        -- The temporary profile is marked as migrated, so the next load sets no alert style and prints no notice.
        mark = function(p)
            p.styleMarked = true
            local newest = ns.SkipRevision and ns.SkipRevision.Newest()
            if newest and ns.Settings then ns.Settings.MarkRevisionNotice(newest, p) end
        end,
        closeUi = function()
            if ns.ConfirmPopup and ns.ConfirmPopup.Close then ns.ConfirmPopup.Close() end
            if ns.Demo and ns.Demo.End then ns.Demo.End() end
        end,
        refresh = function() if ns.Options then ns.Options.Refresh() end end,
        syncDebug = function() if ns.Log then ns.Log.SetEnabled(self.db.profile.debug) end end,
    }
    return self.testDeps
end

function addon:OnEnable()
    -- Test settings left on by an earlier session end here, before anything reads the profile: the player's own
    -- profile comes back unless a CheckThat run is open. CheckThat loads after this addon, so it is asked now.
    if ns.TestSettings then
        local runOpen = ns.CheckThat and ns.CheckThat.RunOpen() or false
        local result = ns.TestSettings.LoginAnnounce(self.db, self:TestSettingsDeps(), runOpen)
        if (result == "removed" or result == "restored") and ns.Settings then
            -- The profile now in use was not the one classified at load.
            local p = self.db.profile
            ns.Settings.ClassifyStyle(p, self.styleBefore, self.db:GetCurrentProfile())
            ns.Settings.ClearDebug(p)
            if ns.Log then ns.Log.SetEnabled(false) end
        end
    end
    if ns.Settings then
        ns.Settings.MigrateCharMarks(self.db.char, self.db.profile, ns.Adapter.ReadPlayer(_G).level)
        ns.Settings.MigrateFamilyIds(self.db.profile, self.db.char)
    end
    if ns.Options then ns.Options.Register(self) end
    if ns.TrainerFilter then ns.TrainerFilter.Enable(_G) end
    if ns.Resets then ns.Resets.Enable(LibStub("AceEvent-3.0"):Embed({}), _G) end
    if ns.Merchant then ns.Merchant.Enable(LibStub("AceEvent-3.0"):Embed({}), _G) end
    if ns.Auction then ns.Auction.Enable(_G) end
    if ns.TrainerOverlay then
        -- Its own event object: AceEvent keeps one handler per event per object, and the
        -- debug capture below registers the same trainer events on the addon itself.
        ns.TrainerOverlay.Enable(LibStub("AceEvent-3.0"):Embed({}), _G)
    end
    if ns.Capture then
        ns.Capture.Enable(self, _G, self.db.global.probe)
    end
    if ns.CheckThat then
        local TS = ns.TestSettings
        ns.CheckThat.Start({
            version = function() return ns.Adapter.readVersion(_G) end,
            testSettings = function() return TS.IsOn(self.db) end,
            setting = function(key)
                local v = ns.Registry.Get(key, self.db.profile)
                return v
            end,
            char = function(key)
                if key == "allowed" then
                    local n = 0
                    for _ in pairs(self.db.char.allowedItems or {}) do n = n + 1 end
                    return n
                end
                local o, t = self.db.char.milestoneOverride or {}, {}
                if o[40] then t[#t + 1] = "40" end
                if o[60] then t[#t + 1] = "60" end
                return #t > 0 and table.concat(t, ", ") or "none"
            end,
            log = function(msg) if ns.Log then ns.Log.Add("%s", msg) end end,
            runStarted = function(runId) TS.OnRunStarted(self.db, self:TestSettingsDeps(), runId) end,
            runEnded = function(reason) TS.OnRunEnded(self.db, self:TestSettingsDeps(), reason) end,
            runGone = function() TS.OnRunGone(self.db, self:TestSettingsDeps()) end,
        })
    end
    -- Once per profile: which skip list is in use, that the newest one changed the rules, and how to change it.
    if ns.SkipRevision then
        local lines = ns.SkipRevision.Notice(self.db.profile)
        for _, line in ipairs(lines or {}) do self:Print(line) end
    end
end

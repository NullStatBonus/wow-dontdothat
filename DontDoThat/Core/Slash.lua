local addonName, ns = ...
local L = ns.L

local addon = ns.addon

local function say(msg)
    addon:Print(msg)
end

local PAGES = { "home", "watch", "progress", "appearance", "warnings", "explanations", "sound", "advanced", "classes", "debug", "about" }
local STATUS_TOPICS = { "nudge", "warnings", "explanations", "sound" }
local HELP_TOPICS = { "appearance", "rules", "diagnostics" }
local PREVIEW_KINDS = { "toast", "warning", "mark", "tooltip", "explanation", "prompt" }

local function choices(list) return table.concat(list, ", ") end

local function oneOf(list, word)
    word = (word or ""):lower()
    for _, v in ipairs(list) do if v == word then return v end end
end

local function onOff(v) return v and "on" or "off" end

local function openPage(self, page)
    if ns.Options and ns.Options.Open then
        ns.Options.Open(page)
    elseif type(self.OpenOptions) == "function" then
        self:OpenOptions()
    else
        say(L["settings not available yet"])
    end
end

-- Its own dialog, so asking never cancels an open purchase question (the shared popup cancels the previous one).
local LOG_CLEAR = "DONTDOTHAT_LOG_CLEAR"
local function askClearLog(text, onYes, onNo)
    if type(_G.StaticPopup_Show) ~= "function" or type(_G.StaticPopupDialogs) ~= "table" then return false end
    if not _G.StaticPopupDialogs[LOG_CLEAR] then
        _G.StaticPopupDialogs[LOG_CLEAR] = {
            text = "%s",
            button1 = _G.ACCEPT or L["Accept"],
            button2 = _G.CANCEL or L["Cancel"],
            OnAccept = function(_, data) if data and data.yes then data.yes() end end,
            OnCancel = function(_, data) if data and data.no then data.no() end end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end
    local ok, dialog = pcall(_G.StaticPopup_Show, LOG_CLEAR, text, nil, { yes = onYes, no = onNo })
    return ok and dialog ~= nil
end

local function value(key, p)
    return (ns.Registry.Get(key, p))
end

-- Status lines per topic. Each reads current values and changes nothing.
local function statusLines(topic, p)
    local R = ns.Registry
    if topic == "nudge" then
        local n = ns.Settings.Nudge(p)
        local lines = { L["Nudge: %s (active profile)."]:format(n) }
        if n == "custom" then
            local t = ns.Settings.PromptTiers(p)
            lines[#lines + 1] = L["Custom: warnings %s, ask before buying %s, ask about expensive %s, low-value %s, informational %s."]:format(
                onOff(p.warnings ~= false), onOff(p.blockingConfirmations ~= false),
                onOff(t.defer), onOff(t.deferLow), onOff(t.info))
        end
        return lines
    elseif topic == "warnings" then
        return { L["Warnings: alerts %s, message %s, style %s, chat record %s, toast background %s text %s scale %s."]:format(
            value("alerts", p), value("appearance.message", p), value("appearance.warning-style", p), value("appearance.chat", p),
            value("appearance.toast.background-opacity", p), value("appearance.toast.text-opacity", p), value("appearance.toast.scale", p)) }
    elseif topic == "explanations" then
        return { L["Explanations: background %s text %s scale %s."]:format(
            value("appearance.explanation.background-opacity", p), value("appearance.explanation.text-opacity", p),
            value("appearance.explanation.scale", p)) }
    else
        local a = p.alert or {}
        return { L["Sound: alerts %s, sound %s, channel %s, cooldown %s seconds."]:format(
            value("alerts", p), tostring(a.sound), value("alert.channel", p), value("alert.cooldown", p)) }
    end
end

local function helpLines(topic)
    if topic == "appearance" then
        return {
            L["Appearance: how warnings look and sound."],
            L["/ddt settings appearance | warnings | explanations | sound  open that page"],
            L["/ddt set appearance.warning-style toast|warning, appearance.message on|off, appearance.chat on|off"],
            L["/ddt set appearance.toast.scale 50-200 (also background-opacity, text-opacity 0-100; same under appearance.explanation)"],
            L["/ddt demo  show a sample; /ddt preview [toast|warning|mark|tooltip|explanation|prompt]"],
        }
    elseif topic == "rules" then
        return {
            L["Rules: what Don't Do That watches and how firmly it nudges."],
            L["/ddt set nudge mark|ask|everything; /ddt set watch.spells|watch.professions|watch.shopping on|off"],
            L["/ddt revision [number]  show or pick the skip list revision; /ddt test  dry run of a purchase"],
            L["/ddt settings watch | progress | advanced | classes"],
        }
    elseif topic == "diagnostics" then
        return {
            L["Diagnostics: for bug reports."],
            L["/ddt log  open the copyable report (/ddt export is the same, kept for compatibility)"],
            L["/ddt log clear  ask, then empty the diagnostic log; /ddt clear  legacy, empties it at once"],
            L["/ddt debug on|off; /ddt probe; /ddt trainerids [hover]; /ddt version"],
        }
    end
    return {
        L["Don't Do That v%s warns before you buy what you can wait on."]:format(tostring(ns.version)),
        L["/ddt  open settings; /ddt settings [page]; pages: %s"]:format(choices(PAGES)),
        L["/ddt status [%s]; /ddt get [key]; /ddt set <key> <value>"]:format(table.concat(STATUS_TOPICS, "|")),
        L["/ddt help [%s]  groups of commands"]:format(choices(HELP_TOPICS)),
        L["/ddt demo; /ddt preview [kind]; /ddt log; /ddt log clear; /ddt debug on|off"],
    }
end

function addon:HandleSlash(input)
    local words = {}
    for w in (input or ""):gmatch("%S+") do words[#words + 1] = w end
    local cmd = (table.remove(words, 1) or ""):lower()
    local n = #words
    local arg1 = words[1]
    local rest = table.concat(words, " "):lower()
    local p = self.db and self.db.profile

    local function surplus(max, usage)
        if n > max then
            say(usage)
            return true
        end
    end

    if cmd == "" then
        openPage(self, "home")
    elseif cmd == "settings" then
        if surplus(1, L["usage: /ddt settings [page]"]) then return end
        if arg1 == nil then return openPage(self, "home") end
        local page = oneOf(PAGES, arg1)
        if not page then say(L["Unknown page '%s'. Pages: %s."]:format(arg1, choices(PAGES))) return end
        openPage(self, page)
    elseif cmd == "status" then
        if surplus(1, L["usage: /ddt status [%s]"]:format(table.concat(STATUS_TOPICS, "|"))) then return end
        if not p then say(L["settings not available yet"]) return end
        if arg1 == nil then
            for _, t in ipairs(STATUS_TOPICS) do say(statusLines(t, p)[1]) end
            return
        end
        local topic = oneOf(STATUS_TOPICS, arg1)
        if not topic then say(L["Unknown status topic '%s'. Topics: %s."]:format(arg1, choices(STATUS_TOPICS))) return end
        for _, line in ipairs(statusLines(topic, p)) do say(line) end
    elseif cmd == "help" then
        if surplus(1, L["usage: /ddt help [%s]"]:format(table.concat(HELP_TOPICS, "|"))) then return end
        local topic
        if arg1 then
            topic = oneOf(HELP_TOPICS, arg1)
            if not topic then say(L["Unknown help topic '%s'. Topics: %s."]:format(arg1, choices(HELP_TOPICS))) return end
        end
        for _, line in ipairs(helpLines(topic)) do say(line) end
    elseif cmd == "get" then
        if surplus(1, L["usage: /ddt get [key]"]) then return end
        if arg1 == nil then
            say(L["Settings: %s"]:format(choices(ns.Registry.Keys())))
            return
        end
        local v, err = ns.Registry.Get(arg1, p)
        say(v and ("%s = %s"):format(arg1:lower(), v) or err)
    elseif cmd == "set" then
        if n ~= 2 then say(L["usage: /ddt set <key> <value>; /ddt get lists the keys"]) return end
        local v, e = ns.Registry.Set(arg1, words[2], p)
        if not v then say(e) return end
        say(L["%s set to %s."]:format(arg1:lower(), v))
        ns.Registry.Refresh(e)
    elseif cmd == "demo" then
        if surplus(0, L["usage: /ddt demo"]) then return end
        if ns.Demo and ns.Demo.Run then ns.Demo.Run() else say(L["demo not available yet"]) end
    elseif cmd == "preview" then
        if surplus(1, L["usage: /ddt preview [%s]"]:format(table.concat(PREVIEW_KINDS, "|"))) then return end
        local kind = arg1 and oneOf(PREVIEW_KINDS, arg1)
        if arg1 and not kind then say(L["Unknown preview '%s'. Kinds: %s."]:format(arg1, choices(PREVIEW_KINDS))) return end
        if not kind then say(L["Previews: %s"]:format(choices(PREVIEW_KINDS))) return end
        if ns.Demo and ns.Demo.Preview then ns.Demo.Preview(kind) else say(L["demo not available yet"]) end
    elseif cmd == "debug" then
        if n ~= 1 or (rest ~= "on" and rest ~= "off") then
            say(L["usage: /ddt debug on|off"])
            return
        end
        local on = (rest == "on")
        if p then
            p.debug = on
        end
        if ns.Log then
            ns.Log.SetEnabled(on)
        end
        say("debug " .. rest)
    elseif cmd == "clear" then
        -- Legacy: empties the log at once. /ddt log clear asks first.
        if ns.Log and type(ns.Log.ClearAll) == "function" then
            ns.Log.ClearAll()
            say(L["log cleared"])
        else
            say(L["log not available yet"])
        end
    elseif cmd == "log" or cmd == "export" then
        if cmd == "export" and surplus(0, L["usage: /ddt export (same as /ddt log)"]) then return end
        if cmd == "log" and surplus(1, L["usage: /ddt log [clear]"]) then return end
        if arg1 == nil then
            if ns.Export and type(ns.Export.Show) == "function" then
                ns.Export.Show()
            else
                say(L["export not available yet"])
            end
        elseif arg1:lower() == "clear" then
            if not (ns.Log and type(ns.Log.ClearAll) == "function") then say(L["log not available yet"]) return end
            local asked = askClearLog(
                L["Empty the Don't Do That diagnostic log? Settings and savings are not touched."],
                function() ns.Log.ClearAll(); say(L["log cleared"]) end,
                function() say(L["log kept"]) end)
            if not asked then say(L["Cannot ask here. Use /ddt clear (legacy) to empty the log at once."]) end
        else
            say(L["usage: /ddt log [clear]"])
        end
    elseif cmd == "probe" then
        if ns.Probe and ns.Export then
            ns.Export.Show({ probe = function() return ns.Probe.Run(nil, self.db and self.db.global.probe) end })
        else
            say(L["probe not available yet"])
        end
    elseif cmd == "trainerids" then
        -- With a trainer window open: can the addon get a spell ID for each row? Shows what every known method returns.
        if ns.Probe and ns.Export then
            local function show(withHover)
                ns.Export.Show({ probe = function()
                    local text = ns.Probe.TrainerIds()
                    if withHover then text = text .. "\n\n== hovered row ==\n" .. ns.Probe.HoveredSpell() end
                    return text
                end })
            end
            if rest == "hover" and _G.C_Timer then
                say("hover over a trainer row now; the report opens in 5 seconds")
                _G.C_Timer.After(5, function() show(true) end)
            else
                show(false)
            end
        else
            say("probe not available yet")
        end
    elseif cmd == "test" then
        -- Acts like a purchase of a deferred spell with your current settings, but buys nothing.
        say(L["test (build %s)"]:format(tostring(ns.build)))
        if ns.TrainerConfirm then ns.TrainerConfirm.Test(say) else say(L["test: not available yet"]) end
    elseif cmd == "revision" then
        -- The skip list revision: show it, or pick one. (rest was lowercased above; a number is unaffected.)
        for _, line in ipairs(ns.SkipRevision.Command(rest, self.db and self.db.profile)) do say(line) end
        if ns.Options and ns.Options.Rebuild and rest ~= "" then pcall(ns.Options.Rebuild) end
    elseif cmd == "version" then
        say(L["Don't Do That v%s (build %s)"]:format(tostring(ns.version), tostring(ns.build)))
    else
        say(L["Don't Do That v%s"]:format(tostring(ns.version)))
        say(L["usage: /ddt [settings [page] | status [topic] | help [topic] | get | set | demo | preview | log [clear] | debug on|off | test | probe | revision [number] | trainerids [hover]]"])
    end
end

addon:RegisterChatCommand("ddt", "HandleSlash")
addon:RegisterChatCommand("dontdothat", "HandleSlash")

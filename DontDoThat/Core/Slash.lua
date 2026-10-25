local addonName, ns = ...

local addon = ns.addon

local function say(msg)
    addon:Print(msg)
end

function addon:HandleSlash(input)
    local cmd, rest = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()
    rest = (rest or ""):lower()

    if cmd == "" then
        if type(self.OpenOptions) == "function" then
            self:OpenOptions()
        else
            say("settings not available yet")
        end
    elseif cmd == "debug" then
        if rest ~= "on" and rest ~= "off" then
            say("usage: /ddt debug on|off")
            return
        end
        local on = (rest == "on")
        if self.db and self.db.profile then
            self.db.profile.debug = on
        end
        if ns.Log then
            ns.Log.SetEnabled(on)
        end
        say("debug " .. rest)
    elseif cmd == "clear" then
        if ns.Log and type(ns.Log.ClearAll) == "function" then
            ns.Log.ClearAll()
            say("log cleared")
        else
            say("log not available yet")
        end
    elseif cmd == "probe" then
        if ns.Probe and ns.Export then
            ns.Export.Show({ probe = function() return ns.Probe.Run(nil, self.db and self.db.global.probe) end })
        else
            say("probe not available yet")
        end
    elseif cmd == "export" then
        if ns.Export and type(ns.Export.Show) == "function" then
            ns.Export.Show()
        else
            say("export not available yet")
        end
    elseif cmd == "test" then
        -- Acts like a purchase of a deferred spell with your current settings, but buys nothing.
        say("test (build " .. tostring(ns.build) .. ")")
        if ns.TrainerConfirm then ns.TrainerConfirm.Test(say) else say("test: not available yet") end
    elseif cmd == "version" then
        say("Don't Do That v" .. tostring(ns.version) .. " (build " .. tostring(ns.build) .. ")")
    else
        say("Don't Do That v" .. tostring(ns.version))
        say("usage: /ddt [debug on|off | clear | probe | export | test]")
    end
end

addon:RegisterChatCommand("ddt", "HandleSlash")
addon:RegisterChatCommand("dontdothat", "HandleSlash")

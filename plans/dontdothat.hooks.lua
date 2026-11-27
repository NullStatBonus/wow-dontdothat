-- What the replay does for the steps whose check reads DontDoThatDB.global.log.enabled.
-- The replay cannot write a state check, so the hook turns debug on the way the addon does.
local function debugOn(R)
    local env = R.App.env
    env.DontDoThatDB = env.DontDoThatDB or {}
    local g = env.DontDoThatDB.global or {}; env.DontDoThatDB.global = g
    local log = g.log or {}; g.log = log
    log.enabled = true
    log.entries = log.entries or {}
    log.entries[#log.entries + 1] = { t = 0, msg = "debug log turned on" }
end

return {
    action = {
        ["ddt.f.4"] = function(R)
            debugOn(R)
            assert(R.App.AutoSettle(), "the debug check settles")
        end,
    },
}

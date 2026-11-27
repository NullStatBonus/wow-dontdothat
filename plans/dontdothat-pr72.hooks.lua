-- What the replay does for ddt.pr72.8, whose check reads DontDoThatDB.global.log.enabled.
-- The replay cannot write a state check, so the hook turns debug on the way the addon does.
return {
    action = {
        ["ddt.pr72.8"] = function(R)
            local env = R.App.env
            env.DontDoThatDB = env.DontDoThatDB or {}
            local g = env.DontDoThatDB.global or {}; env.DontDoThatDB.global = g
            local log = g.log or {}; g.log = log
            log.enabled = true
            assert(R.App.AutoSettle(), "the debug check settles")
        end,
    },
}

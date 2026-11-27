local _, ns = ...
local L = ns.L

-- Test settings (spec checkthat-integration): the character switches to a temporary AceDB profile with default
-- settings, and its own profile is put aside, untouched. Pure logic over an AceDB object `db`; the game is not
-- read here. opts: log(msg) writes a debug line, mark(profile) marks the temporary profile as already migrated.
--
-- The record db.char.testSettings = { profile = <the player's own profile>, runId = <the run that owns it> } exists
-- only while the mode is on. The saved file never names the temporary profile: Shutdown writes the own profile
-- back to the profile key, so a downgrade, a removed CheckThat or a crash leave the player on their own profile.
local TS = {}
ns.TestSettings = TS

TS.PROFILE = "DDT test" -- short and fixed; AceDB limits a profile name to 50 characters
TS.FALLBACK = "Default"

local function record(db)
  local r = db and db.char and db.char.testSettings
  return type(r) == "table" and r or nil
end

local function noop() end

-- The own profile a record names, or the default profile when it names nothing usable (never the temporary one).
local function ownOf(r)
  local name = r and r.profile
  if type(name) ~= "string" or name == "" or #name > 50 or name == TS.PROFILE then return TS.FALLBACK end
  return name
end

function TS.IsOn(db) return record(db) ~= nil end

-- The profile in use, and whether it is the temporary one.
function TS.Current(db)
  local ok, name = pcall(db.GetCurrentProfile, db)
  name = ok and name or nil
  return name, name == TS.PROFILE
end

-- The player's own profile name while the mode is on, else the profile in use.
function TS.OwnProfile(db)
  local r = record(db)
  if r then return ownOf(r) end
  return (TS.Current(db))
end

-- Debug recording is for one session and stays on across a switch.
local function carry(flags, p)
  if type(p) == "table" and flags then p.debug, p.traceItems = flags.debug, flags.traceItems end
end

local function flagsOf(db)
  local p = db.profile
  return { debug = p and p.debug or false, traceItems = p and p.traceItems or false }
end

-- Switches to the temporary profile and resets it. Returns "on" or "reset", or nil and the reason (nothing changed).
local function enter(db, opts, runId)
  local r = record(db)
  local cur = TS.Current(db)
  local status = r and "reset" or "on"
  local flags = flagsOf(db)
  if r then
    if runId ~= nil then r.runId = runId end
  else
    -- A temporary profile in use with no record is a leftover: the player's own profile is the default one.
    db.char.testSettings = { profile = (cur == TS.PROFILE) and TS.FALLBACK or cur, runId = runId }
  end
  local ok, err = pcall(function()
    db:SetProfile(TS.PROFILE)
    db:ResetProfile()
  end)
  if not ok then
    if status == "on" then db.char.testSettings = nil end
    return nil, tostring(err)
  end
  if opts.mark then opts.mark(db.profile) end
  carry(flags, db.profile)
  return status
end

-- Switches back to the own profile and deletes the temporary one. No log. Returns true, or nil and the reason.
local function leave(db)
  local r = record(db)
  if not r then return false end
  local flags = flagsOf(db)
  db.char.testSettings = nil -- first, so callbacks fired by the switch already see the mode off
  local ok, err = pcall(db.SetProfile, db, ownOf(r))
  if not ok then
    db.char.testSettings = r
    return nil, tostring(err)
  end
  carry(flags, db.profile)
  pcall(db.DeleteProfile, db, TS.PROFILE, true) -- a leftover profile is harmless; the next Off removes it
  return true
end

-- Turns the mode on (or resets it when it is on). Returns "on" or "reset", or nil and the reason.
function TS.On(db, opts, runId)
  opts = opts or {}
  local log = opts.log or noop
  local status, err = enter(db, opts, runId)
  if not status then
    log("test settings: FAILED: " .. tostring(err))
    return nil, err
  end
  log(status == "on" and "test settings: on (own settings put aside)" or "test settings: reset to defaults")
  return status
end

-- Turns the mode off. Returns true, false when it was not on, or nil and the reason.
function TS.Off(db, opts)
  opts = opts or {}
  local log = opts.log or noop
  local done, err = leave(db)
  if done then log("test settings: off (own settings restored)")
  elseif done == nil then log("test settings: FAILED: " .. tostring(err)) end
  return done, err
end

-- At login, before anything reads the profile. runOpen: a CheckThat run is open. Returns "kept" (still on, the run
-- is open), "restored" (the own profile is back), "removed" (a leftover temporary profile with no record is gone)
-- or nil (nothing to do).
function TS.Login(db, opts, runOpen)
  opts = opts or {}
  local log = opts.log or noop
  local r = record(db)
  local cur, temporary = TS.Current(db)
  if r then
    if runOpen then
      if not temporary then pcall(db.SetProfile, db, TS.PROFILE) end -- Shutdown wrote the own profile back
      if opts.mark then opts.mark(db.profile) end
      if opts.sync then pcall(opts.sync) end -- debug is on again before the line is written
      log("test settings: on at login")
      return "kept"
    end
    if leave(db) then
      log("test settings: restored at login")
      return "restored"
    end
    return nil
  end
  if temporary then
    local ok = pcall(db.SetProfile, db, TS.FALLBACK)
    if ok then
      pcall(db.DeleteProfile, db, TS.PROFILE, true)
      log("test settings: temporary profile removed at login")
      return "removed"
    end
  end
  return nil
end

-- A run started. The run owns the mode: the same run id changes nothing, a new one resets it.
function TS.RunStarted(db, opts, runId)
  opts = opts or {}
  local log = opts.log or noop
  if runId == nil then
    log("test settings: run start without an id")
    return "ignored"
  end
  local r = record(db)
  if r and r.runId == runId then
    log("test settings: run already seen")
    return "seen"
  end
  if r then
    log("test settings: another run started")
    local status, err = enter(db, opts, runId)
    if not status then log("test settings: FAILED: " .. tostring(err)) return nil, err end
    return status
  end
  return TS.On(db, opts, runId)
end

-- A run ended: the mode goes off, or nothing changes when it was off.
function TS.RunEnded(db, opts, reason)
  opts = opts or {}
  local log = opts.log or noop
  log("test settings: run ended: " .. tostring(reason))
  if record(db) then return TS.Off(db, opts) end
  return false
end

-- Before the game saves: the saved profile key names the player's own profile, never the temporary one.
function TS.Shutdown(db)
  local r = record(db)
  local sv = db and db.sv
  local char = db and db.keys and db.keys.char
  if r and type(sv) == "table" and type(sv.profileKeys) == "table" and char then
    sv.profileKeys[char] = ownOf(r)
  end
end

---- Chat lines and the controller ------------------------------------------------------------------------
-- Every line names the profile in use and says whether it is the player's own or temporary.

-- kind: "login", "changed", "on", "reset", "off", "notOn", "restored" or "kept".
function TS.Line(kind, db)
  local cur, temporary = TS.Current(db)
  cur = tostring(cur)
  if kind == "login" then
    return (temporary and L["Profile in use: %s (temporary)."] or L["Profile in use: %s (your own)."]):format(cur)
  elseif kind == "changed" then
    return (temporary and L["Profile changed. Profile in use: %s (temporary)."] or L["Profile changed. Profile in use: %s (your own)."]):format(cur)
  elseif kind == "on" then
    return L["Test settings on. Profile in use: %s (temporary, default settings). Your own profile %s is put aside. Type /ddt testsettings off to go back to it."]:format(cur, TS.OwnProfile(db))
  elseif kind == "reset" then
    return L["Test settings reset to defaults. Profile in use: %s (temporary). Your own profile %s is still put aside."]:format(cur, TS.OwnProfile(db))
  elseif kind == "off" then
    return L["Test settings off. Profile in use: %s (your own). The temporary profile is deleted."]:format(cur)
  elseif kind == "notOn" then
    return L["Test settings are not on. Profile in use: %s (your own)."]:format(cur)
  elseif kind == "restored" then
    return L["Test settings were left on. Profile in use: %s (your own). The temporary profile is deleted."]:format(cur)
  elseif kind == "kept" then
    return L["Test settings are still on for the open run. Profile in use: %s (temporary)."]:format(cur)
  end
end

-- deps: say(msg) chat, log(msg) debug log, mark(profile), closeUi() closes open questions and previews, refresh() redraws
-- the settings pages, syncDebug() applies the profile's debug flag to the log. deps.busy is set while this module
-- switches the profile, so the profile-changed callback stays quiet and the caller prints the one line.
local function say(deps, msg) if msg and deps.say then deps.say(msg) end end

local function call(deps, name)
  if type(deps[name]) == "function" then pcall(deps[name]) end
end

local function opts(deps) return { log = deps.log, mark = deps.mark, sync = deps.syncDebug } end

-- Runs fn with the profile switch protected: UI closed before, debug and pages synced after.
local function apply(deps, fn)
  deps.busy = true
  call(deps, "closeUi")
  local ok, a, b = pcall(fn)
  deps.busy = false
  call(deps, "syncDebug")
  call(deps, "refresh")
  if not ok then error(a, 0) end
  return a, b
end

-- AceDB's OnProfileChanged: a switch this module did not make (the Profiles page, another addon). One chat line.
function TS.ProfileChanged(db, deps)
  if deps.busy then return end
  call(deps, "syncDebug")
  call(deps, "refresh")
  say(deps, TS.Line("changed", db))
end

-- /ddt testsettings on|off, and the settings banner's button.
function TS.Command(db, deps, action)
  if action == "on" then
    local status, err = apply(deps, function() return TS.On(db, opts(deps)) end)
    if not status then say(deps, L["Test settings could not change the profile: %s"]:format(tostring(err))) return end
    say(deps, TS.Line(status == "on" and "on" or "reset", db))
  else
    local done, err = apply(deps, function() return TS.Off(db, opts(deps)) end)
    if done then say(deps, TS.Line("off", db))
    elseif done == false then say(deps, TS.Line("notOn", db))
    else say(deps, L["Test settings could not change the profile: %s"]:format(tostring(err))) end
  end
end

function TS.OnRunStarted(db, deps, runId)
  local status = apply(deps, function() return TS.RunStarted(db, opts(deps), runId) end)
  if status == "on" or status == "reset" then say(deps, TS.Line(status, db)) end
end

function TS.OnRunEnded(db, deps, reason)
  local done = apply(deps, function() return TS.RunEnded(db, opts(deps), reason) end)
  if done then say(deps, TS.Line("off", db)) end
end

-- At login: restore or keep, then one chat line naming the profile in use. A login with no open run is also what
-- CheckThat's "no run" answer means, so a repeat is harmless.
function TS.LoginAnnounce(db, deps, runOpen)
  local result = apply(deps, function() return TS.Login(db, opts(deps), runOpen) end)
  if result == "kept" then say(deps, TS.Line("kept", db))
  elseif result == "restored" or result == "removed" then say(deps, TS.Line("restored", db))
  else say(deps, TS.Line("login", db)) end
  return result
end

function TS.OnRunGone(db, deps)
  local result = apply(deps, function() return TS.Login(db, opts(deps), false) end)
  if result == "restored" or result == "removed" then say(deps, TS.Line("restored", db)) end
end

local H = require("harness")

local saved = {}
local function stub(k, v) if saved[k] == nil then saved[k] = { _G[k] } end _G[k] = v end
local function restore() for k, v in pairs(saved) do _G[k] = v[1] end saved = {} end

local function fresh(show)
  stub("StaticPopupDialogs", {})
  stub("StaticPopup_Show", show)
  local ns = { Log = { Add = function() end } }
  H.load("DontDoThat/UI/ConfirmPopup.lua", ns)
  return ns
end

test("popup: an OnCancel the game fires because no slot was free is not a decline", function()
  local ns = fresh(function(which, _, _, data) _G.StaticPopupDialogs[which].OnCancel(nil, data) return nil end)
  local cancelled = 0
  falsy(ns.ConfirmPopup.Show("q", function() end, function() cancelled = cancelled + 1 end))
  eq(cancelled, 0)
  restore()
end)

test("popup: a real cancel after the dialog showed still declines, once", function()
  local data
  local ns = fresh(function(_, _, _, d) data = d return {} end)
  local cancelled = 0
  truthy(ns.ConfirmPopup.Show("q", function() end, function() cancelled = cancelled + 1 end))
  _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnCancel(nil, data)
  _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnCancel(nil, data)
  eq(cancelled, 1)
  restore()
end)

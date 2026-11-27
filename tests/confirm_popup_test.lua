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

test("popup: the item question has Always Allow, which runs only its own step, once", function()
  local data, which
  local ns = fresh(function(w, _, _, d) which, data = w, d return {} end)
  local runs = { yes = 0, no = 0, allow = 0 }
  truthy(ns.ConfirmPopup.Show("q", function() runs.yes = runs.yes + 1 end, function() runs.no = runs.no + 1 end,
    function() runs.allow = runs.allow + 1 end))
  eq(which, "DONTDOTHAT_CONFIRM_ITEM")
  local dialog = _G.StaticPopupDialogs.DONTDOTHAT_CONFIRM_ITEM
  eq(dialog.button3, "Always Allow")
  dialog.OnAlt(nil, data, "clicked")
  dialog.OnAlt(nil, data, "clicked")
  dialog.OnCancel(nil, data)
  eq(runs.allow, 1)
  eq(runs.yes, 0)
  eq(runs.no, 0)
  restore()
end)

test("popup: a question without Always Allow uses the two-button dialog", function()
  local which
  local ns = fresh(function(w) which = w return {} end)
  truthy(ns.ConfirmPopup.Show("q", function() end, function() end))
  eq(which, "DONTDOTHAT_CONFIRM")
  eq(_G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.button3, nil)
  eq(_G.StaticPopupDialogs.DONTDOTHAT_CONFIRM.OnAlt, nil)
  restore()
end)

test("popup: a question under the other key hides the unanswered one", function()
  local hidden = {}
  local ns = fresh(function() return {} end)
  stub("StaticPopup_Hide", function(which) hidden[#hidden + 1] = which end)
  local declined = 0
  truthy(ns.ConfirmPopup.Show("trainer", function() end, function() declined = declined + 1 end))
  truthy(ns.ConfirmPopup.Show("item", function() end, function() end, function() end))
  eq(declined, 1, "the trainer question counts as declined")
  eq(hidden, { "DONTDOTHAT_CONFIRM" })
  truthy(ns.ConfirmPopup.Show("item again", function() end, function() end, function() end))
  eq(#hidden, 1, "the same key reuses its frame and is not hidden")
  restore()
end)

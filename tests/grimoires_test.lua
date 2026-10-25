package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local function setup(class, profile)
  local ns = {}
  for _, f in ipairs({ "Rules/Schema.lua", "Rules/Engine.lua", "Rules/Data/Warlock.lua", "Rules/Data/Mage.lua",
      "Model/ItemCategory.lua", "Model/ItemWarning.lua", "Model/Ledger.lua", "Intercepts/Adapter.lua", "Intercepts/ItemGuard.lua" }) do
    H.load("DontDoThat/" .. f, ns)
  end
  ns.db = { profile = profile or { enabled = true, blockingConfirmations = true, alerts = true, minPrice = 100,
      itemModes = { recipes = "ah" } }, char = { ledger = ns.Ledger.NewState() }, global = {} }
  ns.Alert = { Trigger = function() return true end }
  local shown = {}
  ns.ConfirmPopup = { Ask = function(verdict, yes, no) shown.verdict, shown.yes, shown.no = verdict, yes, no; return true end }
  _G.UnitClass = function() return class:sub(1, 1) .. class:sub(2):lower(), class, 1 end
  _G.UnitLevel = function() return 20 end
  -- A grimoire is an item of class 9 (Recipe), subclass 0 (Book).
  _G.GetItemInfoInstant = function() return 1, "Recipe", "Book", "", 0, 9, 0 end
  return ns, shown
end
local function teardown() _G.UnitClass, _G.UnitLevel, _G.GetItemInfoInstant = nil, nil, nil end
local function link(name) return "|cff9d9d9d|Hitem:1224::::::::20:::::|h[" .. name .. "]|h|r" end

test("a Warlock is asked before buying a secondary demon grimoire", function()
  local ns, shown = setup("WARLOCK")
  local bought = false
  ns.ItemGuard.Run("vendor", "Grimoire of Soothing Kiss (Rank 2)", link("Grimoire of Soothing Kiss (Rank 2)"), 5000, function() bought = true end)
  falsy(bought, "held until answered")
  truthy(shown.verdict.reason:find("demon", 1, true), shown.verdict.reason)
  shown.yes()
  truthy(bought)
  eq(ns.db.char.ledger.spentAgainst, 5000)
  teardown()
end)

test("declining a grimoire counts as avoided and does not buy it", function()
  local ns, shown = setup("WARLOCK")
  local bought = false
  ns.ItemGuard.Run("vendor", "Grimoire of Devour Magic (Rank 3)", link("Grimoire of Devour Magic (Rank 3)"), 8000, function() bought = true end)
  shown.no()
  falsy(bought)
  eq(ns.db.char.ledger.itemsAvoided, 1)
  teardown()
end)

test("the grimoires the experts recommend are not asked about", function()
  local ns, shown = setup("WARLOCK")
  for _, n in ipairs({ "Grimoire of Firebolt (Rank 3)", "Grimoire of Torment (Rank 2)", "Grimoire of Blood Pact (Rank 2)", "Grimoire of Sacrifice (Rank 3)", "Grimoire of Lash of Pain (Rank 2)", "Grimoire of Spell Lock (Rank 1)" }) do
    local bought = false
    ns.ItemGuard.Run("vendor", n, link(n), 5000, function() bought = true end)
    truthy(bought, n); eq(shown.verdict, nil)
  end
  teardown()
end)

test("another class buying an item named like a grimoire is judged by its category only", function()
  local ns, shown = setup("MAGE")
  local bought = false
  ns.ItemGuard.Run("vendor", "Grimoire of Blood Pact (Rank 2)", link("Grimoire of Blood Pact (Rank 2)"), 5000, function() bought = true end)
  truthy(bought); eq(shown.verdict, nil)
  teardown()
end)

test("the Shopping switch, the minimum price and the addon switch all apply to grimoires", function()
  local profile = { enabled = true, blockingConfirmations = true, alerts = true, minPrice = 100, itemModes = {}, watch = { shopping = false } }
  local ns, shown = setup("WARLOCK", profile)
  local name = "Grimoire of Soothing Kiss (Rank 2)"
  eq(ns.ItemGuard.Flag("vendor", link(name), 5000), nil, "Shopping off")
  profile.watch.shopping = true
  eq(ns.ItemGuard.Flag("vendor", link(name), 5000), "grimoires")
  eq(ns.ItemGuard.Flag("vendor", link(name), 50), nil, "below the minimum price")
  profile.enabled = false
  eq(ns.ItemGuard.Flag("vendor", link(name), 5000), nil, "addon off")
  teardown()
end)

test("grimoires are a vendor matter only, and asking can be turned off", function()
  local ns, shown = setup("WARLOCK")
  ns.db.profile.itemModes = {}
  local name = "Grimoire of Soothing Kiss (Rank 2)"
  eq(ns.ItemGuard.Flag("ah", link(name), 5000), nil, "not flagged at the auction house by this rule")
  ns.db.profile.blockingConfirmations = false
  local bought = false
  ns.ItemGuard.Run("vendor", name, link(name), 5000, function() bought = true end)
  truthy(bought, "alert only, purchase goes ahead"); eq(shown.verdict, nil)
  teardown()
end)

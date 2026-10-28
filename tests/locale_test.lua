package.path = "./tests/?.lua;" .. package.path
local H = require("harness")
local C = require("locale_check")

local used = C.usedKeys("DontDoThat")

test("the enUS file gives English-as-key: a sentence with no translation shows as written", function()
  local ns = {}
  H.load("DontDoThat/Locales/enUS.lua", ns)
  eq(ns.L["Buy anyway?"], "Buy anyway?")
  eq(ns.L["Anything at all, even a sentence nobody wrote"], "Anything at all, even a sentence nobody wrote")
end)

test("the source asks for the sentences the tests below rely on", function()
  truthy(used["Buy anyway?"]); truthy(used["Costs about %s"]); truthy(used["%s costs %s."])
  truthy(next(used), "keys were found")
end)

test("a good translation file passes, and a locale file only loads for its own locale", function()
  local t = C.translations("tests/fixtures/locale_good.lua", "xxXX")
  eq(t["Buy anyway?"], "Xx?")
  eq(C.check(t, used), {})
  eq(C.translations("tests/fixtures/locale_good.lua", "deDE"), {}, "another locale loads nothing")
end)

test("a translation key the source never uses, and a placeholder mismatch, both fail and name the key", function()
  local problems = C.check(C.translations("tests/fixtures/locale_bad.lua", "xxXX"), used)
  eq(#problems, 3)
  local text = table.concat(problems, "\n")
  truthy(text:find('placeholder count differs: "Costs about %s"', 1, true), text)
  truthy(text:find('placeholder count differs: "%s costs %s."', 1, true), text)
  truthy(text:find('unused key: "A sentence the addon never asks for"', 1, true), text)
end)

test("every shipped translation file passes", function()
  local p = io.popen('ls DontDoThat/Locales/*.lua')
  for path in p:lines() do
    local name = path:match("([%w]+)%.lua$")
    if name ~= "enUS" and name ~= "Example" then
      eq(C.check(C.translations(path, name), used), {}, path)
    end
  end
  p:close()
end)

test("the example file loads for no real locale and translates nothing", function()
  eq(C.translations("DontDoThat/Locales/Example.lua", "enUS"), {})
  eq(C.translations("DontDoThat/Locales/Example.lua", "deDE"), {})
end)

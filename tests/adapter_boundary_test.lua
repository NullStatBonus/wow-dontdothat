local H = require("harness")

-- Model code reads the game only through an env argument or ns.Adapter (AGENTS.md, Conventions).
local API = { "UnitLevel", "UnitClass", "GetTime", "GetMoney", "StaticPopup_Show", "StaticPopupDialogs", "LibStub",
  "GetNumTalentTabs", "GetTalentTabInfo", "IsSpellKnown", "GetSpellInfo", "C_Traits", "C_ClassTalents" }

local function modelFiles()
  local out = {}
  local p = io.popen("ls DontDoThat/Model/*.lua")
  for path in p:lines() do out[#out + 1] = path end
  p:close()
  return out
end

test("adapter boundary: Model files read no game global directly", function()
  local bad = {}
  for _, path in ipairs(modelFiles()) do
    local f = io.open(path); local src = f:read("*a"); f:close()
    local n = 0
    for line in (src .. "\n"):gmatch("([^\n]*)\n") do
      n = n + 1
      local code = line:gsub("%-%-.*$", "")
      if code:find("_G%s*[%.%[]") then bad[#bad + 1] = path .. ":" .. n .. ": " .. line end
      for _, name in ipairs(API) do
        -- A bare name, not a field (env.X, ns.X) and not inside a string.
        local s = code:gsub('"[^"]*"', '""')
        if s:find("%f[%w_.]" .. name .. "%f[^%w_]") then bad[#bad + 1] = path .. ":" .. n .. ": " .. line end
      end
    end
  end
  eq(table.concat(bad, "\n"), "", "direct game calls")
end)

test("adapter boundary: the earn-back line reads the level through the adapter", function()
  local ns = {}
  ns.Adapter = { ReadPlayer = function() return { level = 24 } end }
  H.load("DontDoThat/Data/GoldRates.lua", ns)
  H.load("DontDoThat/Model/EarnBack.lua", ns)
  truthy((ns.EarnBack.Line(33200) or ""):find("At level 24", 1, true))
end)

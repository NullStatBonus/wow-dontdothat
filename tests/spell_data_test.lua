local H = require("harness")

local function fresh()
  local ns = {}
  H.load("DontDoThat/Data/SpellData.lua", ns)
  return ns
end

local function find(ns, class, name, rank)
  for _, row in ipairs(ns.SpellTables[class].rows) do
    if row.name == name and row.rank == rank then return row end
  end
end

local function hasId(row, id)
  if row.id == id then return true end
  for _, alt in ipairs(row.alt or {}) do if alt == id then return true end end
  return false
end

test("every spell family has one row per rank and no rankless twin of a ranked spell", function()
  local ns = fresh()
  for class, block in pairs(ns.SpellTables) do
    if type(block) == "table" and block.rows then
      local seen, ranked, rankless = {}, {}, {}
      for _, row in ipairs(block.rows) do
        if row.rank and row.kind ~= "pet" then -- pet ranks repeat per pet level (Natural Armor)
          local key = row.name .. "|" .. row.rank
          eq(seen[key], nil, class .. " has two rows for " .. key)
          seen[key] = true
        end
        if row.rank then ranked[row.name] = true else rankless[row.name] = row.id end
      end
      for name, id in pairs(rankless) do
        -- Known: Mage Polymorph (Turtle, 28271) and Paladin Vindication (talent, 9452) are separate spells with the same name.
        eq(ranked[name] and id ~= 28271 and id ~= 9452 or nil, nil, class .. " " .. name .. " has a rankless row " .. id .. " next to ranked rows")
      end
    end
  end
end)

test("ranks that carry ClassMask 0 in the game tables are present", function()
  local ns = fresh()
  local light = find(ns, "PALADIN", "Holy Light", 5)
  truthy(light and hasId(light, 1042), "Paladin Holy Light rank 5 is spell 1042")
  local agony = find(ns, "WARLOCK", "Bane of Agony", 2)
  truthy(agony and hasId(agony, 1014), "Warlock Curse of Agony rank 2 is spell 1014")
end)

test("Holy Shock rows use the taught spell IDs", function()
  local ns = fresh()
  local taught = { [2] = 20473, [3] = 20929, [4] = 20930 }
  for rank, id in pairs(taught) do
    local row = find(ns, "PALADIN", "Holy Shock", rank)
    truthy(row, "Holy Shock rank " .. rank)
    eq(row.id, id, "Holy Shock rank " .. rank)
  end
end)

test("Prayer of Mending has one row per rank and no rankless 401863 row", function()
  local ns = fresh()
  local count = 0
  for _, row in ipairs(ns.SpellTables.PRIEST.rows) do
    if row.name == "Prayer of Mending" then
      count = count + 1
      truthy(row.rank, "rank on " .. row.id)
      truthy(row.id ~= 401863, "401863 is not a row")
    end
  end
  eq(count, 3)
  eq(find(ns, "PRIEST", "Prayer of Mending", 1).id, 401859)
end)

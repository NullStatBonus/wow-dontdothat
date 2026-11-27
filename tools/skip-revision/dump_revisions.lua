-- Prints revisions 1 and 2 of Data/SkipRevisions.lua as JSON, so revision 3 can be built on exactly what shipped.
-- Usage: luajit dump_revisions.lua <path to the DontDoThat addon folder>
local ROOT = (arg[1] or "DontDoThat"):gsub("/?$", "/")
local function ser(v)
  local t = type(v)
  if t == "table" then
    if v[1] ~= nil or next(v) == nil then local p = {} for _, x in ipairs(v) do p[#p+1] = ser(x) end return "["..table.concat(p, ",").."]" end
    local p = {} for k, x in pairs(v) do p[#p+1] = string.format("%q:%s", tostring(k), ser(x)) end return "{"..table.concat(p, ",").."}"
  elseif t == "string" then return string.format("%q", v)
  elseif t == "number" or t == "boolean" then return tostring(v) else return "null" end
end
local ns = {}
assert(loadfile(ROOT .. "Data/SkipRevisions.lua"))("DontDoThat", ns)
local out = {}
for cls, revs in pairs(ns.SkipRevisions) do
  out[#out + 1] = string.format("%q:{%s}", cls, table.concat({ string.format('"1":%s', ser(revs[1].entries)), string.format('"2":%s', ser(revs[2].entries)) }, ","))
end
io.write("{" .. table.concat(out, ",") .. "}")

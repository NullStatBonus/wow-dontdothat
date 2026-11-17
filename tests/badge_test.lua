-- The AddOns list badge: both TOCs name the same file, which ships in the addon folder as a square,
-- power-of-two, uncompressed 32-bit TGA with an alpha channel (what the game can load).
local function iconOf(flavor)
  for line in io.lines("DontDoThat/DontDoThat_" .. flavor .. ".toc") do
    local path = line:gsub("\r", ""):match("^## IconTexture:%s*(.-)%s*$")
    if path then return path end
  end
end

test("badge: both TOCs name the shipped icon", function()
  local icon = iconOf("Vanilla")
  eq(icon, "Interface\\AddOns\\DontDoThat\\Media\\icon.tga")
  eq(iconOf("Camelot"), icon)
end)

test("badge: the icon is a square 32-bit TGA with alpha", function()
  local file = assert(io.open("DontDoThat/Media/icon.tga", "rb"))
  local h = file:read(18); file:close()
  local w, hgt = h:byte(13) + h:byte(14) * 256, h:byte(15) + h:byte(16) * 256
  eq(h:byte(3), 2) -- uncompressed truecolor
  truthy(w == hgt and (w == 64 or w == 128 or w == 256), "square, power of two")
  eq(h:byte(17), 32)
  eq(h:byte(18) % 16, 8) -- 8-bit alpha
end)

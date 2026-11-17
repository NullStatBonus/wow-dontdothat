local H = require("harness")

local function fresh()
  local ns = {}
  H.load("DontDoThat/UI/Helpers.lua", ns)
  return ns.UIHelpers
end

test("presentation helpers: spacing and font role tokens", function()
  local U = fresh()
  eq({ U.SPACE, U.PAD, U.CONTENT_PAD, U.SECTION }, { 4, 8, 12, 16 })
  eq(U.FONTS, { supporting = "GameFontHighlightSmall", body = "GameFontHighlight", heading = "GameFontNormal" })
end)

test("presentation helpers: appearance percentages clamp to their ranges and default to 100", function()
  local U = fresh()
  eq(U.Appearance(nil), { bg = 1, text = 1, scale = 1 })
  eq(U.Appearance({ bgAlpha = 0, textAlpha = 80, scale = 150 }), { bg = 0, text = 0.8, scale = 1.5 })
  eq(U.Appearance({ bgAlpha = -1, textAlpha = 101, scale = 49 }), { bg = 1, text = 1, scale = 1 })
  eq(U.Appearance({ scale = 200 }).scale, 2)
  eq(U.Appearance({ bgAlpha = "50" }).bg, 0.5)
end)

test("presentation helpers: content keeps the recommendation wording and estimate marker, invents no price", function()
  local U = fresh()
  local c = U.Content({ tier = "info", cost = 250, costIsEstimate = true, reason = "Why." }, "Mount")
  eq(c.recommendation, "Optional")
  eq(c.title, "Mount costs about 2s 50c.")
  eq(c.detail, "Why.")
  eq(#c.color, 3)
  c = U.Content({}, nil)
  eq(c.recommendation, nil); eq(c.color, nil); eq(c.detail, nil)
  eq(c.title, "This purchase")
  eq(U.Content(nil).title, "This purchase")
end)

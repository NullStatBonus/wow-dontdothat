package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local ns = { Log = { Add = function() end } }
H.load("DontDoThat/Rules/Schema.lua", ns)
H.load("DontDoThat/Rules/Engine.lua", ns)
H.load("DontDoThat/Rules/Data/ProfessionLearn.lua", ns)

local function profile(extra)
  local p = { class = "HUNTER", level = 25, plausibleSpecs = {}, professions = {}, professionAsked = {},
    milestone = { current = 40, state = "active" } }
  for k, v in pairs(extra or {}) do p[k] = v end
  return p
end
local function learn(name) return { kind = "professionLearn", name = "Apprentice " .. name, profession = name, cost = 1000 } end

test("rows teaching a gathering profession are not recognised", function()
  for _, n in ipairs({ "Skinning", "Herbalism", "Mining", "Fishing" }) do
    eq(ns.Rules.MatchProfessionLearn("Apprentice " .. n), nil, n)
  end
  eq(ns.Rules.MatchProfessionLearn("Journeyman Leatherworking"), nil)
  eq(ns.Rules.MatchProfessionLearn("Apprentice Leatherworking"), "Leatherworking")
  eq(ns.Rules.MatchProfessionLearn("Engineering (Apprentice)"), "Engineering")
end)

test("the first time: defer with a direct reason naming the profession and no cost", function()
  local v = ns.Rules.Evaluate(profile(), learn("Leatherworking"))
  eq(v.tier, "defer"); eq(v.source, "professionLearn"); eq(v.profession, "Leatherworking"); eq(v.cost, nil)
  truthy(v.reason:find("Leatherworking", 1, true))
end)

test("already asked or already known means keep", function()
  eq(ns.Rules.Evaluate(profile({ professionAsked = { Leatherworking = true } }), learn("Leatherworking")).tier, "keep")
  eq(ns.Rules.Evaluate(profile({ professions = { Leatherworking = { skill = 1, max = 75 } } }), learn("Leatherworking")).tier, "keep")
end)

test("no warning once the mount milestone is over", function()
  eq(ns.Rules.Evaluate(profile({ milestone = { state = "finished" } }), learn("Leatherworking")).tier, "keep")
end)

test("answering either way records the profession; alert-only mode records nothing", function()
  local function run(promptsOn, answer)
    local n = { Log = { Add = function() end } }
    n.db = { profile = {} }
    n.Settings = { MarkProfessionAsked = function(prof) n.db.profile.professionAsked = { [prof] = true } end,
      PromptTiers = function() return { defer = true } end, PromptsFor = function() return true end }
    n.Alert = { Trigger = function() end }
    local ask
    n.ConfirmPopup = { Ask = function(_, yes, no) ask = { yes = yes, no = no }; return true end }
    H.load("DontDoThat/Intercepts/Confirm.lua", n)
    n.TrainerConfirm.Reset()
    n.db.profile.blockingConfirmations = promptsOn
    n.TrainerOverlay = { Compute = function()
      return { verdicts = { [3] = { tier = "defer", source = "professionLearn", profession = "Engineering", name = "Apprentice Engineering", reason = "r" } } }
    end }
    local button = { script = function() end }
    button.GetScript = function(self) return self.script end
    button.SetScript = function(self, _, fn) self.script = fn end
    local env = { ClassTrainerTrainButton = button, ClassTrainerFrame = { selectedService = 3 } }
    n.TrainerConfirm.Install(env)
    button.script(button)
    if ask and answer then ask[answer]() end
    return n.db.profile.professionAsked
  end
  eq(run(true, "yes"), { Engineering = true })
  eq(run(true, "no"), { Engineering = true })
  eq(run(false), nil, "blocking confirmations off: no question, nothing recorded")
end)

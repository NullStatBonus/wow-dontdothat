# Module contracts (shared by parallel workstreams)

Conventions
- Lua 5.1 syntax (WoW). Every addon file starts `local addonName, ns = ...` and attaches its module to `ns`. No new globals except SavedVariables (`DontDoThatDB`) and slash command registration.
- `Rules/**` and `Model/**` are pure Lua: no WoW API calls, no Ace libs, no frames. They take plain tables in and return plain tables, so they run under `tests/run.lua`.
- Anything that calls a WoW API must guard it (`if C_Foo and C_Foo.Bar then`) and wrap fragile calls in `pcall`. Forever API names are unverified until the probe runs; do not assume them.
- Money is always integer copper in data and logic.
- Do NOT edit `DontDoThat_Camelot.toc` or `tasks.md`. Report the new files you want in the TOC, in load order, in your final message.

Shapes

```
Action  = { kind = "spell"|"respec"|"professionLearn",
            name = "Serpent Sting", family = "Serpent Sting",   -- family groups ranks
            rank = 8, unlockLevel = 58, nextRankLevel = 60,     -- nextRankLevel nil if last rank
            spellId = nil|number, cost = copper|nil, tags = {..}|nil }

Profile = { class = "HUNTER", level = 25,
            treePoints = { BM = 21, MM = 0, SV = 0 },           -- keyed by spec key
            plausibleSpecs = { "BM" },                          -- from SpecInference
            professions = { Cooking = { skill = 75, max = 150 } },   -- known professions
            milestone = { current = 40|60|nil, state = "active"|"finished" } }  -- active from level 1 until the level 60 mount is bought

Verdict = { tier = "keep"|"info"|"deferLow"|"defer",
            cost = copper|nil, costIsEstimate = bool,
            reason = "text", milestone = 40|60|nil,
            source = "override"|"rotation"|"tag"|"supersession"|"default" }

Service = { family = "Serpent Sting", name = "Serpent Sting", rank = 3, unlockLevel = 18,
            cost = copper|nil, learned = bool, available = bool }   -- trainer/spellbook row, adapter-supplied

Engine (ns.Rules)
  ns.Rules.Evaluate(profile, action) -> Verdict
  ns.Rules.Load(classData)  -- validates, raises a clear error on malformed data
  ns.Rules.GetClass(classKey) -> data table or nil
  ns.Rules.SupersessionWindow  -- default 4, overridable via data

SpecInference (ns.SpecInference)
  ns.SpecInference.Infer(classData, treePointsByTalentSet, opts) -> plausibleSpecs (array of spec keys)
  opts = { leadMargin = number, ... }; treePointsByTalentSet is an array (1 or 2 talent sets).
  ns.SpecInference.Depth(treePoints, specKey) -> points; ns.SpecInference.Role(classData, treePoints) -> role

Milestones (ns.Milestones)
  ns.Milestones.Defaults  -- data: { [40] = { riding = copper, mount = copper }, [60] = {...} }
  ns.Milestones.State(level, ridingLearned40, ridingLearned60, manualOverride) -> { current, state }

Ledger (ns.Ledger) -- takes the engine as an argument so it is testable with a stub
  ns.Ledger.Compute(profile, services, engine, costCache) -> { verified = copper, projected = copper, items = {..} }
  ns.Ledger.RespecCost(count, table) -> copper (escalating, capped)
  ns.Ledger.NewState() -> { respecsAvoided = 0, respecsPerformed = 0, spentAgainst = 0, costCache = {} }
Items
  ns.ItemCategory.Classify({ classID, subClassID, equipLoc }) -> category key (one of 13; unknown -> "misc")
  ns.ItemWarning.Flagged(modes, category, surface, total, minPrice) -> bool   -- surface "vendor"|"ah"
  profile.itemModes = { [category] = "off"|"vendor"|"ah"|"both" }; profile.minPrice = copper (default 100)
  ns.ItemGuard.Run(surface, name, link, total, proceed)   -- alert, ask, then proceed() or drop
Guarded dialogs (ns.Resets): KINDS = talent, pet, bank, stable, cod; profile.guard = { bank, stable, cod } (default all true)
  kind = { popups, label, title, ask, rises, advice, price(env,data)|event, accept(env,data,which)|confirmFn, done, avoided(state,cost), performed(state,cost) }
EarnBack (ns.EarnBack)
  ns.EarnBack.Describe(copper, level) -> "about 40 minutes" | nil;  ns.EarnBack.Line(copper) -> prompt sentence | nil
  Rates: Data/GoldRates.lua, copper per hour by level band (estimates, needsReview)
Ledger additions: ns.Ledger.RecordItemAvoided(state, copper), RecordItemPerformed(state, copper)
```

Test commands: `lua` is at the scratchpad path given in your task; run from the project root: `<lua> tests/run.lua [pattern]`; syntax check with `<luac> -p file.lua`.

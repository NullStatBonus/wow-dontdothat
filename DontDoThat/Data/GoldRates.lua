local addonName, ns = ...

-- Gold earned per hour of moderate-pace mob grinding (coin plus vendor trash; no auction house, no
-- professions), by level band. Copper. These are ESTIMATES drawn from scattered player reports, kept
-- deliberately low so the "time to earn back" errs long. Replace with measured numbers when available.
ns.GoldRates = {
  { minLevel = 1,  perHour = 4000,   needsReview = true }, -- 0.4g
  { minLevel = 10, perHour = 10000,  needsReview = true }, -- 1g
  { minLevel = 20, perHour = 20000,  needsReview = true }, -- 2g
  { minLevel = 30, perHour = 30000,  needsReview = true }, -- 3g
  { minLevel = 40, perHour = 50000,  needsReview = true }, -- 5g
  { minLevel = 50, perHour = 80000,  needsReview = true }, -- 8g
  { minLevel = 60, perHour = 120000, needsReview = true }, -- 12g
}

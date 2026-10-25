-- Minimal test harness. Runs outside the game with no WoW globals.
-- Test files live in tests/*_test.lua and call test(name, fn) and the assert helpers.

local H = { passed = 0, failed = 0, failures = {} }

function H.load(path, ns)
  -- Loads an addon file the way WoW does: the file receives (addonName, ns) as varargs.
  local chunk, err = loadfile(path)
  if not chunk then error(err, 2) end
  return chunk("DontDoThat", ns)
end

function H.deepEqual(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do
    if not H.deepEqual(v, b[k]) then return false end
  end
  for k in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end

local function fail(msg)
  error(msg, 3)
end

function _G.eq(actual, expected, msg)
  if not H.deepEqual(actual, expected) then
    fail((msg or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
end

function _G.truthy(value, msg)
  if not value then fail(msg or "expected a truthy value") end
end

function _G.falsy(value, msg)
  if value then fail(msg or "expected a falsy value") end
end

function _G.raises(fn, pattern, msg)
  local ok, err = pcall(fn)
  if ok then fail(msg or "expected an error") end
  if pattern and not tostring(err):find(pattern, 1, true) then
    fail((msg or "error text mismatch") .. ": expected to contain '" .. pattern .. "', got '" .. tostring(err) .. "'")
  end
end

function _G.test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    H.passed = H.passed + 1
  else
    H.failed = H.failed + 1
    H.failures[#H.failures + 1] = name .. "\n    " .. tostring(err)
  end
end

function H.report()
  for _, f in ipairs(H.failures) do print("FAIL  " .. f) end
  print(("%d passed, %d failed"):format(H.passed, H.failed))
  return H.failed == 0
end

return H

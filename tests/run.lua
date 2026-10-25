-- Usage (from the project root): lua tests/run.lua [pattern]
-- Runs every tests/*_test.lua whose name contains the optional pattern.

package.path = "./tests/?.lua;" .. package.path
local H = require("harness")

local pattern = arg and arg[1]
local p = io.popen('ls tests/*_test.lua 2>/dev/null')
local files = {}
for line in p:lines() do
  if not pattern or line:find(pattern, 1, true) then files[#files + 1] = line end
end
p:close()

for _, file in ipairs(files) do
  local chunk, err = loadfile(file)
  if not chunk then
    H.failed = H.failed + 1
    H.failures[#H.failures + 1] = file .. "\n    " .. tostring(err)
  else
    local ok, runErr = pcall(chunk)
    if not ok then
      H.failed = H.failed + 1
      H.failures[#H.failures + 1] = file .. "\n    " .. tostring(runErr)
    end
  end
end

os.exit(H.report() and 0 or 1)

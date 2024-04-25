local args = {...}
if args[1] == "install-cos" then
  -- when installing cOS from a regular computer, we'll find ourselves here
  return
end
local archive = require("archive")
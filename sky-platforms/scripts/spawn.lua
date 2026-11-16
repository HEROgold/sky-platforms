-- Where characters appear. Placement on the home platform, in this slice, is only
-- the position search. Placing and armor come with the spawn slice.
local registry = require("scripts.registry")

local spawn = {}

--- The platform a force starts on.
---@param force LuaForce
---@return LuaSpacePlatform?
function spawn.home_platform(force)
  return registry.resolve(storage.home_platform[force.index])
end

return spawn
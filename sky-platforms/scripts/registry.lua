-- Platform registry. Stores a stable ID per platform, so other code never keeps a
-- LuaSpacePlatform across ticks. Slice L1 (0.4.0) adds landing and take-off states.
local registry = {}

function registry.init()
  storage.platforms = storage.platforms or {}
  storage.platform_next_id = storage.platform_next_id or 1
  storage.platform_by_index = storage.platform_by_index or {}
  storage.platform_by_hub = storage.platform_by_hub or {}
end

--- Register a platform in state "orbit" and return its ID. Returns the existing ID if known.
---@param platform LuaSpacePlatform
---@return integer
function registry.register(platform)
  registry.init()
  local known = storage.platform_by_index[platform.index]
  if known then
    return known
  end
  local id = storage.platform_next_id
  storage.platform_next_id = id + 1
  storage.platforms[id] = {
    id = id,
    force_index = platform.force.index,
    name = platform.name,
    state = "orbit",
    platform_index = platform.index,
    state_tick = game.tick,
  }
  storage.platform_by_index[platform.index] = id
  return id
end

--- Resolve an ID to the current LuaSpacePlatform, or nil if it is gone or not in orbit.
---@param id integer?
---@return LuaSpacePlatform?
function registry.resolve(id)
  local entry = id and storage.platforms and storage.platforms[id]
  if not (entry and entry.platform_index) then
    return nil
  end
  local force = game.forces[entry.force_index]
  if not (force and force.valid) then
    return nil
  end
  for _, platform in pairs(force.platforms) do
    if platform.valid and platform.index == entry.platform_index then
      return platform
    end
  end
  return nil
end

return registry
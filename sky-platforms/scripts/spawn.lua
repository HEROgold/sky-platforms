-- Where characters appear: on a platform, near its hub, never on empty space.
local registry = require("scripts.registry")

local spawn = {}

--- The platform a force starts on.
---@param force LuaForce
---@return LuaSpacePlatform?
function spawn.home_platform(force)
  return registry.resolve(storage.home_platform[force.index])
end

---@param surface LuaSurface
---@param position {x: number, y: number}
---@return boolean
local function on_solid_tile(surface, position)
  local tile = surface.get_tile(math.floor(position.x), math.floor(position.y))
  return tile.valid and tile.name ~= "empty-space"
end

--- A free, non-empty-space position within the spawn radius of the hub.
--- The search order is fixed (rings outward, 16 directions each), so every peer agrees.
---@param platform LuaSpacePlatform
---@return MapPosition?
function spawn.find_position(platform)
  local hub = platform.hub
  if not (hub and hub.valid) then
    return nil
  end
  local surface = platform.surface
  local center = hub.position --[[@as {x: number, y: number}]]
  local radius = settings.global["sky-platforms-spawn-radius"].value --[[@as number]]
  local function usable(candidate)
    local found = surface.find_non_colliding_position("character", candidate, 1, 0.5)
    if not found then return nil end
    local pos = found --[[@as {x: number, y: number}]]
    local dx, dy = pos.x - center.x, pos.y - center.y
    if dx * dx + dy * dy > radius * radius then return nil end
    if not on_solid_tile(surface, pos) then return nil end
    return pos
  end
  for ring = 2, radius do
    for k = 0, 15 do
      local angle = k * math.pi / 8
      local pos = usable({ x = center.x + ring * math.cos(angle), y = center.y + ring * math.sin(angle) })
      if pos then
        return pos
      end
    end
  end
  return nil
end

--- Put the player in a new character on the platform and destroy the old one.
---@param player LuaPlayer
---@param platform LuaSpacePlatform
---@return boolean placed
function spawn.place_on_platform(player, platform)
  local position = spawn.find_position(platform)
  if not position then
    log("[sky-platforms] no spawn position on platform " .. platform.name)
    return false
  end
  local old = player.character
  local character = platform.surface.create_entity({
    name = "character",
    position = position,
    force = player.force,
  })
  if not character then
    return false
  end
  player.set_controller({ type = defines.controllers.character, character = character })
  if old and old.valid then
    old.destroy()
  end
  return true
end

---@param player LuaPlayer
---@return boolean placed
function spawn.place_on_home(player)
  local platform = spawn.home_platform(player.force --[[@as LuaForce]])
  if not platform then
    return false
  end
  return spawn.place_on_platform(player, platform)
end

--- True if the player has a character standing on a platform surface.
---@param player LuaPlayer
---@return boolean
function spawn.is_on_platform(player)
  local character = player.character
  return character ~= nil and character.valid and character.surface.platform ~= nil
end

--- One mech-armor per player, once. The flag is set only after the insert succeeds.
---@param player LuaPlayer
function spawn.give_armor(player)
  local character = player.character
  if storage.armor_given[player.index] or not (character and character.valid) then
    return
  end
  local armor = character.get_inventory(defines.inventory.character_armor)
  if armor and armor.insert({ name = "mech-armor", count = 1 }) == 1 then
    storage.armor_given[player.index] = true
  end
end

return spawn
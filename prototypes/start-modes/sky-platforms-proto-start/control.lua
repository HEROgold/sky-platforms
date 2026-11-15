-- PROTOTYPE: start-mode comparison. Throwaway code, not for release.

local autotest = require("autotest")

local DEFAULT_MODE = "remote"
local MODES = { remote = true, god = true, walk = true }

local HUB_ITEMS = {
  { name = "space-platform-foundation", count = 50 },
  { name = "inserter", count = 20 },
  { name = "assembling-machine-1", count = 20 },
  { name = "solar-panel", count = 10 },
  { name = "asteroid-collector", count = 4 },
  { name = "crusher", count = 4 },
}

local function say(player, msg)
  log("[start-proto] " .. msg)
  if player and player.valid then
    player.print("[start-proto] " .. msg)
  else
    game.print("[start-proto] " .. msg)
  end
end

-- Runs fn under pcall and reports the outcome. Returns ok, result.
local function try(player, label, fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    say(player, label .. ": ok " .. tostring(result))
  else
    say(player, label .. ": ERROR " .. tostring(result))
  end
  return ok, result
end

local function controller_name(player)
  for name, value in pairs(defines.controllers) do
    if value == player.controller_type then return name end
  end
  return tostring(player.controller_type)
end

local function setup_storage()
  storage.platforms = storage.platforms or {} -- force index -> LuaSpacePlatform
  storage.pending = storage.pending or {} -- player index -> true, waiting for platform
  storage.walkers = storage.walkers or {} -- player index -> last tile name seen
  storage.hub_filled = storage.hub_filled or {} -- platform index -> true
end

local function skip_freeplay()
  if remote.interfaces["freeplay"] then
    pcall(remote.call, "freeplay", "set_skip_intro", true)
    pcall(remote.call, "freeplay", "set_disable_crashsite", true)
    -- Question 11 in the research notes: does an empty map remove all starting items?
    pcall(remote.call, "freeplay", "set_created_items", {})
  end
end

local function unlock_platforms(force)
  pcall(force.unlock_space_platforms, force)
  local tech = force.technologies["space-platform"]
  if tech then tech.researched = true end
end

-- Returns the platform for the force once hub and surface exist, else nil.
local function ready_platform(force)
  local platform = storage.platforms[force.index]
  if platform and platform.valid and platform.hub and platform.hub.valid
      and platform.surface and platform.surface.valid then
    return platform
  end
  return nil
end

local function ensure_platform(player)
  local force = player.force
  local platform = storage.platforms[force.index]
  if platform and platform.valid then return platform end
  unlock_platforms(force)
  local ok, result = try(player, "create_space_platform", force.create_space_platform, force, {
    planet = "nauvis",
    starter_pack = "space-platform-starter-pack",
  })
  if ok and result then
    storage.platforms[force.index] = result
    try(player, "apply_starter_pack", result.apply_starter_pack, result)
    return result
  end
  return nil
end

local function fill_hub(player, platform)
  for _, item in pairs(HUB_ITEMS) do
    try(player, "hub insert " .. item.name, platform.hub.insert, platform.hub, item)
  end
end

local function spawn_position(platform)
  local hub = platform.hub
  local ok, pos = pcall(platform.surface.find_non_colliding_position, platform.surface, "character", hub.position, 12, 0.5)
  if ok and pos then return pos end
  return { x = hub.position.x, y = hub.position.y + 4 }
end

-- Switches the player to a mode. Assumes the platform is ready.
local function apply_mode(player, mode, platform)
  local surface = platform.surface
  local hub_pos = platform.hub.position
  say(player, "applying mode " .. mode .. " (before: controller=" .. controller_name(player)
    .. ", character=" .. tostring(player.character ~= nil) .. ")")

  -- Drop a character left behind by an earlier mode, once the player no longer uses it.
  local function destroy_orphan(old)
    if old and old.valid and player.character ~= old then
      try(player, "destroy old character", old.destroy, old)
    end
  end

  if mode == "walk" then
    local old = player.character
    local pos = spawn_position(platform)
    local ok, char = try(player, "create_entity character", surface.create_entity, surface, {
      name = "character", position = pos, force = player.force,
    })
    if ok and char then
      try(player, "set_controller character", player.set_controller, player, {
        type = defines.controllers.character, character = char,
      })
      storage.walkers[player.index] = ""
      destroy_orphan(old)
    end
  elseif mode == "god" then
    local old = player.character
    try(player, "set_controller god", player.set_controller, player, { type = defines.controllers.god })
    destroy_orphan(old)
    try(player, "teleport to platform", player.teleport, player, spawn_position(platform), surface)
    storage.walkers[player.index] = nil
  elseif mode == "remote" then
    -- Make sure no body is left. Go through god so the old character is detached first.
    local old = player.character
    if old then
      try(player, "set_controller god (detach body)", player.set_controller, player, { type = defines.controllers.god })
      destroy_orphan(old)
    end
    try(player, "enter_space_platform", player.enter_space_platform, player, platform)
    if player.controller_type ~= defines.controllers.remote then
      try(player, "set_controller remote", player.set_controller, player, {
        type = defines.controllers.remote, surface = surface, position = hub_pos,
      })
    end
    storage.walkers[player.index] = nil
  end

  say(player, "after: controller=" .. controller_name(player) .. ", surface=" .. player.surface.name
    .. ", character=" .. tostring(player.character ~= nil))
end

local function try_start(player)
  ensure_platform(player)
  local ready = ready_platform(player.force)
  if not ready then return false end
  if not storage.hub_filled[ready.index] then
    storage.hub_filled[ready.index] = true
    fill_hub(player, ready)
  end
  apply_mode(player, DEFAULT_MODE, ready)
  if autotest.active() and not storage.autotest then autotest.start(player) end
  return true
end

local function on_new_player(player)
  if not storage.pending[player.index] then
    storage.pending[player.index] = true
    say(player, "new player, waiting for the platform to be ready")
  end
end

script.on_init(function()
  setup_storage()
  skip_freeplay()
  for _, player in pairs(game.players) do on_new_player(player) end
end)

script.on_configuration_changed(setup_storage)

script.on_event(defines.events.on_player_created, function(event)
  setup_storage()
  local player = game.get_player(event.player_index)
  if player then on_new_player(player) end
end)

-- Retry until the platform has a hub and surface.
script.on_nth_tick(30, function()
  setup_storage()
  for index in pairs(storage.pending) do
    local player = game.get_player(index)
    if not player or not player.valid then
      storage.pending[index] = nil
    elseif player.connected and try_start(player) then
      storage.pending[index] = nil
    end
  end
end)

script.on_event(defines.events.on_tick, function()
  if storage.autotest then autotest.walk_tick() end
end)

script.on_nth_tick(10, function()
  if not storage.autotest then return end
  autotest.tick(function(player) return ready_platform(player.force) end, apply_mode)
end)

-- Walk mode edge test: report each tile type the character stands on. Nothing is blocked.
script.on_nth_tick(15, function()
  if not storage.walkers then return end
  for index, last in pairs(storage.walkers) do
    local player = game.get_player(index)
    if player and player.valid and player.character then
      local ok, tile = pcall(player.surface.get_tile, player.surface, player.position)
      if ok and tile and tile.name ~= last then
        storage.walkers[index] = tile.name
        say(player, "walk: standing on tile '" .. tile.name .. "' at "
          .. string.format("%.1f,%.1f", player.position.x, player.position.y))
      end
    end
  end
end)

commands.add_command("sky-start", "<remote|god|walk> switch start mode (prototype)", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player then return end
  local mode = cmd.parameter and cmd.parameter:match("^%s*(%S+)")
  if not mode or not MODES[mode] then
    say(player, "usage: /sky-start <remote|god|walk>")
    return
  end
  setup_storage()
  local platform = ready_platform(player.force)
  if not platform then
    say(player, "platform not ready yet, try again in a moment")
    return
  end
  local ok, err = pcall(apply_mode, player, mode, platform)
  if not ok then say(player, "apply_mode ERROR " .. tostring(err)) end
end)

commands.add_command("sky-state", "print controller, surface, position, character, handcraft (prototype)", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player then return end
  local ok, err = pcall(function()
    local char = player.character
    local craft
    if char and char.valid then
      local n = 0
      for _ in pairs(char.prototype.crafting_categories or {}) do n = n + 1 end
      craft = "character prototype has " .. n .. " crafting categories"
    else
      local info = prototypes.mod_data["sky-start-god-info"]
      craft = "no character. god controller categories after data-final-fixes: "
        .. (info and tostring(info.data.categories_after) or "unknown")
        .. " (confirm by trying to craft)"
    end
    say(player, string.format("controller=%s, surface=%s, position=%.1f,%.1f, character=%s, crafting_queue_size=%s",
      controller_name(player), player.surface.name, player.position.x, player.position.y,
      tostring(char ~= nil and char.valid), tostring(player.crafting_queue_size)))
    say(player, "can-handcraft: " .. craft)
    say(player, "physical_controller=" .. tostring(player.physical_controller_type)
      .. ", physical_surface=" .. player.physical_surface.name)
  end)
  if not ok then say(player, "sky-state ERROR " .. tostring(err)) end
end)

local state = require("scripts.state")
local bootstrap = require("scripts.bootstrap")
local registry = require("scripts.registry")
local spawn = require("scripts.spawn")

--- The freeplay scenario may be missing, so each call is guarded.
---@param fn "set_skip_intro"|"set_disable_crashsite"|"set_created_items"
local function call_freeplay(fn, ...)
  local interface = remote.interfaces["freeplay"] --[[@as table<string, boolean>?]]
  if interface and interface[fn] then
    ---@diagnostic disable-next-line: generic-constraint-mismatch
    return remote.call("freeplay", fn, ...)
  end
end

script.on_init(function()
  state.init()
  call_freeplay("set_skip_intro", true)
  call_freeplay("set_disable_crashsite", true)
  call_freeplay("set_created_items", {})
  storage.bootstrap_done = false
  bootstrap.run(game.forces["player"])
end)

script.on_configuration_changed(function()
  state.init()
  -- Drop entries whose platform no longer exists.
  for force_index, id in pairs(storage.home_platform) do
    if not registry.resolve(id) then storage.home_platform[force_index] = nil end
  end
  for player_index, id in pairs(storage.respawn_choice) do
    if not registry.resolve(id) then storage.respawn_choice[player_index] = nil end
  end
  if storage.bootstrap_done == nil then
    -- An existing save adds the mod: it keeps its progress and gets no kit.
    storage.bootstrap_done = true
  end
  local force = game.forces["player"]
  if force and force.valid then
    bootstrap.unlock_space_travel(force)
  end
end)
script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if not spawn.is_on_platform(player) then
    spawn.place_on_home(player)
  end
  spawn.give_armor(player)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  spawn.relocate_respawn(player)
end)

-- Safety net for saves that load the mod after players already exist.
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if player.character and not spawn.is_on_platform(player) then
    spawn.place_on_home(player)
  end
end)

-- Read-only helpers for the self-test mod.
remote.add_interface("sky-platforms", {
  home_platform_spawn_position = function(force_index)
    local force = game.forces[force_index]
    local platform = force and spawn.home_platform(force)
    return platform and spawn.find_position(platform) or nil
  end,
})

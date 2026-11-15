-- Self-test for Sky Platforms. Appends PASS and FAIL lines to
-- script-output/sky-platforms-test.txt and ends with DONE.
local OUT = "sky-platforms-test.txt"
local STEP_TICKS = 30

local function out(line)
  log("[sky-platforms-test] " .. line)
  helpers.write_file(OUT, line .. "\n", true)
end

local function check(label, ok, detail)
  out(string.format("%s %s%s", ok and "PASS" or "FAIL", label, detail and (" (" .. tostring(detail) .. ")") or ""))
end

--- Runs fn and reports an error as FAIL instead of crashing.
local function guarded(label, fn)
  local ok, err = pcall(fn)
  if not ok then
    check(label, false, "error: " .. tostring(err))
  end
end

local function find_home_platform(force)
  for _, platform in pairs(force.platforms) do
    if platform.valid then
      return platform
    end
  end
end

local KIT = {
  { "asteroid-collector", 4 }, { "crusher", 4 }, { "assembling-machine-1", 4 },
  { "steel-furnace", 4 }, { "lab", 2 }, { "solar-panel", 20, true }, { "inserter", 40, true },
  { "transport-belt", 100, true }, { "space-platform-foundation", 180, true },
  { "thud-inertial-damper", 1 },
}
local TECHS = {
  "space-platform", "thud-orbital-ascent", "steam-power", "electronics",
  "automation-science-pack", "automation",
}

local function check_platform_and_kit(force)
  local platform = find_home_platform(force)
  check("platform exists", platform ~= nil)
  if not platform then return end
  local location = platform.space_location
  check("platform orbits sky-drift", location ~= nil and location.name == "sky-drift",
    location and location.name or "nil")
  local hub = platform.hub
  check("hub is valid", hub ~= nil and hub.valid)
  if not (hub and hub.valid) then return end
  local scale = settings.startup["sky-platforms-kit-scale"].value --[[@as number]]
  for _, item in ipairs(KIT) do
    local want = item[2]
    if item[3] then want = math.max(1, math.floor(want * scale + 0.5)) end
    local have = hub.get_item_count(item[1])
    -- The starter pack adds 10 foundations of its own, so the hub may hold more than the kit.
    check("hub holds " .. item[1], have >= want, have .. " of " .. want)
  end
  check("hub holds no mech-armor", hub.get_item_count("mech-armor") == 0)
  check("hub holds no stone-furnace", hub.get_item_count("stone-furnace") == 0)
end

local function check_unlocks(force)
  check("space platforms unlocked", force.is_space_platforms_unlocked())
  check("sky-drift unlocked", force.is_space_location_unlocked("sky-drift"))
  local tech = prototypes.technology["sky-platform-foundation"]
  check("foundation tech exists", tech ~= nil)
  if tech then
    local unlocks = false
    for _, effect in pairs(tech.effects or {}) do
      if effect.type == "unlock-recipe" and effect.recipe == "space-platform-foundation" then unlocks = true end
    end
    check("foundation tech unlocks the foundation recipe", unlocks)
    local red_only = #tech.research_unit_ingredients == 1
      and tech.research_unit_ingredients[1].name == "automation-science-pack"
    check("foundation tech costs red science only", red_only,
      tostring(tech.research_unit_count) .. " units")
    check("foundation tech needs steel processing", tech.prerequisites["steel-processing"] ~= nil)
  end
end

local function check_drift_solar()
  local drift = prototypes.space_location["sky-drift"]
  local nauvis = prototypes.space_location["nauvis"]
  if not (drift and nauvis) then
    check("drift solar equals nauvis orbit", false, "prototype missing")
    return
  end
  check("drift solar equals nauvis orbit", drift.solar_power_in_space == nauvis.solar_power_in_space,
    tostring(drift.solar_power_in_space) .. " vs " .. tostring(nauvis.solar_power_in_space))
end

--- Places a 2x2 entity on four foundation tiles. can_place_entity returns false here for any
--- entity on the platform, so this tries create_entity, which checks collisions itself.
local function place_on_foundation(platform, name)
  local hub = platform.hub
  local surface = platform.surface
  if not (hub and hub.valid and surface and surface.valid) then return nil end
  local function is_foundation(x, y)
    local tile = surface.get_tile(x, y)
    return tile ~= nil and tile.valid and tile.name == "space-platform-foundation"
  end
  local tiles = surface.find_tiles_filtered({ name = "space-platform-foundation", position = hub.position, radius = 14 })
  for _, tile in ipairs(tiles) do
    if tile.valid then
      local x, y = tile.position.x, tile.position.y
      if is_foundation(x + 1, y) and is_foundation(x, y + 1) and is_foundation(x + 1, y + 1) then
        local entity = surface.create_entity({ name = name, position = { x = x + 1, y = y + 1 }, force = platform.force, raise_built = true })
        if entity and entity.valid then
          return entity
        end
      end
    end
  end
end

--- Starts the steel furnace check. The poll in on_nth_tick finishes it, so it also runs headless.
local function start_furnace_check(platform)
  local test = storage.test
  test.furnace_started = true
  local furnace = place_on_foundation(platform, "steel-furnace")
  if not furnace then
    check("steel furnace works on the platform", false, "could not place on foundation")
    test.furnace_done = true
    return
  end
  furnace.insert({ name = "carbon", count = 5 })
  furnace.insert({ name = "iron-ore", count = 5 })
  test.furnace = furnace
  test.furnace_deadline = game.tick + 600
end

local function poll_furnace()
  local test = storage.test
  if not test or test.furnace_done or not test.furnace then return end
  local furnace = test.furnace
  if not furnace.valid then
    check("steel furnace works on the platform", false, "entity vanished")
    test.furnace_done = true
    return
  end
  if furnace.status == defines.entity_status.working then
    check("steel furnace works on the platform", true)
    furnace.destroy()
    test.furnace_done = true
  elseif game.tick >= test.furnace_deadline then
    check("steel furnace works on the platform", false, "status " .. tostring(furnace.status))
    furnace.destroy()
    test.furnace_done = true
  end
end

--- Finds the center of a 3x3 block of empty-space tiles that touches foundation, and a foundation tile next to it.
local function find_ghost_spot(platform)
  local hub = platform.hub
  local surface = platform.surface
  if not (hub and hub.valid and surface and surface.valid) then return nil end
  local function tile_name(x, y)
    local tile = surface.get_tile(x, y)
    return tile and tile.valid and tile.name or nil
  end
  local hx, hy = math.floor(hub.position.x), math.floor(hub.position.y)
  for cy = hy - 14, hy + 14 do
    for cx = hx - 14, hx + 14 do
      local all_empty = true
      for dy = -1, 1 do
        for dx = -1, 1 do
          if tile_name(cx + dx, cy + dy) ~= "empty-space" then all_empty = false end
        end
      end
      if all_empty then
        -- The tiles just outside the box on the left and right edges, rows -1 to 1.
        for dy = -1, 1 do
          for _, dx in ipairs({ -2, 2 }) do
            if tile_name(cx + dx, cy + dy) == "space-platform-foundation" then
              return { x = cx + 0.5, y = cy + 0.5 }, { x = cx + dx + 0.5, y = cy + dy + 0.5 }
            end
          end
        end
      end
    end
  end
end

local function clear_ghosts(surface, area)
  for _, ghost in ipairs(surface.find_entities_filtered({ area = area, type = { "entity-ghost", "tile-ghost" } })) do
    if ghost.valid then ghost.destroy() end
  end
end

local function check_techs(force)
  for _, name in ipairs(TECHS) do
    local tech = force.technologies[name]
    check("researched " .. name, tech ~= nil and tech.researched, tech and "" or "missing")
  end
end

--- Finds an ingredient or product by name in a recipe prototype list.
local function find_amount(list, name)
  for _, entry in ipairs(list or {}) do
    if entry.name == name then return entry end
  end
end

local function check_crushing_recipe(force, name, chunk, product)
  local recipe = force.recipes[name]
  check(name .. " exists", recipe ~= nil and recipe.valid)
  if not (recipe and recipe.valid) then return end
  check(name .. " is enabled", recipe.enabled)
  check(name .. " uses the crushing category", recipe.prototype.categories[1] == "crushing" and #recipe.prototype.categories == 1)
  local ingredient = find_amount(recipe.ingredients, chunk)
  check(name .. " takes 1 " .. chunk, ingredient ~= nil and ingredient.amount == 1)
  local result = find_amount(recipe.products, product)
  check(name .. " gives 6 " .. product, result ~= nil and result.amount == 6, result and result.amount or "nil")
  local back = find_amount(recipe.products, chunk)
  check(name .. " returns the chunk at 30%", back ~= nil and (back.independent_probability or back.probability) == 0.3,
    back and (back.independent_probability or back.probability) or "nil")
end

local function check_crushing(force)
  check_crushing_recipe(force, "sky-metallic-crushing-copper", "metallic-asteroid-chunk", "copper-ore")
  check_crushing_recipe(force, "sky-oxide-crushing-stone", "oxide-asteroid-chunk", "stone")
end

--- Checks that need no player: the spawn search the mod would use.
local function check_spawn_position()
  local pos = remote.call("sky-platforms", "home_platform_spawn_position", 1)
  check("spawn position found", pos ~= nil)
  local platform = find_home_platform(game.forces["player"])
  if not (pos and platform and platform.valid and platform.hub and platform.hub.valid) then return end
  local hub = platform.hub.position
  local distance = math.sqrt((pos.x - hub.x) ^ 2 + (pos.y - hub.y) ^ 2)
  check("spawn position within 5 tiles of hub", distance <= 5, string.format("%.2f", distance))
  local tile = platform.surface.get_tile(math.floor(pos.x), math.floor(pos.y))
  check("spawn tile is not empty-space", tile.valid and tile.name ~= "empty-space", tile.valid and tile.name or "invalid")
end

local function check_character(player)
  local character = player.character
  check("player has a character", character ~= nil and character.valid)
  if not (character and character.valid) then return end
  local platform = character.surface.platform
  check("character stands on a platform surface", platform ~= nil)
  local hub = platform and platform.valid and platform.hub
  if hub and hub.valid then
    local d = math.sqrt((character.position.x - hub.position.x) ^ 2 + (character.position.y - hub.position.y) ^ 2)
    check("character within 5 tiles of hub", d <= 5, string.format("%.2f", d))
  end
  local tile = character.surface.get_tile(math.floor(character.position.x), math.floor(character.position.y))
  check("character tile is not empty-space", tile.valid and tile.name ~= "empty-space", tile.valid and tile.name or "invalid")
  local armor = character.get_inventory(defines.inventory.character_armor)
  local count = armor and armor.get_item_count("mech-armor") or -1
  check("mech-armor equipped once", count == 1, count)
  local nauvis = game.surfaces["nauvis"]
  local left = nauvis and nauvis.find_entities_filtered({ name = "character" }) or {}
  check("Nauvis has no character left", #left == 0, #left)
end

local function check_respawned(player, label)
  local character = player.character
  if not (character and character.valid) then return end
  local platform = character.surface.platform
  check("respawn " .. label .. " lands on a platform surface", platform ~= nil, character.surface.name)
  local hub = platform and platform.valid and platform.hub
  if hub and hub.valid then
    local d = math.sqrt((character.position.x - hub.position.x) ^ 2 + (character.position.y - hub.position.y) ^ 2)
    check("respawn " .. label .. " within 5 tiles of hub", d <= 5, string.format("%.2f", d))
  end
  local tile = character.surface.get_tile(math.floor(character.position.x), math.floor(character.position.y))
  check("respawn " .. label .. " tile is not empty-space", tile.valid and tile.name ~= "empty-space")
  local armor = character.get_inventory(defines.inventory.character_armor)
  local count = armor and armor.get_item_count("mech-armor") or -1
  check("respawn " .. label .. " gives no new armor", count == 0, count)
  local nauvis = game.surfaces["nauvis"]
  local left = nauvis and nauvis.find_entities_filtered({ name = "character" }) or {}
  check("respawn " .. label .. ": Nauvis has no character", #left == 0, #left)
end

local RESPAWN_WAIT_TICKS = 3600

--- Kill the character and start the respawn clock.
local function kill_step(label)
  return function()
    guarded("kill " .. label, function()
      local player = game.get_player(storage.test.player)
      local character = player and player.valid and player.character
      check("character alive before " .. label .. " death", character ~= nil and character ~= false and character.valid)
      if character and character.valid then
        storage.test.death_tick = game.tick
        character.die()
      end
    end)
  end
end

--- Poll until the player has a character again, up to 60 s. Returns false to be called again.
local function await_step(label)
  return function()
    local ok, result = pcall(function()
      local player = game.get_player(storage.test.player)
      if not (player and player.valid) then
        check("respawn " .. label, false, "player invalid")
        return true
      end
      local character = player.character
      if character and character.valid then
        check("respawn " .. label .. " after " .. (game.tick - storage.test.death_tick) .. " ticks", true)
        check_respawned(player, label)
        return true
      end
      if game.tick - storage.test.death_tick > RESPAWN_WAIT_TICKS then
        check("respawn " .. label, false, "no character after 60 s")
        return true
      end
      return false
    end)
    if not ok then
      check("respawn " .. label, false, "error: " .. tostring(result))
      return true
    end
    return result
  end
end

local steps = {
  function()
    guarded("kit", function()
      local force = game.forces["player"]
      check_platform_and_kit(force)
      check_techs(force)
      check_unlocks(force)
      check_drift_solar()
      local platform = find_home_platform(force)
      if platform and not storage.test.furnace_started then
        start_furnace_check(platform)
      end
      check_crushing(force)
      check_spawn_position()
    end)
  end,
  function()
    guarded("spawn", function()
      local player = game.get_player(storage.test.player)
      check("test player is valid", player ~= nil and player.valid)
      if player and player.valid then check_character(player) end
    end)
  end,
  function()
    guarded("ghost placement", function()
      local label = "player ghost-places a solar panel on empty space"
      local player = game.get_player(storage.test.player)
      local platform = find_home_platform(game.forces["player"])
      if not (player and player.valid and platform) then
        check(label, false, "no player or platform")
        return
      end
      if player.surface ~= platform.surface then
        check(label, false, "player is on " .. player.surface.name)
        return
      end
      local spot, standing = find_ghost_spot(platform)
      if not (spot and standing) then
        check(label, false, "no empty 3x3 block next to foundation")
        return
      end
      player.teleport(standing)
      player.cursor_ghost = "solar-panel"
      player.build_from_cursor({ position = spot, build_mode = defines.build_mode.forced })
      storage.test.ghost_spot = spot
    end)
  end,
  function()
    guarded("ghost check", function()
      local label = "player ghost-places a solar panel on empty space"
      local spot = storage.test.ghost_spot
      local player = game.get_player(storage.test.player)
      if not (spot and player and player.valid) then return end
      local surface = player.surface
      local area = { { spot.x - 1.5, spot.y - 1.5 }, { spot.x + 1.5, spot.y + 1.5 } }
      local panel_ghost = false
      for _, ghost in ipairs(surface.find_entities_filtered({ area = area, type = "entity-ghost" })) do
        if ghost.valid and ghost.ghost_name == "solar-panel" then panel_ghost = true end
      end
      local tile_ghosts = 0
      for _, ghost in ipairs(surface.find_entities_filtered({ area = area, type = "tile-ghost" })) do
        if ghost.valid and ghost.ghost_name == "space-platform-foundation" then tile_ghosts = tile_ghosts + 1 end
      end
      check(label, panel_ghost, string.format("entity-ghost solar-panel %s, foundation tile ghosts %d",
        panel_ghost and "present" or "missing", tile_ghosts))
      clear_ghosts(surface, area)
      player.cursor_ghost = nil
      player.clear_cursor()
    end)
  end,
  kill_step("first"),
  await_step("first"),
  kill_step("second"),
  await_step("second"),
}

local function finish()
  out("DONE")
  storage.test.done = true
end

local function start()
  storage.test = storage.test or { step = 1, next_tick = 0 }
end

script.on_init(start)
script.on_configuration_changed(start)

script.on_event(defines.events.on_player_created, function(event)
  start()
  storage.test.player = storage.test.player or event.player_index
  storage.test.next_tick = game.tick + 60
end)

script.on_nth_tick(10, poll_furnace)

script.on_nth_tick(STEP_TICKS, function()
  local test = storage.test
  if not test or test.done then return end
  if not test.player then
    -- Headless runs have no player. Say so once, then keep waiting.
    if game.tick >= 300 and not test.warned then
      test.warned = true
      out("SKIP player checks, no player has joined yet")
    end
    if game.tick >= 120 and not test.ran_headless then
      test.ran_headless = true
      steps[1]()
    end
    return
  end
  if game.tick < test.next_tick then return end
  local step = steps[test.step]
  if not step then
    if not test.furnace_done then return end
    finish()
    return
  end
  if step() ~= false then
    test.step = test.step + 1
  end
  test.next_tick = game.tick + STEP_TICKS
end)
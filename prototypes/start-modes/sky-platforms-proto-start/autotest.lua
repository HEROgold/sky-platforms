-- PROTOTYPE self-test. Runs only when the empty marker mod "sky-proto-autotest" is active.
-- Drives each start mode, tries the things the README checklist asks, and appends
-- results to script-output/skyp-autotest.txt.

local M = {}

local OUT = "skyp-autotest.txt"
local MODES = { "remote", "god", "walk" }

local function out(line)
  log("[autotest] " .. line)
  helpers.write_file(OUT, line .. "\n", true)
end

local function cname(value)
  for name, v in pairs(defines.controllers) do
    if v == value then return name end
  end
  return tostring(value)
end

local function try(label, fn)
  local ok, res = pcall(fn)
  out(string.format("  %-28s %s %s", label, ok and "ok" or "ERROR", tostring(res)))
  return ok, res
end

local function snapshot(player, label)
  local ok = pcall(function()
    out(string.format("  [%s] controller=%s physical=%s surface=%s physical_surface=%s pos=%.1f,%.1f character=%s",
      label, cname(player.controller_type), cname(player.physical_controller_type),
      player.surface.name, player.physical_surface.name, player.position.x, player.position.y,
      tostring(player.character ~= nil)))
  end)
  if not ok then out("  [" .. label .. "] snapshot failed") end
end

local function checks(player, platform)
  local hub = platform.hub
  local target = { x = hub.position.x + 4, y = hub.position.y + 6 }

  try("main inventory exists", function() return player.get_main_inventory() ~= nil end)
  try("insert 10 iron plates", function() return player.insert({ name = "iron-plate", count = 10 }) end)
  try("begin_crafting gear", function()
    return player.begin_crafting({ count = 1, recipe = "iron-gear-wheel" })
  end)
  try("crafting_queue_size", function() return player.crafting_queue_size end)
  try("cancel crafting", function()
    if player.crafting_queue_size > 0 then
      player.cancel_crafting({ index = 1, count = 1 })
    end
    return true
  end)
  try("cursor_stack set inserter", function()
    return player.cursor_stack ~= nil and player.cursor_stack.set_stack({ name = "inserter", count = 1 })
  end)
  try("cursor_ghost set inserter", function()
    player.cursor_ghost = "inserter"
    return player.cursor_ghost ~= nil
  end)
  try("can_build_from_cursor", function() return player.can_build_from_cursor({ position = target }) end)
  try("build_from_cursor", function()
    player.build_from_cursor({ position = target })
    local found = platform.surface.find_entities_filtered({ position = target, radius = 1 })
    local names = {}
    for _, e in pairs(found) do names[#names + 1] = e.name end
    return table.concat(names, ",")
  end)
  try("clear cursor", function() player.clear_cursor() return true end)
  try("open hub GUI", function()
    player.opened = hub
    return player.opened ~= nil and player.opened.name or "nil"
  end)
  try("close GUI", function() player.opened = nil return true end)
  try("take item from hub", function()
    local inv = hub.get_inventory(defines.inventory.hub_main)
    local stack = inv and inv.find_item_stack("inserter")
    if not stack then return "no inserter in hub" end
    local moved = player.insert({ name = "inserter", count = 1 })
    if moved > 0 then inv.remove({ name = "inserter", count = 1 }) end
    return moved
  end)
end

-- Each step runs on a later tick so mode switches settle.
local function build_steps(player_index)
  local steps = {}
  local function add(fn) steps[#steps + 1] = fn end
  for _, mode in ipairs(MODES) do
    add(function(player, platform, apply)
      out("== mode " .. mode .. " ==")
      snapshot(player, "before")
      try("apply_mode " .. mode, function() apply(player, mode, platform) return true end)
    end)
    add(function(player, platform)
      snapshot(player, "after")
      checks(player, platform)
    end)
    if mode == "walk" then
      add(function(player)
        try("start walking east", function()
          storage.autotest.walking = true
          return true
        end)
      end)
      for i = 1, 8 do
        add(function(player)
          local ok, tile = pcall(player.surface.get_tile, player.surface, player.position)
          out(string.format("  walk %d: pos=%.1f,%.1f tile=%s character_valid=%s health=%s", i,
            player.position.x, player.position.y, ok and tile.name or "?",
            tostring(player.character ~= nil and player.character.valid),
            tostring(player.character and player.character.health)))
        end)
      end
      add(function(player, platform)
        storage.autotest.walking = false
        try("teleport 80 tiles off platform", function()
          local p = platform.hub.position
          return player.teleport({ x = p.x + 80, y = p.y }, platform.surface)
        end)
      end)
      add(function(player)
        snapshot(player, "off platform")
        try("tile under player", function()
          return player.surface.get_tile(player.position).name
        end)
        try("character health", function() return player.character and player.character.health end)
      end)
    end
  end
  add(function()
    try("auto_save", function() game.auto_save("skyp-autotest") return true end)
    out("DONE")
  end)
  return steps
end

-- Keeps the walk input held; walking_state only lasts one tick.
function M.walk_tick()
  local t = storage.autotest
  if not (t and t.walking) then return end
  local player = game.get_player(t.player)
  if player and player.valid and player.character then
    player.walking_state = { walking = true, direction = defines.direction.east }
  end
end

function M.active()
  return script.active_mods["sky-proto-autotest"] ~= nil
end

-- Called from control.lua after the default mode is applied for a player.
function M.start(player)
  storage.autotest = { player = player.index, step = 1, next_tick = game.tick + 60 }
  out("autotest start, Factorio " .. script.active_mods["base"] .. ", tick " .. game.tick)
end

function M.tick(platform_of, apply)
  local t = storage.autotest
  if not t or t.done or game.tick < t.next_tick then return end
  local player = game.get_player(t.player)
  local platform = player and platform_of(player)
  if not (player and platform) then return end
  local steps = build_steps(t.player)
  local step = steps[t.step]
  if not step then t.done = true return end
  local ok, err = pcall(step, player, platform, apply)
  if not ok then out("  step " .. t.step .. " ERROR " .. tostring(err)) end
  t.step = t.step + 1
  t.next_tick = game.tick + 30
end

return M

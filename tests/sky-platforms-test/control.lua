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
  { "stone-furnace", 4 }, { "lab", 2 }, { "solar-panel", 20, true }, { "inserter", 40, true },
  { "transport-belt", 100, true }, { "space-platform-foundation", 50, true },
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
end

local function check_techs(force)
  for _, name in ipairs(TECHS) do
    local tech = force.technologies[name]
    check("researched " .. name, tech ~= nil and tech.researched, tech and "" or "missing")
  end
end

local steps = {
  function()
    guarded("kit", function()
      local force = game.forces["player"]
      check_platform_and_kit(force)
      check_techs(force)
    end)
  end,
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

script.on_nth_tick(STEP_TICKS, function()
  local test = storage.test
  if not test or test.done then return end
  if not test.player then
    -- Headless runs have no player. Say so once, then keep waiting.
    if game.tick >= 300 and not test.warned then
      test.warned = true
      out("SKIP player checks, no player has joined yet")
    end
    if game.tick >= 300 and not test.ran_headless then
      test.ran_headless = true
      steps[1]()
    end
    return
  end
  if game.tick < test.next_tick then return end
  local step = steps[test.step]
  if not step then
    finish()
    return
  end
  step()
  test.step = test.step + 1
  test.next_tick = game.tick + STEP_TICKS
end)
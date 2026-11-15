-- Orbit bootstrap: the first platform, its kit and the starting research.
local registry = require("scripts.registry")

local bootstrap = {}

local START_TECHS = {
  "space-platform",
  "thud-orbital-ascent",
  "steam-power",
  "electronics",
  "automation-science-pack",
  "automation",
}

-- Counts for these items are multiplied by the kit-scale setting.
local KIT = {
  { name = "asteroid-collector", count = 4 },
  { name = "crusher", count = 4 },
  { name = "assembling-machine-1", count = 4 },
  { name = "stone-furnace", count = 4 },
  { name = "lab", count = 2 },
  { name = "solar-panel", count = 20, scaled = true },
  { name = "inserter", count = 40, scaled = true },
  { name = "transport-belt", count = 100, scaled = true },
  { name = "space-platform-foundation", count = 50, scaled = true },
  { name = "thud-inertial-damper", count = 1 },
}

--- The kit as an ordered array of item stacks, with the scale applied and rounded to nearest.
---@return ItemStackDefinition[]
function bootstrap.kit()
  local scale = settings.startup["sky-platforms-kit-scale"].value --[[@as number]]
  local stacks = {}
  for _, entry in ipairs(KIT) do
    local count = entry.count
    if entry.scaled then
      count = math.max(1, math.floor(count * scale + 0.5))
    end
    stacks[#stacks + 1] = { name = entry.name, count = count }
  end
  return stacks
end

---@param force LuaForce
function bootstrap.set_start_research(force)
  for _, name in ipairs(START_TECHS) do
    local tech = force.technologies[name]
    if tech then
      tech.researched = true
    else
      log("[sky-platforms] start technology not found: " .. name)
    end
  end
end

--- Create the starting platform at the Drift and fill the hub. Returns the registry ID.
---@param force LuaForce
---@return integer?
function bootstrap.run(force)
  -- create_space_platform only accepts planets, so create at Nauvis and move at once.
  local platform = force.create_space_platform({
    planet = "nauvis",
    starter_pack = "space-platform-starter-pack",
  })
  if not platform then
    log("[sky-platforms] could not create the starting platform")
    return nil
  end
  platform.space_location = "sky-drift"
  local hub = platform.apply_starter_pack()
  if hub and hub.valid then
    for _, stack in ipairs(bootstrap.kit()) do
      local inserted = hub.insert(stack)
      if inserted < stack.count then
        log(string.format("[sky-platforms] kit stack did not fit: %d of %d %s inserted",
          inserted, stack.count, stack.name))
        local wanted = stack.count or 1
        game.print({ "sky-platforms.kit-did-not-fit", wanted - inserted, wanted, stack.name })
      end
    end
  else
    log("[sky-platforms] the starting platform has no hub")
  end
  local id = registry.register(platform)
  storage.home_platform[force.index] = id
  bootstrap.set_start_research(force)
  storage.bootstrap_done = true
  local location = platform.space_location --[[@as {name: string}?]]
  log(string.format("[sky-platforms] home platform %d created at %s", id, tostring(location and location.name)))
  return id
end

return bootstrap
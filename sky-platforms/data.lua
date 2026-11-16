-- The Drift is a plain space-location. create_space_platform only accepts planets,
-- so the platform is created at Nauvis and moved here (scripts/bootstrap.lua).
-- Icons are copied from solar-system-edge until the Drift has its own art.
local drift = table.deepcopy(data.raw["space-location"]["solar-system-edge"])
drift.name = "sky-drift"
drift.order = "a[sky-drift]"
drift.gravity_pull = -10
drift.distance = 5
drift.orientation = 0.25
drift.magnitude = 1.0
-- solar-system-edge has very little sunlight. Use the Nauvis orbit value (300) so solar panels work.
drift.solar_power_in_space = data.raw.planet["nauvis"].solar_power_in_space
drift.asteroid_spawn_influence = 1

-- Chunks only, in the Nauvis orbit ratio 3 : 2 : 1 metallic : carbonic : oxide.
-- 0.0125 per second is the highest vanilla orbit rate (nauvis_chunks).
local CHUNK_PROBABILITY = 0.0125
local function chunk(name, ratio)
  return {
    type = "asteroid-chunk",
    asteroid = name,
    probability = CHUNK_PROBABILITY * ratio / 3,
    speed = 1 * meter / second,
    angle_when_stopped = 1,
  }
end
drift.asteroid_spawn_definitions = {
  chunk("metallic-asteroid-chunk", 3),
  chunk("carbonic-asteroid-chunk", 2),
  chunk("oxide-asteroid-chunk", 1),
}

data:extend({ drift })

-- Space Age unlocks the foundation recipe with rocket-silo, which this mod never
-- needs early. A cheap red-science tech unlocks it instead (decided 2026-11-16).
data:extend({
  {
    type = "technology",
    name = "sky-platform-foundation",
    icon = "__space-age__/graphics/technology/space-platform.png",
    icon_size = 256,
    effects = { { type = "unlock-recipe", recipe = "space-platform-foundation" } },
    prerequisites = { "steel-processing" },
    unit = {
      count = 50,
      ingredients = { { "automation-science-pack", 1 } },
      time = 15,
    },
  },
})
-- Copper and stone crushing, enabled from the start. Same category, time and chunk
-- return as vanilla metallic-asteroid-crushing (2 s, 30% chance to get the chunk back).
local function crushing(name, chunk_name, ore_name, ore_icon, order)
  return {
    type = "recipe",
    name = name,
    icons = {
      { icon = "__space-age__/graphics/icons/" .. chunk_name .. ".png", icon_size = 64, scale = 0.5, shift = { -4, -4 } },
      { icon = ore_icon, icon_size = 64, scale = 0.5, shift = { 6, 6 } },
    },
    categories = { "crushing" },
    subgroup = "space-crushing",
    order = order,
    auto_recycle = false,
    enabled = true,
    ingredients = {
      { type = "item", name = chunk_name, amount = 1, ignored_by_stats = 1 },
    },
    energy_required = 2,
    results = {
      { type = "item", name = ore_name, amount = 6 },
      { type = "item", name = chunk_name, amount = 1, independent_probability = 0.3, ignored_by_stats = 1 },
    },
    allow_productivity = true,
    allow_decomposition = false,
  }
end

data:extend({
  crushing("sky-metallic-crushing-copper", "metallic-asteroid-chunk", "copper-ore",
    "__base__/graphics/icons/copper-ore.png", "b-a-d[sky-metallic-crushing-copper]"),
  crushing("sky-oxide-crushing-stone", "oxide-asteroid-chunk", "stone",
    "__base__/graphics/icons/stone.png", "b-a-e[sky-oxide-crushing-stone]"),
})

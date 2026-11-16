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
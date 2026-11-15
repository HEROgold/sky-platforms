# Spec: Orbit bootstrap

## Summary

The game starts on a space platform orbiting a new space location, the Drift. The platform hub holds a starting kit. Asteroid crushing alone must feed the first hours, so the mod adds copper and stone crushing recipes and cuts the thruster research to red science. The player never needs a planet to begin.

Decided on 2026-11-15:

- New space location "the Drift", internal name `sky-drift`, with all three asteroid types (metallic, carbonic, oxide). The game starts on one platform orbiting it.
- Starting kit in the hub: 4 asteroid collectors, 4 crushers, 4 assemblers, 4 furnaces, 2 labs, solar panels, inserters, belts, space platform foundation, 1 `mech-armor` and 1 Thud damper.
- New asteroid crushing recipes for copper ore and stone, available from the start, at low yields.
- `space-platform-thruster` costs red science only. Its fuel and oxidizer chain is reachable with red science.
- `thud-orbital-ascent` and `space-platform` start researched.
- Dependencies: Thud (required), Space Age.
- Out of scope: hiding vanilla planets from the star map (see #9).

## Parent design

#8, `docs/design/gameplay-flow.md`. Related: #6 (`docs/spec/start-and-respawn.md`, owns the home platform and the character placement code), #9 (planets, hides vanilla planets).

## Behaviour

1. A new game creates one platform at game start, owned by the first player's force, orbiting `sky-drift`.
2. The platform hub holds the kit: 4 `asteroid-collector`, 4 `crusher`, 4 `assembling-machine-1`, 4 `stone-furnace`, 2 `lab`, `solar-panel` x TBD, `inserter` x TBD, `transport-belt` x TBD, `space-platform-foundation` x TBD, 1 `mech-armor`, 1 `thud-inertial-damper`. Exact amounts are in Open numbers.
3. The first player's character wears the `mech-armor`. The kit's `mech-armor` is in the hub, not a second copy. See statement 4.
4. The mod inserts the armor into the character's armor inventory (`defines.inventory.character_armor`) and not into the hub, so the kit holds exactly one `mech-armor` in total. `TBD (proposed: the one armor goes on the first player; the hub gets none)`.
5. The player stands on the platform, not on Nauvis (via #6, slice 1).
6. The platform orbits `sky-drift` (`platform.space_location.name == "sky-drift"`). It is created at Nauvis and moved to `sky-drift` in the same tick, because `create_space_platform` only accepts planets (tested).
7. Asteroid collectors on the platform receive chunks of all three types: metallic, carbonic and oxide.
8. The recipes `sky-copper-asteroid-crushing` and `sky-stone-asteroid-crushing` are enabled in a new game without research. A crusher can run them.
9. A crusher running `sky-copper-asteroid-crushing` outputs fewer copper ore per chunk than the metallic recipe outputs iron ore (20).
10. Technologies `space-platform` and `thud-orbital-ascent` are researched at game start. The `create-space-platform` research trigger of `space-platform` does not need to fire.
11. `space-platform-thruster` needs only `automation-science-pack`. It has no `space-science-pack` prerequisite and no `space-science-pack` in its ingredients.
12. After researching `space-platform-thruster` with red science, the player can craft the `chemical-plant`, run `ice-melting`, `thruster-fuel` and `thruster-oxidizer`, and craft a `thruster`.
13. The thruster chain needs no oil, no plastic, and no item that a planet gives. Carbon comes from carbonic chunks, iron ore from metallic chunks, water from ice.
14. Nauvis still exists as a surface. No player stays on it (see Control stage, "Leaving Nauvis").
15. The game does not show the freeplay intro, the crash site, or the freeplay starting items.

## Data stage

### Space location

```lua
{
  type = "space-location",
  name = "sky-drift",
  icon = "__sky-platforms__/graphics/icons/sky-drift.png",       -- art TBD
  starmap_icon = "__sky-platforms__/graphics/icons/starmap-sky-drift.png",
  starmap_icon_size = 512,
  subgroup = "planets",
  order = "a[sky-drift]",
  gravity_pull = -10,       -- TBD (proposed: -10, same as solar-system-edge)
  distance = 5,             -- TBD (proposed: 5)
  orientation = 0.25,       -- TBD (proposed: 0.25)
  magnitude = 1.0,
  asteroid_spawn_influence = 1,
  asteroid_spawn_definitions = ...,  -- see below
}
```

Reference: `solar-system-edge` is a plain `space-location` with these fields at `__space-age__/prototypes/planet/planet.lua:706-721`. `PlanetPrototype`'s parent is `SpaceLocationPrototype` (`prototype-api.json`), so a plain `space-location` is valid for platforms to orbit. Vanilla has no precedent for starting a game there. This is the unproven part of the spec.

Asteroid spawn definitions for orbit: Space Age builds them with `asteroid_util.spawn_definitions(data, planet)`, passing a `planet` argument to get one fixed probability per asteroid (`__space-age__/prototypes/planet/asteroid-spawn-definitions.lua:368-441`). With `planet ~= nil` the helper reads `probability_on_range_*` at that planet's position and emits `{ asteroid, probability, speed, angle_when_stopped }` entries. For the Drift, write the entries by hand and do not use the helper, because the helper's tables are keyed to Space Age planets. Proposed entries, copied in shape from the helper output:

- `metallic-asteroid-chunk`, `carbonic-asteroid-chunk`, `oxide-asteroid-chunk`, each `type = "asteroid-chunk"`, `speed = 1 * meter/second` (the helper's `standard_speed`), `angle_when_stopped = 1` (the helper's `chunk_angle`).
- Chunk probability `TBD (proposed: 0.0125 each)`, which equals `nauvis_chunks` (asteroid-spawn-definitions.lua:17). This is the highest vanilla orbit rate. A starting platform with 4 collectors needs it.
- Ratio `TBD (proposed: 3 : 2 : 1 metallic : carbonic : oxide)`, which equals `nauvis_ratio` (line 10). Metallic feeds iron and now copper, carbonic feeds thruster fuel, oxide feeds ice.
- Small, medium and big asteroids: none at the Drift. `TBD (proposed: none in 0.x)`. Collectors then catch only chunks, and no turret defence is needed at the start.

Space connections are not defined here. Without a `space-connection`, a platform at the Drift cannot leave. Connections belong to the planets spec (#9). The Drift is reachable as the start. Note this as a dependency for #9.

### Recipes

```lua
{
  type = "recipe",
  name = "sky-copper-asteroid-crushing",
  categories = {"crushing"},
  subgroup = "space-crushing",
  order = "b-b-a",
  auto_recycle = false,
  enabled = true,
  energy_required = 2,
  ingredients = {{ type = "item", name = "metallic-asteroid-chunk", amount = 1, ignored_by_stats = 1 }},
  results = {{ type = "item", name = "copper-ore", amount = 6 }},   -- TBD (proposed: 6)
}
{
  type = "recipe",
  name = "sky-stone-asteroid-crushing",
  categories = {"crushing"},
  subgroup = "space-crushing",
  order = "b-b-b",
  auto_recycle = false,
  enabled = true,
  energy_required = 2,
  ingredients = {{ type = "item", name = "oxide-asteroid-chunk", amount = 1, ignored_by_stats = 1 }},
  results = {{ type = "item", name = "stone", amount = 6 }},        -- TBD (proposed: 6)
}
```

Shape follows the vanilla recipes `metallic-asteroid-crushing` (energy 2, `categories = {"crushing"}`, `auto_recycle = false`, `enabled = false`) at `__space-age__/prototypes/recipe.lua:890-910`. Vanilla values for comparison: metallic chunk gives 20 iron ore, carbonic gives 10 carbon, oxide gives 5 ice. Advanced recipes (late game) give 10 iron and 4 copper from a metallic chunk, 5 carbon and 2 sulfur from carbonic, 3 ice and 2 calcite from oxide. Copper at 6 per chunk is below the advanced 10 + 4 mix on total and well below the iron yield. The mod does not change the vanilla advanced recipes.

Stone from oxide is a proposal. The brief names no source chunk. Alternatives are listed in Open numbers.

### Technologies

`space-platform` (vanilla, `technology.lua:20-54`): prerequisite `rocket-silo`, `research_trigger = { type = "create-space-platform" }`. It unlocks `asteroid-collector`, `crusher`, `metallic-asteroid-crushing`, `carbonic-asteroid-crushing`, `oxide-asteroid-crushing` and `cargo-bay`. No data change is needed. The control stage sets it researched. The mod does not remove the `rocket-silo` prerequisite, because a researched technology with an unmet prerequisite is harmless in script.

`space-platform-thruster` (vanilla, `technology.lua:327-364`):

- Effects: `thruster`, `ice-melting`, `thruster-fuel`, `thruster-oxidizer`.
- Prerequisites: `space-science-pack`.
- Cost: 500 x automation, logistic, chemical and space science, 60 s each.

Change (in `data-updates.lua`, after Space Age loads):

```lua
local tech = data.raw.technology["space-platform-thruster"]
tech.prerequisites = { "steel-processing", "electronics" }   -- TBD, see below
tech.unit = {
  count = 200,                                               -- TBD (proposed: 200)
  ingredients = { { "automation-science-pack", 1 } },
  time = 30,                                                 -- TBD (proposed: 30)
}
table.insert(tech.effects, { type = "unlock-recipe", recipe = "chemical-plant" })
```

#### What the thruster chain needs

I checked which techs unlock each piece (Factorio 2.1.24 files):

| Piece | Unlocked by | Cost of that tech | Reachable with red only? |
| --- | --- | --- | --- |
| `thruster-fuel` (2 carbon + 10 water, `categories = {"chemistry"}`, `recipe.lua:1094-1114`) | `space-platform-thruster` (`technology.lua:344`) | re-costed here | yes |
| `thruster-oxidizer` (2 iron ore + 10 water, `recipe.lua:1126-1146`) | `space-platform-thruster` (`technology.lua:348`) | re-costed here | yes |
| `ice-melting` | `space-platform-thruster` (`technology.lua:340`) | re-costed here | yes |
| `chemical-plant` (5 steel, 5 gear, 5 electronic circuit, 5 pipe, `base/recipe.lua:2423-2434`) | `oil-processing` only (`base/technology.lua:4616`) | `research_trigger` "mine crude-oil", prerequisite `oil-gathering` (red + green, `base/technology.lua:4584-4600`) | no, there is no crude oil at the Drift |
| `thruster` (10 steel, 10 `processing-unit`, 5 `electric-engine-unit`, `recipe.lua:735-744`) | `space-platform-thruster` | re-costed here | the recipe is, its ingredients are not |
| `processing-unit` | `advanced-electronics-2` (`base/technology.lua:3030`) | needs chemical science in vanilla | no |
| `electric-engine-unit` | `electric-engine` (`base/technology.lua:3868`) | red + green + chemical, 50 units | no |
| `steel-plate` | `steel-processing` (`base/technology.lua:1983-2003`) | 50 x red | yes |
| `electronic-circuit`, `inserter`, `lab` | `electronics` (`base/technology.lua:54-86`) | `research_trigger` craft 10 copper plate | yes, by trigger |
| `automation-science-pack` recipe | `automation-science-pack` tech (`base/technology.lua:87-105`) | trigger "craft a lab", prerequisites `steam-power`, `electronics` | needs the trigger chain |

The minimum change has three parts.

1. **Chemical plant.** Add `{ type = "unlock-recipe", recipe = "chemical-plant" }` to `space-platform-thruster`. The chemical plant is the only machine for the `chemistry` category used by `thruster-fuel` and `thruster-oxidizer`, and its only unlock is `oil-processing`, which needs crude oil. Leave `oil-processing` unchanged. Its own unlock of the same recipe stays valid. Whether the chemical plant's `surface_conditions` allow a platform surface is not checked. The thruster recipes require `gravity` min 0, max 0 (`recipe.lua:1105-1112`), which a platform meets.
2. **Thruster recipe.** The `thruster` recipe needs `processing-unit` and `electric-engine-unit`, both locked behind chemical science and oil. Red science alone would research the tech and still leave the thruster uncraftable. Override the recipe ingredients: `TBD (proposed: steel-plate 10, electronic-circuit 10, iron-gear-wheel 10, pipe 5)`. This keeps the steel-and-electronics feel and needs only items that red-science techs and the kit unlock. This changes a vanilla recipe. It is the minimum change that makes statement 12 true. The alternative of unlocking `processing-unit` and `electric-engine-unit` drags in plastic, sulfur and lubricant, which need oil.
3. **Prerequisites.** `steel-processing` (red) is needed for steel. `electronics` is a trigger tech (craft 10 copper plate) and gets set researched at start (see Control stage). The prerequisite list `{ "steel-processing", "electronics" }` is a proposal. `steel-processing` must be researchable with red science in a new game, and `automation-science-pack` (the tech that unlocks the red science recipe) must be researched at start (Control stage).

Techs that list `space-platform-thruster` as a prerequisite (`technology.lua:383, 415, 451`) are unchanged. They keep their space science costs.

### Thud

`thud-orbital-ascent` is Thud's damper tech name, from `docs/design/gameplay-flow.md:13`. The damper item is `thud-inertial-damper` (Thud 2.2.0, `data/damper/damper.lua:11`).

### Freeplay and scenario

None. The mod uses the freeplay remote interface at runtime (below).

## Control stage

### Storage

```lua
storage.bootstrap_done = false      -- true after the first platform and kit exist
```

The home platform tables belong to #6 (`storage.home_platform`, `storage.respawn_choice`).

### Events and handlers

| Event | Handler |
| --- | --- |
| `on_init` | Call the freeplay remote interface, then set `bootstrap_done = false`. |
| `on_player_created` | If `not storage.bootstrap_done`, run `bootstrap(force)`, then call #6's `place_on_home(player)`. |
| `on_configuration_changed` | Re-set the starting researched list if `bootstrap_done` is false. Do nothing otherwise. |

### Freeplay remote interface

`on_init` calls these verified functions. Each call lives in a closure, because some may be missing when freeplay is not loaded:

```lua
local function call_freeplay(fn, ...)
  local args = { ... }
  if remote.interfaces["freeplay"] and remote.interfaces["freeplay"][fn] then
    return remote.call("freeplay", fn, table.unpack(args))
  end
end
call_freeplay("set_skip_intro", true)
call_freeplay("set_disable_crashsite", true)
call_freeplay("set_created_items", {})
```

`set_skip_intro`, `set_disable_crashsite` and `set_created_items` exist and work (prototype, Factorio 2.1.24). They stop the freeplay crash site and starting items, so the kit is the only start.

### Bootstrap

```lua
local function bootstrap(force)
  -- create_space_platform only accepts planets, so create at Nauvis and move at once.
  local platform = force.create_space_platform({
    planet = "nauvis",
    starter_pack = "space-platform-starter-pack",
  })
  platform.space_location = "sky-drift"
  local hub = platform.apply_starter_pack()
  for _, stack in pairs(KIT) do
    hub.insert(stack)
  end
  storage.home_platform[force.index] = platform.index
  set_start_research(force)
  storage.bootstrap_done = true
end
```

Verified (prototype, Factorio 2.1.24): `force.create_space_platform({ planet = "nauvis", starter_pack = "space-platform-starter-pack" })` returns a `LuaSpacePlatform`, `platform.apply_starter_pack()` returns the hub, and `platform.hub.insert(item)` works. `LuaSpacePlatform.apply_starter_pack(silent)` returns the hub entity (`runtime-api.json`).

#### Can the platform start at the Drift

Tested headless on Factorio 2.1.24 (2026-11-15) with a throwaway mod that defines `sky-drift` as a copy of `solar-system-edge`:

- `create_space_platform({ planet = "sky-drift", ... })` fails with "Given space location is not a planet."
- `create_space_platform({ planet = "nauvis", ... })`, then `platform.space_location = "sky-drift"`, works. `platform.space_location.name` reads `sky-drift` afterwards.

So `sky-drift` stays a plain `space-location`, and bootstrap uses the create-then-move route above. Writing `space_location` "will cancel pending item requests" (`runtime-api.json`), which doesn't matter on a new platform.

### Kit

Items inserted into the hub:

```lua
local KIT = {
  { name = "asteroid-collector", count = 4 },
  { name = "crusher", count = 4 },
  { name = "assembling-machine-1", count = 4 },
  { name = "stone-furnace", count = 4 },
  { name = "lab", count = 2 },
  { name = "solar-panel", count = 20 },               -- TBD
  { name = "inserter", count = 40 },                  -- TBD
  { name = "transport-belt", count = 100 },           -- TBD
  { name = "space-platform-foundation", count = 50 }, -- TBD
  { name = "thud-inertial-damper", count = 1 },
}
```

`mech-armor` goes into the first character's armor slot via `get_inventory(defines.inventory.character_armor).insert("mech-armor")` after placement. The hub keeps one copy only if a later spec adds one. `TBD (proposed: character gets it, hub holds none)`.

Hub inventory size limits what fits. `hub.insert` returns the count inserted. Compare to the request. If a stack does not fit, print one message in the log and continue. The hub's slot count is not looked up here, so the kit total is checked in game (slice 1).

### Starting research

`set_start_research(force)` sets `force.technologies[name].researched = true` for each name in this list:

- `space-platform` (decided).
- `thud-orbital-ascent` (decided).
- `electronics`, `steam-power`, `automation-science-pack`, `automation`: needed so labs get red science. `TBD (proposed: exactly these four)`. The red science recipe is unlocked by `automation-science-pack` (`base/technology.lua:87-105`), a trigger tech that needs `steam-power` and `electronics`. Without them the player cannot craft red science. The `automation` tech name is from memory and not checked, so confirm each name in `prototypes` before shipping.

`LuaTechnology.researched` is a read and write attribute in the runtime API. This is from memory, so confirm it in slice 1.

### Leaving Nauvis

The game creates Nauvis as the first surface and gives each new player a character there. #6 handles the move:

1. `on_player_created` runs `place_on_home(player)`. It creates a character on the platform, sets the controller, and destroys the Nauvis character (verified route).
2. Nauvis stays loaded. The mod does not delete it. `game.delete_surface` on the starting surface is not tried here.
3. No chunks around Nauvis 0,0 are generated for players. Vanilla generates a start area at game creation. The mod does not suppress it.
4. Hiding Nauvis and the other planets from the star map is out of scope. Spec #9 owns it.

## Settings

| Name | Type | Default | Use |
| --- | --- | --- | --- |
| `sky-platforms-copper-crush-yield` | startup, int, min 1, max 20 | 6 `TBD (proposed: 6)` | Copper ore per metallic chunk in `sky-copper-asteroid-crushing`. |
| `sky-platforms-stone-crush-yield` | startup, int, min 1, max 20 | 6 `TBD (proposed: 6)` | Stone per oxide chunk in `sky-stone-asteroid-crushing`. |
| `sky-platforms-thruster-tech-count` | startup, int, min 10, max 1000 | 200 `TBD (proposed: 200)` | Red science units for `space-platform-thruster`. |
| `sky-platforms-kit-scale` | startup, double, min 0.5, max 4 | 1 | Multiplies the kit counts of solar panels, inserters, belts and foundation. |

Startup settings, not runtime, because they change prototypes or the one-time kit.

## Storage and migrations

- New saves: `on_init` creates `storage.bootstrap_done = false`.
- Existing saves that add the mod: `bootstrap_done` is nil. `on_configuration_changed` sets it to `true` and does nothing else, because an existing game already has progress. The kit is never given to an existing save. `TBD (proposed: skip bootstrap on saves with any existing platform or tick > 0)`.
- Migration file: None for 0.1.0 to 0.3.0. Slice 2 changes the start location for new games only.

## Multiplayer and determinism

- Bootstrap runs once, on the first `on_player_created` of the game, on all peers in the same tick with the same inputs.
- The kit table is a fixed ordered array. Insert it in array order, never with `pairs` over a hash.
- A player who joins after bootstrap skips it and goes straight to #6's `place_on_home`.
- Research flags are set in the same handler as the platform. Peers run the same order.
- No randomness is used. Asteroid spawns are the engine's own and deterministic.
- Risk: loading a save made before `bootstrap_done` existed. `on_configuration_changed` covers it (Storage and migrations).
- Risk: the freeplay interface runs in `on_init`. If freeplay's own `on_init` runs after ours, our calls may be overwritten. Test the order in slice 1 and move the calls into `on_player_created` if needed.

## Slices

- [ ] 1. Start on a platform with the kit
- [ ] 2. Orbit the Drift
- [ ] 3. Copper and stone crushing
- [ ] 4. Red-science thruster chain

### Slice 1. Start on a platform with the kit

This is the smallest installable thing. After it ships, a new game puts the player on a platform with the kit, armor on, labs and crushers ready, no crash site. The platform orbits Nauvis in this slice (verified call). Thud is a required dependency from here.

Acceptance criteria:

- [ ] A new game does not play the freeplay intro or the crash site.
- [ ] The player stands on a platform within 5 tiles of the hub (via #6 slice 1).
- [ ] The hub holds 4 asteroid collectors, 4 crushers, 4 assemblers, 4 furnaces, 2 labs, solar panels, inserters, belts, foundation and 1 Thud damper.
- [ ] The character wears `mech-armor` and can fly over `empty-space`.
- [ ] `space-platform` and `thud-orbital-ascent` are researched. The four start techs are researched.
- [ ] The player can craft red science and research with a placed lab.
- [ ] Every kit stack fits, or a log line names the stack that did not.
- [ ] `emmylua_check` passes. A headless `factorio --create` run loads the mod with Space Age and Thud.

Path to prod:

- Target release: 0.1.0 (together with start-and-respawn slice 1).
- Save migration: no.
- In-game test steps: 1. New game. 2. Check the hub inventory against the list. 3. Check armor and fly over space. 4. Open the technology screen and check the researched list. 5. Craft a red science pack. 6. Place a collector and a crusher.
- Changelog line: "New games start on a space platform with a starting kit."

### Slice 2. Orbit the Drift

After this ships, the platform orbits the Drift and its collectors catch metallic, carbonic and oxide chunks.

Acceptance criteria:

- [ ] `data.raw["space-location"]["sky-drift"]` exists and loads headless.
- [ ] `platform.space_location.name == "sky-drift"` after bootstrap.
- [ ] Within 10 minutes of play, a collector catches at least one chunk of each type.
- [ ] The platform never shows Nauvis as its location.
- [ ] The star map shows the Drift. Hiding other locations is not tested here.

Path to prod:

- Target release: 0.2.0.
- Save migration: no. Saves from 0.1.0 keep their Nauvis orbit. `TBD (proposed: no automatic move)`.
- In-game test steps: 1. New game. 2. Open the platform tab and read the location. 3. Run collectors for 10 minutes and check chunk types. 4. `/c game.print(game.forces.player.platforms[1].space_location.name)`.
- Changelog line: "The start platform now orbits the Drift, a new space location with all three asteroid types."

### Slice 3. Copper and stone crushing

After this ships, a crusher turns metallic chunks into copper ore and oxide chunks into stone from the first minute.

Acceptance criteria:

- [ ] Both recipes are enabled in a new game without research.
- [ ] A crusher set to `sky-copper-asteroid-crushing` outputs the configured copper ore per chunk.
- [ ] A crusher set to `sky-stone-asteroid-crushing` outputs the configured stone per chunk.
- [ ] Both yields are below the matching vanilla recipe yields (iron 20 for metallic).
- [ ] Vanilla crushing recipes are unchanged.
- [ ] The two startup settings change the yields.

Path to prod:

- Target release: 0.3.0.
- Save migration: yes in effect, but handled with `migrations/0.3.0.lua`, which sets the two recipes enabled on every force (recipes from a new mod version start disabled on loaded saves if `enabled` is read from the saved state). `TBD (proposed: write the migration and test with a 0.2.0 save)`.
- In-game test steps: 1. Place a crusher. 2. Set each recipe. 3. Feed chunks with `/c` or collectors. 4. Count outputs. 5. Load a 0.2.0 save and check the recipes are enabled.
- Changelog line: "Added copper and stone asteroid crushing, available from the start."

### Slice 4. Red-science thruster chain

After this ships, the player researches the thruster with red science, builds a chemical plant, makes fuel and oxidizer from asteroid products, and crafts a thruster.

Acceptance criteria:

- [ ] `space-platform-thruster` has no `space-science-pack` prerequisite and only `automation-science-pack` as an ingredient.
- [ ] After the research, `chemical-plant`, `ice-melting`, `thruster-fuel`, `thruster-oxidizer` and `thruster` are craftable or placeable.
- [ ] A chemical plant on the platform runs `thruster-fuel` from carbon (crushed carbonic chunks) and water (melted ice).
- [ ] A chemical plant runs `thruster-oxidizer` from iron ore and water.
- [ ] The thruster recipe uses only items reachable without oil and without chemical science.
- [ ] Techs that depend on `space-platform-thruster` still load.

Path to prod:

- Target release: 0.4.0.
- Save migration: yes (`migrations/0.4.0.lua`: reset technology effects with `force.reset_technology_effects()` so the new `chemical-plant` unlock and changed recipe apply to saves). `TBD (proposed: write and test with a 0.3.0 save)`.
- In-game test steps: 1. Research `space-platform-thruster` with red packs only. 2. Craft a chemical plant. 3. Set each recipe and supply inputs. 4. Craft a thruster. 5. Load a 0.3.0 save and repeat.
- Changelog line: "The thruster now needs red science only, and its fuel chain works without oil."

## Path to prod

Releases are 0.1.0, 0.2.0, 0.3.0 and 0.4.0, one per slice. Slice 1 ships with start-and-respawn slice 1 as 0.1.0. Release numbers of the two specs share one sequence, so the later slices of both specs must be interleaved by the maintainer when 0.2.0 or later is planned.

Every release passes these checks before upload:

1. `emmylua_check` with the Factorio type library.
2. A headless `factorio --create` load with Space Age and Thud.
3. The in-game self-test: the test steps of every slice shipped so far.

Target release: 0.1.0 to 0.4.0 as above.
Save migration: slice 1 no, slice 2 no, slice 3 yes, slice 4 yes.

In-game test steps: see each slice.

Changelog section (mod portal): one line per slice, as written in the slices.

## Open numbers

- `TBD (proposed: 20)` solar panels in the kit. Enough to power 4 assemblers, 2 labs and inserters in daylight orbit. Panels give no night power, so batteries come later.
- `TBD (proposed: 40)` inserters in the kit. About 10 per machine row. Cheap to craft from copper and iron.
- `TBD (proposed: 100)` transport belts in the kit. Two belt loops across the first factory.
- `TBD (proposed: 50)` space platform foundation. One 5-tile-wide extension strip across the starting size, with some left over.
- `TBD (proposed: 6)` copper ore per metallic chunk. Under the advanced recipe's 4 copper plus 10 iron mix in effect and well under the 20 iron of the basic recipe, so copper is slow.
- `TBD (proposed: 6)` stone per oxide chunk. Same low rate as copper. Oxide chunks also feed ice, so stone competes with water.
- `TBD (proposed: oxide chunk as the stone source)` the brief gives no source. Carbonic would compete with thruster fuel carbon.
- `TBD (proposed: 200)` red science units for `space-platform-thruster`. Vanilla is 500. Red-only techs in vanilla run 50 to 100 units. 200 keeps it a mid-early goal.
- `TBD (proposed: 30)` seconds per unit for that tech. Vanilla is 60. Red-only techs use 5 to 30 seconds.
- `TBD (proposed: steel-plate 10, electronic-circuit 10, iron-gear-wheel 10, pipe 5)` thruster recipe. Replaces `processing-unit` and `electric-engine-unit`, which need chemical science and oil.
- `TBD (proposed: steel-processing, electronics)` prerequisites of `space-platform-thruster`. Steel is a red tech. Electronics is a trigger tech set researched at start.
- `TBD (proposed: electronics, steam-power, automation-science-pack, automation)` extra start-researched techs. They are the chain behind the red science recipe. `automation` is unverified.
- `TBD (proposed: 0.0125 for each chunk type)` chunk spawn probability at the Drift. Equals `nauvis_chunks`, the highest vanilla orbit rate.
- `TBD (proposed: 3 : 2 : 1)` metallic : carbonic : oxide ratio. Equals `nauvis_ratio`. Iron and copper first, then carbon, then ice.
- `TBD (proposed: none)` small, medium and big asteroids at the Drift. No defence needed in the first hours.
- `TBD (proposed: -10, 5, 0.25)` `gravity_pull`, `distance` and `orientation` of `sky-drift`. Same pull as `solar-system-edge`. The others only place the icon, and #9 can move them.
- `TBD (proposed: character gets mech-armor, hub holds none)` where the one armor goes.
- `TBD (proposed: skip bootstrap on saves with any platform or tick > 0)` bootstrap on an existing save. Never hand a kit to a running game.
- `TBD (proposed: 1)` default of `sky-platforms-kit-scale`. The decided kit is the baseline.

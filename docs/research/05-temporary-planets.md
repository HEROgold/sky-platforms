# Temporary planets: creating, removing and what it costs

Sources: Factorio 2.1.24 `runtime-api.json` and `prototype-api.json`, and Warptorio Space Age 0.4.7 source (read for ideas only). Where the docs are silent the text says "not found". Warptorio paths are relative to `warptorio\warptorio-space-age\`.

## 1. Runtime planets versus data-stage prototypes

Not found: any runtime API that creates a planet or space location. `LuaGameScript` has only `create_surface`, `delete_surface` and `get_surface` for surface work (LuaGameScript methods list). `LuaGameScript.planets` is a read view of existing planets. `LuaPlanet` has `create_surface`, `associate_surface`, `reset_map_gen_settings` and `get_space_platforms`, and nothing that creates a planet.

`PlanetPrototype` (parent `SpaceLocationPrototype`) and `SpaceConnectionPrototype` are prototypes, so they exist only at data stage. `SpaceLocationPrototype.distance` and `.orientation` are required fields, so a location's map position is fixed when the data stage ends.

Warptorio agrees. It adds no planet prototypes and rolls among the existing ones through `game.planets` (`control.lua:2211`, `modules/planet_roll.lua:13`).

Conclusion: yes, the realistic model is a fixed pool of N planet prototypes. A "new planet" is a surface regenerated on an existing prototype. The prototype keeps its name, icon, position and connections. The mod can change only the surface contents and what the player is told.

Two data-stage properties help with a pool. `SpaceLocationPrototype.hidden` hides a location from the planet selection lists and the space map. `LuaForce.unlock_space_location` and `LuaForce.lock_space_location` toggle access at runtime (LuaForce methods list). Together these let the mod show only the active unstable planets. Whether a hidden location is still reachable by script or schedule is not found.

## 2. Deleting and recreating a surface under a surviving prototype

The planet object stays when its surface goes. `LuaPlanet.surface` is "the surface for this planet if one currently exists", and "planets do not default generate their surface". `LuaPlanet.create_surface` "creates the associated surface if one doesn't already exist". So the cycle is `game.delete_surface(planet.surface)` and later `planet.create_surface()`.

`LuaGameScript.delete_surface` "deletes the given surface and all entities on it if possible". Only the primary surface (nauvis) cannot be deleted. `on_pre_surface_deleted` and `on_surface_deleted` fire, so the mod can clean its own bookkeeping.

Warptorio does exactly this cycle on a stock planet. It deletes the old planet surface, calls `LuaPlanet.create_surface()` and renames the result (`modules/surface_creation.lua:110-122`). The same file has an alternative: `game.create_surface(name, ms)` followed by `LuaPlanet.associate_surface(surf)` (lines 124-125). `associate_surface` requires that the planet has no surface yet and the surface has no planet (LuaPlanet.associate_surface). Warptorio uses the second path when the prototype does not have `entities_require_heating` (`modules/surface_creation.lua:116`). Why it splits the cases is not stated in the source. It looks like a way to pass fresh `map_gen_settings` to a new surface.

Warptorio also notes that `LuaPlanet.create_surface` returns the existing surface when one exists, so calling it twice reuses and does not regenerate (`control.lua:1784-1785`).

Warptorio sets `map_gen_settings` on an already existing surface before calling `create_surface` (`modules/surface_creation.lua:117-120`). `LuaSurface.map_gen_settings` says changes after generation "will not retroactively update the surface". Delete and recreate is therefore the clean way to get a fresh layout. `LuaSurface.clear` ("deleting all entities and chunks") is a second way that keeps the surface object and its index. `LuaSurface.delete_chunk`, `regenerate_entity` and `regenerate_decorative` can redo part of a surface.

What happens to platforms:

- A platform orbiting the planet has its own surface (`LuaSpacePlatform.surface`). It is a different surface from the planet's, so deleting the planet surface does not delete the platform surface by the surface API. The docs do not say what happens to a platform whose `space_location` is a planet that just lost its surface. Not found. Test in game.
- `LuaPlanet.get_space_platforms(force)` lists the platforms orbiting a planet. The mod can use it to check that none is parked before it deletes the surface, or to move them. `LuaSpacePlatform.space_location` is writable ("requires a valid space location"), and `space_connection` is writable and sets the distance to 0.5. Moving a platform off a dying planet by script is therefore supported by the API.
- Entities that Thud places on the planet surface, including a landed platform's foundation tiles and buildings, are ordinary entities on that surface. `delete_surface` removes them with it. The player must lift off before deletion. The mod needs a guard: do not delete while a landed platform exists. How Thud tracks landed state is not found here (Thud source not in the provided sources).
- Other mods keep per-surface registries. Warptorio hit a crash where Repair Turret kept stale entries after `clear()` or `delete_surface()`, because the surface index was reused (`modules/compat_repair_turret.lua:1-9`). Warptorio destroys those entities first with `raise_destroy=true` (`modules/surface_creation.lua:111`, `control.lua:1891`). The mod should do the same for anything it can find on a dying surface.

## 3. Varying resources per visit

`LuaGameScript.create_surface(name, settings)` takes `MapGenSettings`. The fields that matter are `autoplace_controls`, `autoplace_settings`, `default_enable_all_autoplace_controls`, `property_expression_names`, `seed`, `width`, `height` and `starting_points` (MapGenSettings in runtime-api and prototype-api).

For a pool prototype, `PlanetPrototype.map_gen_settings` and `map_seed_offset` set the defaults at data stage. The prototype's autoplace controls decide which resources exist by default. A planet prototype can only generate a resource whose autoplace is controlled by an autoplace control (or a noise expression) that the settings allow. Setting `default_enable_all_autoplace_controls = true` and listing controls explicitly gives the pool surface per-visit control. Whether controls from Vulcanus, Fulgora, Gleba and Aquilo work on a surface whose prototype is not that planet depends on each resource's autoplace expression. Some of those expressions read planet-specific noise such as elevation, moisture or aux. Not found in the API. Test in game.

Warptorio shows the approach on stock planets. It copies the planet prototype's `map_gen_settings` and merges a variant table (rich, normal, dwarf, dangerous, ribbon) into it. Each variant sets frequency, size and richness per resource through a lookup table of multipliers (`map_gens.lua:5-15`, `99-105`, `107-121`, `125-131`). It picks a variant at random and sets a new seed (`modules/surface_creation.lua:93-102`). It also reads settings with `game.planets[name].prototype.map_gen_settings` (`modules/surface_creation.lua:61`).

Answer to the uranium question: one prototype surface can have uranium on one visit and other resources on the next, if every wanted autoplace control is allowed in the settings and each resource's autoplace expression works away from its home planet. Both conditions need a prototype test. A fallback exists that needs no autoplace compatibility. Generate the surface with `default_enable_all_autoplace_controls = false` and place resource entities by script with `LuaSurface.create_entity` after chunk generation (`LuaSurface.request_to_generate_chunks`, `force_generate_chunk_requests`, and the `on_chunk_generated` event). That costs script time but is fully deterministic. The scripted route is not shown in Warptorio and is not found elsewhere in the sources.

Also for variety: `LuaPlanet.reset_map_gen_settings` restores the prototype defaults.

## 4. Travel to a new location

A location needs connections to be reachable by a platform. `SpaceConnectionPrototype` has required `from` and `to`, and an optional `length` in km. Connections are prototypes, so every pool planet needs its connections at data stage. The usual shape is a connection from a hub location (for example nauvis or the solar system edge) to each pool planet.

`SpaceLocationPrototype.distance` and `.orientation` place the location on the space map. `length` sets the trip distance. Travel time is `length` divided by platform speed. Speed is also changed by `gravity_pull` on the departing and arriving locations (SpaceLocationPrototype.gravity_pull). Exact speed numbers are not in the API docs, so they are not found here. Set `length` short for a quick sortie and long to make a planet feel far.

Because the prototype position is fixed, "a new planet appears" is a presentation matter. Options are `hidden` plus runtime lock and unlock, one location per pool slot at different orientations, or schedule changes through `LuaSpacePlatform.schedule` and `get_schedule` to send a platform. Warptorio never creates locations, only builds a `{type = "space-location", name = planet_name}` signal id (`warp_constant_combinator.lua:49`).

`asteroid_spawn_definitions` on the location and the connection decide what attacks platforms on the way. Per-location `asteroid_spawn_influence` interpolates over the route.

## 5. Cost

Not found in the API docs: timings for `delete_surface` and `create_surface`, chunk generation cost, or save size per chunk. These need measurement. What the docs do say:

- `LuaGameScript.create_surface` has a hard limit of 4 294 967 295 surfaces, which is not a practical limit.
- `MapGenSettings.width` and `height` limit surface size, with a silent maximum of 2 000 000 tiles. Setting small values keeps the surface small. Whether chunks beyond the limit are generated at all is not found, but a bounded surface prevents wandering generation.
- Chunks are generated on request. `request_to_generate_chunks(position, radius)` queues them asynchronously, and `force_generate_chunk_requests` blocks until they finish. `delete_chunk` removes single chunks.
- `LuaSurface.clear` removes all entities and chunks, which frees the data without removing the surface.
- The save keeps every generated chunk and entity on every surface, so deleting the surface when the visit ends removes its share from the save. This follows from `delete_surface` removing "all entities", and the size effect is not measured.

Warptorio's limits, all in `modules/surface_creation.lua`:

- It requests a bounded area only: radius 10 chunks at the fixed spawn (lines 23-27), or `max(ceil(platform*2/32)+2, 10)` chunks at a random center (lines 29-43). It does not call `force_generate_chunk_requests`, so generation is asynchronous.
- It restricts the random center to a configured range (`warp_settings.random_position_offset`, line 32).
- It keeps at most one planet surface and one old surface alive, deleting the old one at the next warp (`control.lua:1890-1894`, `modules/surface_creation.lua:110-114`).
- Void and space surfaces use settings with no autoplace controls (`modules/surface_creation.lua:8-20`), which are cheap to generate.
- Warptorio does not set `width` or `height` on the surfaces it creates (`width`/`height` not found in `surface_creation.lua`).

## 6. How Warptorio does it

| Step | Location |
| --- | --- |
| Settings for void and space surfaces | `modules/surface_creation.lua:8-20` |
| Choose the planet and copy its prototype map gen settings | `modules/surface_creation.lua:53-61` (`game.planets[...].prototype.map_gen_settings`) |
| Random variant and seed | `modules/surface_creation.lua:76`, `93-102` |
| Variant merge into planet settings | `map_gens.lua:107-121`, variant list `125-131` |
| Delete the previous planet surface, clear it first | `modules/surface_creation.lua:110-114` |
| Reuse the planet with `create_surface()` | `modules/surface_creation.lua:116-122` |
| Fresh surface plus `associate_surface` | `modules/surface_creation.lua:124-125` |
| Bounded chunk requests | `modules/surface_creation.lua:22-44` |
| Delete the older warp surface after warping | `control.lua:1890-1894` |
| Re-roll guard because `create_surface` returns the existing surface | `control.lua:1781-1790` |
| Planet pick over `game.planets` | `control.lua:2196` (`roll_planet`), `2211`, `modules/planet_roll.lua:13` |
| Cleanup shim for other mods' surface registries | `modules/compat_repair_turret.lua:1-14` |

A copy of this logic also sits in `control.lua:660-738`. Warptorio's own `data.lua:773` comment says there is "no idea how else get map_gen_settings during run time", which is why it reads them from the prototype at runtime.

## Recommended model

Define a fixed pool of N "unstable planet" prototypes at data stage (suggest 3 to 5), each with its own space connections from a hub, short `length` values, a hidden flag, and a `map_gen_settings` default that enables a broad set of autoplace controls. At runtime treat each pool planet as a slot. A slot is idle when it has no surface and is locked. To open a slot, pick a resource profile, build `MapGenSettings` from the prototype defaults plus the profile, give it a new seed and a bounded width and height, call `LuaPlanet.create_surface` (or `create_surface` plus `associate_surface`), request a bounded chunk area, and unlock the location for the force. To close a slot, wait until no platform is parked or landed on it, move any orbiting platform with the `space_location` writer, destroy mod-tracked entities with `raise_destroy`, delete the surface, and lock the location. Keep at most one or two live surfaces, as Warptorio does. If specials do not generate away from their home planet, place those resources by script.

Data-stage prototypes:
- N `planet` prototypes (the pool), each with `distance`, `orientation`, `hidden`, `map_gen_settings`, `surface_properties`, asteroid definitions.
- N `space-connection` prototypes from a hub location to each pool planet, with `length`.
- A technology or script unlock path for the first planet if needed (`LuaForce.unlock_space_location`).

Runtime steps:
1. Pick an idle slot and a resource profile on a timer.
2. Build `MapGenSettings` and call `create_surface`, then request bounded chunks.
3. Unlock the location (`LuaForce.unlock_space_location`).
4. After the visit window, check `LuaPlanet.get_space_platforms` and the Thud landed state.
5. Move or wait for platforms, clean up registered entities, `delete_surface`, lock the location.

## Open questions

1. What happens to a platform whose `space_location` is a planet whose surface was just deleted, and to a platform that is still landed (Thud's state) at that moment?
2. Can `PlanetPrototype.map_gen_settings` on an unmodified pool prototype generate Vulcanus, Fulgora, Gleba and Aquilo resources, or do their autoplace expressions depend on planet noise that a generic prototype lacks?
3. How long do `delete_surface` and `create_surface` take, and how much does a bounded surface add to save size and autosave time?
4. Does a hidden location stay usable by schedule and by `LuaSpacePlatform.space_location` writes?
5. Does Thud need a planet prototype with matching `surface_properties` (gravity, pressure, magnetic field), and does it accept a surface that was created or re-associated at runtime?
6. Does `LuaSurface.map_gen_settings` with `width` and `height` stop generation outside the area, and what do players see at the edge?
7. Do recreated surfaces reuse indices, and which installed mods keep per-surface registries that break the way Repair Turret did?

# Spec: Planet types

## Summary

Each temporary planet has one of five types: Nauvis-like, Vulcanus-like, Fulgora-like, Gleba-like or Aquilo-like. This spec defines the slot pool, how a type gets its resources, tiles, enemies and surface properties, how the next planets are chosen, and what the player sees ahead of time. It reuses the planet states from docs/spec/planet-lifecycle.md. Evidence is in docs/research/05-temporary-planets.md and docs/research/07-planet-loop-tests.md.

## Parent design

#9 (planet types). Related designs: #7 (docs/spec/planet-lifecycle.md), #16 (enemies setting, included here).

## Behaviour

Types and content

1. Nauvis-like has iron, copper, stone, coal, crude oil and water. Uranium is on 50% of Nauvis-like planets. It has biters.
2. Vulcanus-like has tungsten, coal, calcite, lava and sulfuric acid. It has demolishers.
3. Fulgora-like has scrap (the source of holmium) and heavy oil. It has no enemies.
4. Gleba-like has yumako and jellynut, stone and water. It has pentapods.
5. Aquilo-like has lithium brine, fluorine vents, crude oil and an ammonia ocean. It needs heating.
6. Every non-Nauvis type always carries its special resource or feature. Only Nauvis-like varies (uranium).
7. Each planet has a richness of poor, normal or rich. It scales the resource richness controls of the type, not the special features.

Slots and surface properties

8. A planet lives in a slot, a planet prototype defined at data stage. There are 2 slots per type, 10 in total (decided 2026-11-15, see Slot pool).
9. A planet keeps its type's surface properties (gravity, pressure, magnetic field, solar power), so recipes and buildings that read them behave as on the vanilla planet.
10. The vanilla planets (Vulcanus, Fulgora, Gleba, Aquilo) are hidden. The player cannot travel to them. Nauvis stays as the first surface.

Choosing the next planet

11. Only Nauvis-like can appear until the force has visited 4 planets. A visit is the first completed landing on a planet (the moment the lifecycle sets `counting`). After 4 visits Vulcanus-, Fulgora- and Gleba-like can appear. After 12 visits Aquilo-like can appear. The thresholds are defaults.
12. Weights are Nauvis-like 30 and each other type 20. Only unlocked types take part. The roll uses the weights of the unlocked types.
13. Richness weights are poor 30, normal 50, rich 20. Richness factors are 0.5 for poor, 1.0 for normal and 2.0 for rich (decided 2026-11-15, needs a play test).
14. Pity rule. Setting `sky-platforms-pity-n`, default 6, 0 turns it off. If an unlocked type has not appeared among the last N rolled planets, that type is next. If several qualify, pick the one absent longest, then the lowest type order (nauvis, vulcanus, fulgora, gleba, aquilo). The same applies to uranium on Nauvis-like (an uranium-free Nauvis-like run of N Nauvis-like planets forces uranium on the next Nauvis-like planet).
15. Foresight. The next two planets are rolled ahead and stored. The player sees their type, richness and resources before they appear (GUI in Control stage). Skipping a planet that is `open` does not change the queue. The queue shifts as planets appear.
16. When the lifecycle opens a planet, it takes the first queue entry, assigns a free slot of that type, and rolls a new entry at the end.

Enemies

17. Enemies are vanilla per type (statements 1 to 5). The map setting `sky-platforms-enemies` (runtime-global bool, default true) turns them off. It is read when a surface is created. Planets that already exist keep their enemies.
18. With enemies off the mod writes `no_enemies_mode = true` and the enemy autoplace controls to zero into the surface map gen settings (MapGenSettings.no_enemies_mode, runtime-api.json) before chunks generate. Whether this also removes Vulcanus demolishers (territory based) is not found. See Open numbers and the test in slice T8.

## Slot pool

Decided 2026-11-15. Use option (b), slots per type, 2 per type, 10 prototypes.

Reasons

- Planet-level fields cannot change at runtime. `LuaPlanet` has `name`, `prototype`, `surface`, `valid`, `associate_surface`, `create_surface`, `get_space_platforms` and `reset_map_gen_settings` and nothing else (runtime-api.json). Fulgora's `lightning_properties` (planet.lua:320), Aquilo's `entities_require_heating` (planet.lua:680), the `player_effects` (planet.lua:258, 681), `persistent_ambient_sounds` and the sound and cloud data are prototype fields with no runtime writer.
- Surface properties can change per surface. `LuaSurface.get_property` and `set_property` exist (runtime-api.json). So gravity, pressure and magnetic field could be set per visit on a generic slot. That alone does not cover the planet-level fields above, so option (a) would still lose Fulgora lightning and Aquilo heating.
- `map_gen_settings` is readable and writable per surface (`LuaSurface.map_gen_settings`), but the doc says a write "will not retroactively update the surface". It must be written before chunks generate. A slot of a fixed type needs this only for richness and uranium, not for the whole map.
- Thud's data-final-fixes builds descent entries from planet prototypes (07-planet-loop-tests.md, verified facts). A slot per type gives Thud the right surface properties per prototype with no runtime change.
- 2 slots per type is enough because at most 2 planets are live (planet-lifecycle.md, statement 3). Two live planets of one type use both slots of that type.

Cost. 10 prototypes and 10 connections from `sky-drift`. Each prototype copies a vanilla planet's data (planet.lua:18, 119, 287, 612 for vulcanus, gleba, fulgora and aquilo, base planet.lua for nauvis). Prototypes with no surface cost nothing at runtime.

Considered and not chosen. Option (a), a few generic slot prototypes whose type changes per visit. It needs fewer prototypes (2 or 3), but a slot's planet-level fields stay fixed, so Fulgora lightning, Aquilo heating and the planet sounds and effects of one type would show on the others. Rejected.

## Map generation per type

Where vanilla map gen lives

- `data/space-age/prototypes/planet/planet-map-gen.lua`. One function per planet returns the `map_gen_settings`. Vulcanus starts at line 5, Gleba around line 137 (`return` at 137), Fulgora around line 336, Aquilo around line 429 (the `return` lines found by search). Each is assigned in `planet.lua` as `map_gen_settings = planet_map_gen.<name>()` (planet.lua:28, 130, 298, 623).
- Nauvis uses `base/prototypes/planet/planet.lua` (name at line 9). It was not read in detail for this draft. The autoplace control names for iron, copper, stone, coal, uranium, crude oil and water must be taken from that file when implementing.
- Per-planet extra files: `planet-vulcanus-map-gen.lua`, `planet-fulgora-map-gen.lua`, `planet-gleba-map-gen.lua`, `planet-aquilo-map-gen.lua` (noise expressions that the settings reference).

How a slot gets its type

The slot prototype for a type copies the vanilla planet's `map_gen_settings` (and `map_seed_offset`) by calling the same function. No per-visit map gen is needed for the special content, because the slot's prototype already enables the type's autoplace controls (planet-map-gen.lua:37-45 for Vulcanus, 176-182 Gleba, 361-365 Fulgora, 442-446 Aquilo). Autoplace expressions that read planet noise therefore work, as the slot copies the same expressions. This answers open question 2 in docs/research/05-temporary-planets.md for slot-per-type: the specials generate because the slot is a copy. The test for the per-visit edits below is still needed.

Per-visit edits

1. Richness and seed. After `LuaPlanet.create_surface()` and before any chunk request, write `surface.map_gen_settings` with the richness factor on the resource controls (`AutoplaceControl.richness`) and a fresh `seed` from the planet's roll. Whether chunks near the origin exist right after `create_surface` is not found. If they do, delete them with `delete_chunk` and regenerate with `regenerate_entity` (both in runtime-api.json).
2. Uranium on Nauvis-like. Set the uranium control `size` to 0 when the planet has none. Fallback if the control does not respond per surface. Generate with the control off and place a uranium patch with `create_entity` after `on_chunk_generated` (05-temporary-planets.md, section 3).
3. Enemies off. Statement 18.
4. Chunk cost. Create the surface in one tick (3 to 13 ms) and spread chunk requests (radius 4 takes 370 to 480 ms in total) over 8 ticks with `request_to_generate_chunks`.

What cannot move to another planet

These stay on the matching slot type because the data is planet-level or a tile or entity of that planet only.

- Lava and volcanic tiles, geysers and demolisher territories (Vulcanus). Tiles are in `autoplace_settings.tile` of that function (planet-map-gen.lua:50-60). Territories are surface features (LuaSurface.set_chunk_territory and clear_territory_for_chunks exist). Not found whether demolishers need the planet prototype.
- Ammonia ocean tiles (`ammoniacal-ocean`, planet-map-gen.lua, Aquilo list) and `entities_require_heating` (planet.lua:680).
- Gleba plants and wetland tiles (planet-map-gen.lua:176-200) and the pentapod enemy base control `gleba_enemy_base`.
- Fulgora oil ocean tiles, ruins and `lightning_properties` (planet.lua:320).
- Surface properties live on the prototype for each slot (planet.lua:42, 144, 312, 637).
- Sky-platform buildings that need a property value (for example a heat-based recipe) read the slot's properties. They do not need a runtime change under option (b).

## Data stage

- 10 `planet` prototypes `sky-<type>-<n>` with `n` in 1 and 2, `type` in `nauvis`, `vulcanus`, `fulgora`, `gleba`, `aquilo`. Each copies the matching vanilla planet (map gen, surface properties, lightning, heating, sounds, effects) with these changes. `hidden = true`, `distance` and `orientation` TBD, no vanilla `solar-system-edge` links. They must be defined in `data.lua` so Thud's data-final-fixes builds their descent entries.
- 10 `space-connection` prototypes from `sky-drift` to each slot, `length` 20000 for all slot connections (decided 2026-11-15). The reason is the travel-distance decision in docs/spec/planet-lifecycle.md (statement 7).
- Hide the vanilla planets (`hidden = true` in data-final-fixes) so nothing in the starmap shows them (rule for hiding via Thud or other mods is not found, and test with Thud loaded).
- `mod-data` prototype `sky-platforms-types` with the defaults: unlock thresholds, weights, richness weights, pity N, per-type resource lists for foresight, and the richness multipliers.
- Locale for type names, resource lists, and the foresight GUI.
- Technology or script unlock: `LuaForce.unlock_space_location` for the slot at open time (docs/research/05-temporary-planets.md, Recommended model).

## Control stage

Storage

```lua
storage.queue = {}          -- two entries: { type = "nauvis", richness = "normal", uranium = false, seed = 123456 }
storage.visits = {}         -- [force_index] = number of first landings
storage.type_history = {}   -- [force_index] = list of the last N rolled types, newest last
storage.uranium_history = {} -- [force_index] = number of Nauvis-like rolls since the last uranium one
storage.rng = nil           -- LuaRandomGenerator, created with game.create_random_generator(seed)
storage.slot_of_type = {}   -- [type] = { "sky-nauvis-1", "sky-nauvis-2" }
```

Roll

```lua
local function roll(force_index)
  local unlocked = Types.unlocked(storage.visits[force_index] or 0)
  local n = settings.global["sky-platforms-pity-n"].value
  local pick = n > 0 and Types.pity_pick(force_index, unlocked, n) or nil
  pick = pick or Types.weighted_pick(storage.rng, unlocked)
  return Types.build_entry(force_index, pick, storage.rng)
end
```

Order of a roll

1. Fill `storage.queue` to 2 entries (at `on_init` and after every pop).
2. Pop on open. Take entry 1, pick a free slot from `storage.slot_of_type[type]` in ascending name order, write the entry into `storage.planets[slot]` (planet-lifecycle.md), then roll a new entry at the end. The queue is rolled with the counters as they are at that moment, so entry 2 sees entry 1 in `type_history`.
3. Count a visit when the lifecycle sets `counting` (`Types.on_first_landing(force_index)` increments `storage.visits`). A change in the unlock set does not re-roll a queue entry (decided 2026-11-15). Entries already shown in the foresight list are not re-rolled, and new types appear from the next roll on.
4. The pity counters update at roll time, not at open time, so foresight and the guarantee agree.

Foresight GUI

A top-bar button opens a frame that lists the two queue entries with type name, richness, resource icons and a flag for enemies (from `sky-platforms-enemies`). It shows nothing for slots already open (the lifecycle's top-bar element handles those).

## Settings

| Name | Type | Default | Note |
| --- | --- | --- | --- |
| `sky-platforms-pity-n` | runtime-global int | 6 | 0 turns the pity rule off. Range 0 to 50 (TBD). |
| `sky-platforms-enemies` | runtime-global bool | true | Read when a surface is created. Existing planets keep theirs. |
| `sky-platforms-visits-tier-2` | startup int | 4 | Visits before Vulcanus-, Fulgora- and Gleba-like. |
| `sky-platforms-visits-tier-3` | startup int | 12 | Visits before Aquilo-like. |

Weights and richness weights are mod-data defaults, not settings.

## Storage and migrations

None for a first release. Adding a type or a counter later ships a migration `migrations/<version>.lua` that creates the field. Changing the number of slots per type needs a migration that keeps open planets valid (version TBD).

## Multiplayer and determinism

- Every roll uses `storage.rng`, a `LuaRandomGenerator` from `game.create_random_generator(seed)`, so all peers draw the same sequence. `math.random` is never used.
- Rolls happen in the lifecycle's `on_nth_tick` handler, not in per-player events, so a join does not change the order.
- Visits and histories are keyed by `force_index`. v1 is co-op on one force.
- The foresight GUI is read-only. It reads `storage.queue` and writes nothing, so it has no desync risk. Create it for players who join later.
- The surface edit (statements 8 to 18) happens in one tick on every peer.

## Slices

- [ ] T1. Nauvis-like planets with richness and uranium, vanilla planets hidden
- [ ] T2. Foresight of the next two planets
- [ ] T3. Visit gating and Vulcanus-like planets
- [ ] T4. Fulgora-like planets
- [ ] T5. Gleba-like planets
- [ ] T6. Aquilo-like planets
- [ ] T7. Pity rule
- [ ] T8. Enemies setting

### T1. Nauvis-like planets with richness and uranium, vanilla planets hidden

After it ships, the planets that appear are Nauvis-like with poor, normal or rich resources, and about half have uranium. The vanilla planets are hidden.

- [ ] Two `sky-nauvis-<n>` slots exist and Thud lists them as landable.
- [ ] Richness changes patch size and amount by the multiplier, and about 30%, 50%, 20% of planets are poor, normal, rich over 100 rolls.
- [ ] Uranium is on about 50% of planets over 100 rolls and a uranium-free planet has none.
- [ ] Biters exist.
- [ ] The starmap does not list Vulcanus, Fulgora, Gleba or Aquilo.
- [ ] Surface creation stays under 15 ms and each chunk batch under 20 ms.

Path to prod. Target release: 0.4.0. Migration no. Test steps. New game, check planets on three rolls in the console, compare resources, open the starmap. Changelog "Planets have a richness and sometimes uranium. Vanilla planets are hidden."

### T2. Foresight of the next two planets

After it ships, a player can open a window that shows the next two planets with type, richness and resources.

- [ ] The queue has 2 entries after load.
- [ ] The next planet that appears equals queue entry 1 from before it appeared.
- [ ] The window shows the enemy flag and matches `sky-platforms-enemies`.
- [ ] Reload keeps the queue and the seeds.

Path to prod. Target release: 0.6.0. Migration yes (creates the queue on load). Changelog "Added a window that previews the next two planets."

### T3. Visit gating and Vulcanus-like planets

After it ships, the player finds Nauvis-like planets for 4 visits, then Vulcanus-, Fulgora- and Gleba-like roll become possible. This slice delivers Vulcanus-like only, the other two stay locked until their slices.

- [ ] No non-Nauvis type appears before 4 visits.
- [ ] A Vulcanus-like planet has tungsten, coal, calcite, lava, sulfuric acid geysers and demolishers.
- [ ] Vulcanus surface properties match vanilla (gravity 40, pressure 4000, planet.lua:47-48).
- [ ] Weights are 30 and 20 over 200 rolls within tolerance.

Path to prod. Target release: 0.7.0. Migration no. Changelog "Added Vulcanus-like planets."

### T4. Fulgora-like planets

- [ ] Scrap, oil ocean tiles, ruins and lightning exist, with no enemies.
- [ ] Lightning rate matches vanilla (planet.lua:322).
- [ ] Surface properties match vanilla (pressure 800, gravity 8).
- [ ] Heavy oil is available (source to confirm in the map gen, TBD).

Path to prod. Target release: 0.7.0. Migration no. Changelog "Added Fulgora-like planets."

### T5. Gleba-like planets

- [ ] Yumako and jellynut soil, wetland tiles, stone and water exist, with pentapods.
- [ ] Gleba plants grow and spoilage works as on Gleba.
- [ ] Surface properties match vanilla (pressure 2000, gravity 20).

Path to prod. Target release: 0.7.0. Migration no. Changelog "Added Gleba-like planets."

### T6. Aquilo-like planets

- [ ] Lithium brine, fluorine vents, crude oil and ammonia ocean exist.
- [ ] Entities require heating (`entities_require_heating`).
- [ ] No Aquilo-like planet before 12 visits.
- [ ] Surface properties match vanilla (pressure 300, gravity 15).

Path to prod. Target release: 0.8.0. Migration no. Changelog "Added Aquilo-like planets."

### T7. Pity rule

- [ ] With N = 6, no unlocked type is absent from 7 consecutive rolls over 1000 simulated rolls.
- [ ] Uranium appears at least once in every 7 Nauvis-like rolls.
- [ ] N = 0 turns it off.
- [ ] Foresight shows the guaranteed type.

Path to prod. Target release: 0.8.0. Migration yes (creates history tables). Changelog "Added a pity rule for planet types."

### T8. Enemies setting

- [ ] With the setting off, new Nauvis-, Vulcanus- and Gleba-like planets have no biters, demolishers or pentapods.
- [ ] Planets that already exist keep their enemies.
- [ ] If demolishers still spawn, delete segmented units after chunk generation (decided fallback, see the Decided list). This needs a test.

Path to prod. Target release: 0.8.0. Migration no. Changelog "Added a setting to turn enemies off."

## Path to prod

Release plan (2026-11-15, planets first): 0.1.0 start in the Drift, spawn and respawn. 0.2.0 copper and stone crushing. 0.3.0 salvage thrusters. 0.4.0 L1, L2, L3, T1 (first planet loop). 0.5.0 L4, L6, L11 (warnings, automatic take-off, late landings). 0.6.0 L5, T2 (half-life, foresight). 0.7.0 T3, T4, T5 (gating, Vulcanus-, Fulgora-, Gleba-like). 0.8.0 T6, T7, T8 (Aquilo-like, pity, enemies). 0.9.0 L7, L8, L9, L10 (easy mode, skip scanner, circuit signals, timer hook). 0.10.0 corpse into the hub. 0.11.0 respawn picker.
Save migration: yes for T2 and T7, no for others.

Every release passes three checks. First, `emmylua_check` with the Factorio type library. Second, a headless `factorio --create` load with the mod and Thud. Third, the in-game self-test.

In-game test steps:
1. New game. Open the foresight window.
2. Open and land on three planets. Compare the type and richness to the preview.
3. After 4 visits, check other types roll. After 12, Aquilo-like.
4. Set pity N to 2 and watch a forced type.
5. Turn enemies off and open a new planet.

Changelog section (mod portal): see each slice.

## Decided 2026-11-15

1. Slot layout. 2 slots per type, 10 planet prototypes `sky-<type>-<n>`, all in `data.lua`. `LuaPlanet` has no writable attributes, and Fulgora's `lightning_properties` and Aquilo's `entities_require_heating` are prototype-only.
2. Richness weights poor 30, normal 50, rich 20. Richness factors 0.5, 1.0 and 2.0. Needs a play test.
3. Connection length 20000 for all slot connections. Players must design a reasonably fast platform, which steers them toward small lander ships (planet-lifecycle.md, statement 7).
4. Generation. Generate chunks with radius 4 around the landing area, spread over 8 ticks.
5. Foresight. Entries already shown in the foresight list are not re-rolled when a type unlocks.
6. Demolisher fallback. If `no_enemies_mode` does not remove demolishers, delete segmented units after chunk generation. This needs a test.

## Open numbers

1. Visit thresholds. TBD (proposed: 4 and 12). The design default. They are startup settings, so they can change per game.
2. Weights. TBD (proposed: Nauvis-like 30, others 20). The design default. Nauvis-like is the most common as it is the safe type.
3. Pity N. TBD (proposed: 6, 0 is off). The design default. Six keeps the rare types visible without making them certain.
4. Uranium share. TBD (proposed: 50% with a pity at N). The design default.
5. Slot `distance` and `orientation`. TBD.
6. Whether `no_enemies_mode` removes Vulcanus demolishers (territory based). Not found. Needs the test in slice T8. Decided item 6 is the fallback.

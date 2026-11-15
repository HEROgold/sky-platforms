# Planet loop tests (Factorio 2.1.24, Thud 2.2.0)

## Summary

1. `planet.create_surface()` works at runtime on a custom planet prototype. It took 3 to 13 ms for a fresh surface. Calling it when the surface exists returns the existing surface and does not error.
2. Generating a 4 chunk radius took 370 to 480 ms (about 230,000 tiles ended up generated).
3. `thud.emergency_land(platform, {0, 0}, {confirmed = true, forced = true})` lands from script in 1200 ticks. Thud then destroys the platform object, and a `thud-landed-hub` entity is the only owner left.
4. A bare starter-pack platform burns up on re-entry unless the hub is protected (run A). With `hub.destructible = false` it lands.
5. `take_off(landed_hub, {})` works after `set_charge(landed_hub, 1e13)`. It takes 1500 ticks and creates a new platform object.
6. Deleting the planet surface while a platform orbits does nothing to the platform. Thud accepts the recreated surface (second landing worked).
7. Deleting the surface while landed destroys the landed hub and everything on it. No platform exists to lose, and nothing logged an error.
8. Saves: base 931,590 bytes, with generated surface 1,110,305, landed 1,212,117, deleted and recreated 1,105,352.

## Setup

Everything lives in `%TEMP%\skyp-loop\`. Test mod: `mods\skyp-test_0.0.1` (data.lua adds planet `sky-test-slot` and connection `sky-test-conn`; control.lua runs a 19 step sequence on a step table). `mods\mod-list.json` enables base, space-age, quality, elevated-rails, recycler, Thud and skyp-test. `config.ini`:

```
[path]
read-data=C:\Program Files (x86)\Steam\steamapps\common\Factorio\data
write-data=%TEMP%\skyp-loop\data
```

Commands (PowerShell, `$r = "$env:TEMP\skyp-loop"`, `$f` is factorio.exe). Pass an absolute save path to `--create`, or the save lands in the working directory.

```
& $f --config "$r\config.ini" --mod-directory "$r\mods" --create "$r\work\skyp-main.zip"
# no saves are written in benchmark mode, so use a server run for the sequence
& $f --config "$r\config.ini" --mod-directory "$r\mods" --start-server "$r\work\skyp-main.zip" --server-settings "$r\server-settings.json" --until-tick 9000 --port 34299
```

`server-settings.json` sets `auto_pause` false and a private game. The mod sets `game.speed = 20`. The sequence finishes at tick 5240 and logs `SEQUENCE COMPLETE`. `--benchmark ... --benchmark-ticks 9000` also runs the sequence, but `game.auto_save` writes nothing there. Server mode did not exit at `--until-tick`, so the run was stopped by timeout. Logs: `data\factorio-current.log`; copies in `work\runA.log` (bare hub) and `work\runB.log` (hub made indestructible, the main run). Saves: `data\saves\_autosave-skyp-loop-*.zip`.

## 1. create_surface at runtime and chunk generation cost

Works. Profiler lines (run B):

```
t=60   planet.surface before create: true
t=60   create_surface Duration: 0.022900ms      (surface already existed)
t=60   create_surface again while existing ok: {"sky-test-slot"}
t=60   chunkgen_r4 Duration: 390.128000ms
t=3300 planet.surface before create: nil        (after delete_surface)
t=3300 create_surface Duration: 3.435700ms
t=3300 chunkgen_r4 Duration: 376.144500ms
t=4980 create_surface Duration: 6.018600ms
t=4980 chunkgen_r4 Duration: 370.977800ms
```

Run A showed 12.97 ms and 479 to 483 ms. The surface already existed at tick 30, before my own call: setting `platform.space_location = "sky-test-slot"` (or the planet becoming an orbit target) creates it. Thud also creates it itself in `Lift.landing_surface` (`planet.surface or planet.create_surface()`). A second `create_surface()` returns the existing surface without error. `request_to_generate_chunks({0,0}, 4)` followed by `force_generate_chunk_requests()` left 239,616 tiles counted on the surface (about 234 chunks), more than a 9 by 9 area, so treat the 4 as a generous radius.

## 2. Thud landing from script

Call that worked: `remote.call("thud", "emergency_land", P, {0, 0}, {confirmed = true, forced = true})` returned `true`. No charge and no stored site were needed, so `soft_land` was never tried.

```
t=120  hub health before landing: 5000/5000 floor tiles=159744
t=120  emergency_land ok=true res={true}
t=1350 STEP 6 (landing step finished by t=1320)
t=1350 surface sky-test-slot index=3 landed hubs=1
t=1350 landed hub at {x = 0, y = 0} unit=282
```

Landing lasts 1200 ticks (started 120, polling saw the platform gone at 1320; the same gap, 3330 to 4530, on the second landing). While landing, `is_landing(P)` returned true. After impact the surface held `thud-landed-hub` (1), `thud-site-watcher-3` (1), 81 `thud-landed-foundation` tiles and 81 `thud-ground-pole` entities near 0,0, plus explosion and smoke entities. The platform object is gone: Thud's `lift.lua` calls `platform.destroy(1)` at the end of landing, so `P.valid` is false and `P.space_location` and `P.surface` raise "LuaSpacePlatform API call when LuaSpacePlatform was invalid". The brief expected the hub on the platform to stay. It does not, because the whole platform is replaced by the landed hub on the planet surface.

Run A, bare starter pack with no protection: the platform was lost before impact. At t=618 `hub.valid=nil`, at t=619 `P.valid=false`, and the planet surface had no landed hub, no foundation tiles, only a `thud-site-watcher-3`. Cause: `descent.lua` burns the first destructible entity in each column of the bow for 65 fire damage per second at full heat, and the hub is the first thing in its column. Thud reports it as `thud.land-lost` and runs `crash`. A real platform needs something in front of the hub, or an indestructible hub (`hub.destructible = false` was used in run B). The 5000 health hub did not survive without it.

## 3. Take-off from script

Needs the landed hub entity (the "owner") and a full charge.

```
t=1380 get_charge landed ok: {0, 162000000}     (bank 0, need 162 MJ = 81 floor tiles x 2 MJ)
t=1380 set_charge landed ok: {}                  (set_charge(h, 1e13) clamps to the need)
t=1380 get_charge landed after ok: {162000000, 162000000}
t=1380 take_off ok: {true}
t=1680 platform() rebinding to platform index=2 name=skyp-P
t=2878 poll_takeoff climbing=true  loc=nil
t=2880 poll_takeoff climbing=false loc=sky-test-slot hub.valid=true surface.valid=true
```

Call: `remote.call("thud", "take_off", landed_hub, {})`. `set_charge` clamps to the need, so any large number works. Take-off lasts 1500 ticks (1380 to 2880). The result is a new `LuaSpacePlatform` (index 2, same name `skyp-P`, new surface), appearing about 300 ticks after the call, orbiting `sky-test-slot`. The old platform object stays invalid, so a mod must re-find the platform by name or index after take-off. The landed hub and the planet floor tiles were consumed (`landed_hubs=0` after).

## 4. Deleting the surface while a platform orbits

Nothing happens to the platform.

```
t=2940 delete_surface ok: {true}
t=2940 immediately after delete  P.valid=true loc=sky-test-slot hub.valid=true surface.valid=true planet.surface.valid=true
t=2941 observe +1   P.valid=true loc=sky-test-slot hub.valid=true planet.surface.valid=nil
t=3240 observe +300 P.valid=true loc=sky-test-slot hub.valid=true planet.surface.valid=nil
t=3270 get_landing_site ok: {{x = 0, y = 0}}
```

The deletion takes effect on the next tick (`planet.surface` is still valid in the same tick). The platform stays valid at `space_location = sky-test-slot` with no surface. Thud keeps its stored landing site. No errors.

## 5. Recreated surface

Thud accepts it. After `create_surface()` at t=3300 (`planet.surface before create: nil`), `emergency_land` at t=3330 returned `true`, the landing finished at 4530 (1200 ticks), and a new landed hub stood at {0, 0} (`unit=538`) with 81 foundation tiles. The surface index differs per creation (3 in each landing in run B), so never cache the index.

## 6. Deleting the surface while landed

```
t=4620 delete_surface ok: {true}
t=4620 immediately after delete  P.valid=false planet.surface.valid=true landed_hubs=1
t=4621 observe +1   planet.surface.valid=nil landed_hubs=0
t=4920 observe +300 P.valid=false planet.surface.valid=nil landed_hubs=0
t=4950 is_taking_off P ok: {false}
t=4950 landed_hub valid ok: {false}
t=4950 surfaces ok: {{"nauvis"}}
t=4950 platforms ok: {{}}
```

The platform was already gone since landing (section 2), so there is nothing to lose there. The landed hub and everything on the surface are destroyed with the surface, and `game.forces.player.platforms` is empty. No Thud error appeared and no warnings were logged. The player loses the whole base: the platform cannot be recovered. Recreating the surface afterwards (t=4980, 6.0 ms) gave an empty planet.

## 7. Save sizes

| Save | When | Bytes |
| --- | --- | --- |
| `skyp-loop-base` | tick 0, platform in orbit, planet surface present but ungenerated | 931,590 |
| `skyp-loop-a` | after step 2, 4 chunk radius generated | 1,110,305 |
| `skyp-loop-b` | after second landing (recreated surface, landed hub, 81 foundation tiles) | 1,212,117 |
| `skyp-loop-c` | after deleting the landed surface, recreating it and generating chunks (no platform) | 1,105,352 |

The baseline was not free of a planet surface: it already had the engine created one (see section 1). The generated surface adds about 179 KB over the baseline. A landed platform adds about 100 KB. Chunk generation of the same 4 chunk radius costs about 175 KB, which matches c against a. All saves are zip compressed.

## 8. Other observations

- No warnings or engine errors in `factorio-current.log` for either run. The errors in the log are my own `pcall` captures from calling Thud with an invalid platform.
- `thud.get_landing_site(P)` and the other platform calls raise "Expected a valid LuaSpacePlatform" when given an invalid platform, so guard with `.valid` before every call.
- Thud's `is_landing` and `is_taking_off` return false for invalid objects, so a finished landing is detected by `is_landing(P)` becoming false or `P.valid` becoming false.
- The starter pack platform's hub has 5000 health and the platform surface had 159,744 tiles counted (`count_tiles_filtered({})` includes empty space tiles).
- The benchmark runs finished 9000 ticks in about 5 s and the landing sequence ran correctly there too, but benchmark mode writes no saves.

## Implications for the planet loop spec

- Plan on a platform object being destroyed at landing and a new one created at take-off. Track platforms by name or saved landing site data, not by a stored `LuaSpacePlatform` reference.
- The landing hull needs protection from re-entry heat in front of the hub, or the platform dies on descent (run A). Test with the real hull shape before relying on the hub alone.
- Landing takes 1200 ticks and take-off 1500 ticks; plan the loop timing around those figures plus about 300 ticks before the new platform exists.
- Take-off needs `set_charge(landed_hub, big)` first, and the cost is 2 MJ per floor tile (162 MJ here).
- Deleting a planet surface is safe while platforms orbit, and Thud copes with a recreated surface of the same planet. Deleting it while landed destroys the base. The loop must never delete a surface that holds a `thud-landed-hub`; check `find_entities_filtered{name = "thud-landed-hub"}` and any player or force owned entity first.
- Creating the surface costs 3 to 13 ms, and chunk generation about 400 ms for the radius used, so spread work across ticks or generate chunks only where the landing happens.
- A temporary planet costs about 180 KB per generated 4 chunk radius, so deleting unused surfaces keeps saves small.

# Thud 2.2.0 remote API for Sky Platforms

Source: Thud 2.2.0 (MIT, Factorio 2.1), read from the extracted copy. All paths below are relative to the source root `Thud_2.2.0\`. Nothing was run and no web source was used.

## Summary

- Thud exposes 11 remote functions on the interface `thud` (script/interface.lua:184). Landing and take-off run on timers, about 20 s and 25 s with default settings.
- Thud raises no custom events. It raises only vanilla `script_raised_built` and `script_raised_destroy` on the landed hub.
- An emergency landing works from script with no charge (SUPPORTED). A soft landing and a take-off need a full charge bank.
- Take-off starts only from a landed hub entity, and it creates a new LuaSpacePlatform, so a stored platform reference is lost.
- Thud has no hook to block a landing or take-off, and no event for their start, finish or failure. Those are the main gaps.

## Remote functions

All are on `remote.call("thud", name, ...)`, defined in script/interface.lua:87-182.

| Name | Parameters | Returns | Purpose | Source |
| --- | --- | --- | --- | --- |
| emergency_land | platform, position {x, y}, options {confirmed, forced} | true, or false and a list of localised lines | Lands the platform's (0, 0) at position on the planet below. No charge. | interface.lua:92-102 |
| soft_land | platform, position (optional), options {silent} | true, or false and lines | Soft landing at position or the stored site. Needs a full bank. | interface.lua:106-108; gui.lua:278-295 |
| set_landing_site | platform, position {x, y} | true, or false and lines. Returns true with lines when the force's buildings stand on the site. | Stores the soft landing site for the planet below. | interface.lua:113-123 |
| get_landing_site | platform, planet_name (optional) | {x, y} or nil | Reads the stored soft site for a planet. Defaults to the planet below. | interface.lua:126-131 |
| take_off | landed_hub (LuaEntity), options {silent} | true, or false and lines | Starts the countdown and lift-off of a landed platform. Needs a full bank. | interface.lua:136-138 |
| get_charge | owner (LuaSpacePlatform or landed hub) | bank (J), need (J) | Banked and needed joules. | interface.lua:142-145 |
| set_charge | owner, joules | nothing | Sets the bank, capped at need. | interface.lua:148-153 |
| get_circuit_condition | owner, "land" or "take_off" | setting table or nil | Reads a circuit condition as the damper panel shows it. | interface.lua:157-160 |
| set_circuit_condition | owner, "land" or "take_off", setting | nothing | Writes a circuit condition. | interface.lua:163-167 |
| is_landing | platform | boolean | True while the platform is on its way down. | interface.lua:170-173 |
| is_taking_off | owner (LuaSpacePlatform or landed hub) | boolean | True while a landed hub counts down, or a platform climbs. | interface.lua:177-181 |

Position values pass through `origin_at` (interface.lua:15-20). The value is rounded to an even tile grid, and an absolute coordinate above 1000000 is an error (interface.lua:11, 18).

## Events

Thud raises no custom events. A search of the whole source found no `script.raise_event` and no `script.generate_event_name`. The only remote call is `remote.add_interface` at interface.lua:184.

Vanilla events Thud raises:

- `script_raised_built` for the landed hub, when a landing creates it. Source: lift.lua:962-969 (`raise_built = true`).
- `script_raised_destroy` for the landed hub, when a take-off removes it. Source: lift.lua:1446 (`destroy{raise_destroy = true}`).

Thud consumes `on_space_platform_changed_state` (impact.lua:661-664). Arrival in orbit sets `platform.space_location` (rise.lua:348). The code does not confirm whether that engine event fires on arrival.

## Mod-data tables

| Name | Set by | Shape | Source |
| --- | --- | --- | --- |
| thud-descents | data-final-fixes (data-final-fixes.lua:4) | per planet: {name, calm, rise, orbit, entry {name, from, to, split}, ticks, from, to, weather, look} | data/descent/descent.lua:94-229 |
| thud-descent-seconds | data/descent/seconds.lua | {default = 20}, per planet seconds. Another mod sets its own planet in data.lua or data-updates.lua. | data/descent/seconds.lua:4-15 |
| thud-jump-efficiency | data/damper/efficiency.lua | by technology name: 0.2, 0.35, 0.5 for levels 1 to 3 | data/damper/efficiency.lua:4, 49-55 |
| thud-landing-replacements | data/replacements/replacements.lua | empty. Another mod fills from-name to to-name pairs in data.lua or data-updates.lua. Each pair is checked in data-final-fixes. | data/replacements/replacements.lua:4-12; data/replacements/check.lua:28-49 |
| thud-surface-conditions | data/conditions/strip.lua | per entity name: conditions Thud removed, kept for the tooltip and script/lift.lua | data/conditions/strip.lua:126-133 |
| thud-twins | data/twins/pairs.lua | folded: thruster and asteroid-collector to their folded forms. dormant: filled by data/twins/dormant.lua for roboports. | data/twins/pairs.lua:6-22; data/twins/dormant.lua:7-97 |

## Needs

### 1. Start a landing from script

Verdict: SUPPORTED.

- Use `emergency_land(platform, position, options)` (interface.lua:92-102). It runs with no player and no GUI. It refuses if the platform is falling, climbing, or not over a planet (gui.lua:34-44, via interface.lua:95-96).
- It is a hard landing. `clear_site` kills what stands on the footprint except ore, items and corpses (lift.lua:748-785). Options: `confirmed` accepts the warning about what is left behind (lift.lua:916-921). `forced` allows tiles that stay on wet ground (lift.lua:897-899).
- Use `soft_land(platform, position, options)` for a soft landing (interface.lua:106-108). It needs a full bank (gui.lua:184-189, 285-286) and it refuses a site with the force's buildings on it (lift.lua:914).

### 2. Choose or read the landing site

Verdict: SUPPORTED.

- Store a site with `set_landing_site(platform, position)` (interface.lua:113-123). It refuses while the platform is on its way, while the site comes from the X and Y signals, or when the site is on wet ground (interface.lua:110-112; gui.lua:173-178, 244-263).
- Read it with `get_landing_site(platform, planet_name)` (interface.lua:126-131). It returns `{x, y}` or nil. Thud gives no default site suggestion. Search for one found nothing.
- Emergency landings take a position directly and store nothing (interface.lua:97).

### 3. Start a take-off from script

Verdict: PARTIAL.

- Normal take-off: `take_off(landed_hub, options)` (interface.lua:136-138). Pass the landed hub entity, not the platform. Thud makes a new platform at lift-off (lift.lua:1338).
- The bank must cover the need. `Rise.start` takes the need at the press (rise.lua:121-125). `Lift.ascend` refuses a short bank (lift.lua:1310-1311).
- Forced or emergency take-off: not found. `take_off` always passes `confirmed = true` (interface.lua:137). That only skips the warning about cargo left behind (lift.lua:1330-1331). It does not skip the charge.
- A take-off is refused when the landed hub has no floor (lift.lua:1308), has two hubs (lift.lua:1315), has too much cargo for the hub (lift.lua:1317-1328), or its planet has no descent entry (lift.lua:1303).

### 4. Read the platform state

Verdict: PARTIAL.

- Descending: `is_landing(platform)` (interface.lua:170-173). Backed by `Impact.falling` (impact.lua:80-82). True until the fall ends (impact.lua:359, 447).
- Lifting: `is_taking_off(owner)` (interface.lua:177-181). For a landed hub it is true during the countdown (rise.lua:52-54). For a platform it is true while it climbs (rise.lua:69-75).
- Landed: not found as a remote function. After a landing the platform is deleted (lift.lua:1003). The landed hub is an entity named `thud-landed-hub` (script/names.lua:17). Thud has no call that finds it from the platform.
- In orbit: not found as a remote function. The script can infer it from `platform.space_location` and the two `is_*` calls. Thud's own check is `button_state` (gui.lua:34-44), which is not exposed.
- Surface when landed: not returned by any remote call. It is `landed_hub.surface`, which the script must already hold.

### 5. Get notified of landing and take-off events

Verdict: MISSING.

- No custom event exists (see Events).
- No callback exists. Thud reports a failure only as flying text to the player who clicked (impact.lua:324-336; rise.lua:103-112).
- Points where the events would fire: landing start (impact.lua:237), landing complete (impact.lua:440-447), landing fail (impact.lua:354-368), take-off start (rise.lua:116), take-off lift-off (rise.lua:297-341), take-off complete (rise.lua:343-351), take-off abort (rise.lua:290-295).
- The landed hub's `script_raised_built` (lift.lua:968) is a usable proxy for landing completion. It fires before the rest of the landing (lift.lua:971-1000), so it is not a clean completion signal.

### 6. Block or allow landing by our own rule

Verdict: MISSING.

- The script can refuse its own calls. That covers `emergency_land`, `soft_land` and `take_off` (interface.lua:92, 106, 136).
- Thud gives no hook before a landing or take-off, so the script cannot stop the player's Emergency landing button (gui.lua:34-44), the circuit conditions (interface.lua:157-167; circuit.lua), or the Take off button.
- Thud does not check the planet's owner or name. Only the planet's existence and descent are checked (lift.lua:38-44, 1303).
- The landing surface is created if the planet has none (lift.lua:46-54). A rule about "planets we created" would need to inspect the surface first.

### 7. Take-off time, charge and power

Verdict: PARTIAL.

- Time: a countdown of 300 ticks (rise.lua:22), then a climb of `descent.ticks` (rise.lua:333, 390-403). With the default `seconds` of 20 (data/descent/seconds.lua:12), `ticks` is 1200 (data/descent/descent.lua:221). The total is 1500 ticks, or 25 s.
- Landing time: impact comes `max(525, descent.ticks)` ticks after the click (impact.lua:21, 250). With the default, that is 1200 ticks, or 20 s. The alarm sounds 525 ticks before impact (impact.lua:266, 318).
- Charge needed: `2000000 * (1 - saving)` joules per tile of floor (records.lua:245, 267-274). The saving is 0.2, 0.35 or 0.5 for the highest jump-efficiency technology researched (records.lua:248-257; data/damper/efficiency.lua:4).
- Charge rate: dampers bank their intake every 60 ticks (damper.lua:365-367). Each core's headroom is its input flow limit times 60 (damper.lua:121-129). Nothing banks while the platform falls or rises (damper.lua:272-275). The per-record rate is stored as `record.rate` (damper.lua:277) but no remote call returns it.
- Power: a core must be on an electric network (damper.lua:142-143). Thud shows "no spare power" on the core, but no remote call reports it.
- Remaining time: no call returns the countdown or climb progress.

### 8. What happens when the surface is deleted or take-off fails

Verdict: PARTIAL. Thud defines the behaviour, but it sends no event, and one path loses charge.

- Landing in progress, ground surface deleted: `impact.lua:596-598` stops the fall. The platform goes back into orbit (`Descent.abort`, impact.lua:362; descent.lua:265-269), unpauses (impact.lua:363), and refunds a soft landing's charge (impact.lua:364). The player sees flying text (impact.lua:597).
- Landing in progress, platform deleted: `impact.lua:586-589` marks the fall lost. At impact it becomes a crash of wreckage with nothing built (impact.lua:470-494).
- Landing refused at impact time: `land` runs `Lift.descend` with `confirmed = true` (impact.lua:440-442). Any hard refusal calls `stop`, which puts the platform back in orbit and refunds a soft landing's charge (impact.lua:354-368).
- Landed hub destroyed (for example its surface deleted): the landed record is dropped (records.lua:292-296). A take-off countdown then aborts (rise.lua:361-362, 299-300).
- Bug: that abort does not refund the charge. `record_of` returns nil once the hub is invalid (rise.lua:96-101), and `abort` refunds only when a record exists (rise.lua:290-292). The charge taken at the press (rise.lua:124) is lost.
- Take-off fails before lift-off: the dry run and the platform creation are checked first (lift.lua:1299-1339). A failure refunds the bank (rise.lua:290-292) and leaves the landed hub in place.

### 9. Size and entity limits

Verdict: PARTIAL. There is no size cap. Several rules refuse a landing or take-off, and none can be checked in advance from script.

- Size: no maximum footprint size found. `footprint.lua` has no limit. Size affects the charge (records.lua:272-274) and the watcher radius (rise.lua:152; impact.lua:304), not whether a landing is allowed.
- Map edge: the site must be within 1000000 tiles of the origin (interface.lua:11, 18).
- Hub: a platform with no hub cannot land (lift.lua:817-820). A take-off needs one hub (lift.lua:1315).
- Floor: a landing needs at least one floor tile (lift.lua:832). A take-off needs landed foundation under the hub (lift.lua:1308).
- Wet ground: a soft landing refuses tiles on wet ground (lift.lua:863-896, 914). An emergency landing refuses them unless `forced` (lift.lua:897-899). The hub's own footprint on wet ground always refuses (lift.lua:899).
- Force buildings on the site: a soft landing refuses (lift.lua:914). An emergency landing needs `confirmed` (lift.lua:916-921).
- Cargo: a take-off refuses if the cargo does not fit the hub and its bays (lift.lua:1317-1328).
- Machines that cannot work on the planet are wrecked by an emergency landing (lift.lua:989-1000). A soft landing folds space-only machines instead (lift.lua:789; lift.lua:1014-1026).
- A dry-run check exists inside Thud (`Lift.descend` with `dry_run`, lift.lua:815, 925), but no remote call exposes it.

### 10. Does Thud need a specific prototype type

Verdict: PARTIAL. Thud needs a planet prototype (`data.raw.planet`). It does not work on any space location a platform orbits.

- Landing: `planet_below` returns `game.planets[name]` (lift.lua:38-44). A space location that is not a planet returns nil, which refuses the landing (lift.lua:823; gui.lua:39-41).
- Planets get descent entries from `data.raw.planet` in data-final-fixes (data/descent/descent.lua:94; data-final-fixes.lua:4). A planet added after that point has none.
- Landing without a descent entry still works, but without a trip. `impact.lua:243` leaves `descent` nil, and the platform is paused and dropped (impact.lua:308-313). `Lift.descend` does not check the descent (lift.lua:815-826).
- Take-off needs a descent entry (lift.lua:1303). A planet without one refuses take-off with the key `thud.land-not-over-planet`, which is misleading.
- Space locations that are Thud's own (descent, calm, rise, orbit, entry) count as "under" the planet (descent.lua:83-93; lift.lua:40). A platform on a Thud connection can land.
- Landing surface: `planet.surface`, or `planet.create_surface()` if there is none (lift.lua:46-54).

## Requests for the author

1. Need 3. Add a take-off option that skips the bank check, for an emergency take-off. Today `take_off` always needs the full need (interface.lua:136-138; rise.lua:124).
2. Need 3. Accept the platform, not only the landed hub, or add a call that returns the landed hub for a platform. The caller can then take off without knowing the hub's unit number.
3. Need 4. Add `get_state(owner)` returning one of orbit, landing, landed, taking_off or climbing, and the landed hub's surface. The data is already in `Rise` and `Impact` (rise.lua:52-75; impact.lua:80-82).
4. Need 5. Raise custom events from `script/impact.lua` and `script/rise.lua` with `script.generate_event_name`. Suggested names: landing started, landing completed, landing failed, take-off started, take-off completed, take-off failed. Payload: platform or landed-hub unit number, planet name, surface, and a reason key on failure. Points are listed under Need 5.
5. Need 6. Add a cancellable pre-landing and pre-take-off hook, for example an event with a cancel flag, or a remote call that registers a check. Thud's own button and circuit paths should go through it too (gui.lua:34-44; interface.lua:92, 136).
6. Need 7. Expose the countdown start tick, the climb length, and `record.rate` (damper.lua:277) in one call, so a timer can compute the time left.
7. Need 8. Refund the charge when a take-off aborts after the landed hub is gone. Keep the charge with the rise, not only with the record (rise.lua:96-101, 290-292).
8. Need 9. Expose the dry run from `Lift.descend` and `Lift.ascend` as a remote call that returns the refusal lines, so a script can check a site first (lift.lua:815, 1294).
9. Need 10. Let a planet be registered after data-final-fixes, for example through a mod-data table, or document that planets added later get no descent entry (data-final-fixes.lua:4; data/descent/descent.lua:94).

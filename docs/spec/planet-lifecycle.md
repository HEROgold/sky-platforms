# Spec: Planet lifecycle

## Summary

Planets in Sky Platforms are temporary. A planet appears, the player lands on it, a countdown runs, and the planet collapses. Platforms that are still landed at the end are lost unless they took off. This spec defines the planet states, the countdown, the staged warnings, the circuit signals, automatic take-off, collapse, the skip scanner, and a platform registry. The registry exists because Thud destroys the platform object at landing and creates a new one at take-off (docs/research/07-planet-loop-tests.md, sections 2 and 3). This spec does not decide which type a planet has or what it generates. That is docs/spec/planet-types.md.

## Parent design

#7 (planet lifecycle). Related designs: #9 (planet types, docs/spec/planet-types.md), #10 (timer research, a hook only here), #16 (enemies setting, in planet-types.md).

## Behaviour

Planet states

1. A slot is `free`, `open`, `counting` or `collapsing`. `open` means a planet exists and no platform has landed yet. `counting` means the countdown runs.
2. A new planet appears in a free slot as `open`. It has no countdown. It stays `open` until a platform lands on it or the player skips it.
3. At most 2 planets are live at once. Live means `open`, `counting` or `collapsing`.
4. Any number of platforms may orbit and land on the same planet.
5. A planet appears at game start (the first one), when a skip frees a slot, at half-life of a counting planet if a slot is free, and at once when a collapse leaves zero live planets (decided 2026-11-15). A collapse that leaves another live planet does not add one by itself.

Countdown

6. The countdown starts when the landed hub exists (decided 2026-11-15). That moment moves an `open` planet to `counting`. The mod computes the total length once, at that moment, from the setting and the modifiers (statement 20). A later change to the setting does not change a running countdown.
7. The timer is visible to every player from the tick the countdown starts. A top-bar element shows the planet name, type and the time left.
8. The mod plays staged warnings at 50% of the total, then at 2 min, 60 s, 45 s and 26 s left (26 s is 1560 ticks). The 45 s warning reads "automatic take-off at 45 s". The 26 s warning reads "too late: platforms without charge will be lost". These are mod defaults. The stages and their order are data in a mod-data prototype (see Data stage). A stage that is later than the total length is skipped.
9. At 50% (half-life) the mod asks the planet-types queue for the next planet, if a slot is free and fewer than 2 planets are live. A planet that is not `counting` has no half-life.
10. Each counting planet writes the time left to circuit signals (statement 23).

Auto take-off and loss

11. At `AUTO_TAKEOFF_TICKS` before zero, the mod starts take-off for every landed platform whose damper charge is full. Charge is full when `bank >= need` from `remote.call("thud", "get_charge", landed_hub)` (docs/research/04-thud-api.md:24). It calls `remote.call("thud", "take_off", landed_hub, {})` (interface.lua:136-138, per 04-thud-api.md:23).
12. Take-off takes 1500 ticks, and the new platform appears about 300 ticks after the call (07-planet-loop-tests.md, section 3). So take-off must start at least 1500 ticks before the surface is deleted. The default start is 2700 ticks (45 s) before zero. That leaves 1200 ticks of margin.
13. The 26 s warning (1560 ticks) is the last moment a player can start a manual take-off and still finish, because a take-off takes 1500 ticks. It is a warning only. The mod does not auto-start take-off at 26 s.
14. Between `AUTO_TAKEOFF_TICKS` and `LAST_START_TICKS` (default 1560 ticks before zero), the mod re-checks every 60 ticks. A platform whose charge becomes full in that window starts take-off at once. After `LAST_START_TICKS` the mod starts nothing.
15. A platform still landed at zero without a take-off in progress is lost with the surface. This is the penalty. The mod posts a chat message that names the platform.
16. Easy mode makes a platform always take off and lose nothing. At `AUTO_TAKEOFF_TICKS` the mod calls `remote.call("thud", "set_charge", landed_hub, BIG)` and then `take_off`. `set_charge` clamps to the need (07-planet-loop-tests.md, section 3), so `BIG` can be any value above the largest need, for example `1e12`. Easy mode is the runtime-global setting `sky-platforms-easy-mode`.
17. The collapse waits while any landed hub on the surface reports `is_taking_off`, up to `COLLAPSE_GRACE_TICKS` (default 60). A take-off that started before `LAST_START_TICKS` finishes its lift-off inside the 1560-tick margin, so the grace only covers rounding. If Thud's take-off needs the hub after the new platform exists, this grace must be revisited (not found in the tests).

Collapse

18. At zero the planet becomes `collapsing`. The mod moves every platform in orbit to the Drift by writing `platform.space_location = "sky-drift"`. It turns every platform that travels to the planet back to the Drift in the same way. A platform that is mid-descent returns to orbit by itself when the surface is deleted (docs/research/04-thud-api.md:125, impact.lua:596-598). The next poll then finds it in orbit and moves it to the Drift.
19. After the moves, the mod deletes the surface with `game.delete_surface`, marks the registry entries of lost platforms as `lost`, locks the location for the force, and sets the slot to `free`. The mod never deletes a surface that holds a `thud-landed-hub` whose platform is not lost on purpose (statement 15), and never in a tick where a move failed.

Timer research hook

20. A countdown has length `base_ticks * force_mod * type_mod`. `base_ticks` is the setting in minutes times 3600. `force_mod` is `storage.lifetime_mod.force[force_index]` and `type_mod` is `storage.lifetime_mod.type[force_index][type]`, both default 1.0. Design #10 writes these values. This spec only reads them when a countdown starts. The mod also exposes `remote.call("sky-platforms", "set_lifetime_modifier", force, type_or_nil, value)`.

Skipping

21. The skip scanner is a building. Each skip costs 100 `processing-unit` and 50 `low-density-structure`. A map setting sets the cost, so it can change (decided 2026-11-15). The cost is consumed when a player or a circuit signal triggers the skip. Skipping is meant for the mid and late game, for example when a player has plenty of Fulgora science and does not want more Fulgora-like planets. Triggering it on an `open` planet frees the slot and runs statement 5 for the replacement.
22. Skipping a `counting` planet is not allowed. The scanner shows "Planet has landings" and consumes nothing.

Circuit signals

23. A circuit-connected `sky-planet-timer` building (data stage) outputs, for the planet it is set to, the virtual signals `sky-time-left` (seconds), `sky-time-total` (seconds) and `sky-planet-state` (0 free, 1 open, 2 counting, 3 collapsing). An input signal `sky-skip` greater than 0 on the scanner triggers a skip (statement 21).

Platform registry

24. Every platform has a mod-side ID that does not change through landing and take-off. Other specs must store this ID and never `platform.index`.
25. Docs/spec/start-and-respawn.md stores `platform_index` in `storage.home_platform` (line 61) and `storage.respawn_choice` (line 62), and sorts by `platform.index` (line 162). Docs/spec/orbit-bootstrap.md also uses the index. Both must switch to the registry ID. Resolve the live object with `Registry.get_platform(id)`, which returns `nil` while the platform is landed. A landed platform's players stand on the planet surface, so those specs need a rule for a landed home platform (their decision, not this spec's).

Late landings

26. In the last 90 s of a countdown, a landing that starts shows a warning message and an alert to the force.
27. In the same window, the mod tries to block landings. It moves every orbiting platform's landing site to an impossible position with `remote.call("thud", "set_landing_site", platform, position)`. Thud refuses landings with water under the hub or at the map edge. This workaround is untested and needs a headless test.
28. When Thud adds a cancellable pre-landing hook (requested from the author), the mod uses that hook to refuse the landing instead.
29. The mod saves each platform's previous landing site before it moves the site. It restores the saved site after the planet collapses or when the countdown is no longer in the last 90 s.

## Platform registry

Storage

```lua
storage.platforms = {}            -- [id] = entry
storage.platform_next_id = 1
storage.platform_by_index = {}    -- [platform.index] = id, only while the object is valid
storage.platform_by_hub = {}      -- [landed_hub.unit_number] = id, only while landed

-- entry
{
  id = 7,
  force_index = 1,
  name = "Platform 3",
  state = "orbit",    -- "orbit" | "landing" | "landed" | "taking_off" | "lost"
  platform_index = 12,        -- set in orbit, landing and while the new platform is bound; nil while landed
  hub_unit = nil,             -- unit_number of the thud-landed-hub while landed
  slot = nil,                 -- slot (planet prototype) name while landing, landed or taking off
  state_tick = 4800,          -- game.tick of the last state change
}
```

Lifecycle of one ID

1. Register. On `on_surface_created`, if `surface.platform` is set (LuaSurface.platform exists in runtime-api), create an entry in `orbit`. On `on_init` and `on_configuration_changed`, scan `game.forces[*].platforms` for platforms with no entry.
2. Landing starts. The poll (below) sees `remote.call("thud", "is_landing", platform)` true. State becomes `landing`, `slot` is the planet being landed on.
3. Landing ends. The platform object becomes invalid and a `thud-landed-hub` exists on the slot surface. The mod binds the hub: `hub_unit = hub.unit_number`, `platform_by_hub[unit] = id`, `platform_index = nil`, state `landed`. This is the moment `counting` starts (statement 6).
4. Take-off starts. The mod calls take-off itself, or the poll sees `is_taking_off(hub)` true. State becomes `taking_off`.
5. New platform. `on_surface_created` fires for the new platform surface. The mod matches the entry in `taking_off` with the same force and the same `platform.name` (07-planet-loop-tests.md, section 3: same name, new index). It sets `platform_index = new.index`, clears `hub_unit` and `platform_by_hub`, state `orbit`.
6. Loss. At collapse, entries still `landed` become `lost`. A `lost` entry stays one hour (decided 2026-11-15) so other specs can react, then it is deleted.

Matching rules and ambiguity

- Two platforms of one force with the same name are possible if a player renames one. If two entries in `taking_off` share a name, match in ascending `id` order against new platforms in creation order. Log a warning. This is a desync-free but possibly wrong pairing, so the mod also renames platforms on landing to a unique name `<name>` plus `#<id>` only if a collision exists.
- Two landings on one surface in the same poll window leave two unclaimed hubs. The hub does not expose the platform name in anything read for this spec (not found). Match unclaimed hubs to `landing` entries sorted by `id` against hubs sorted by `unit_number`. Where possible the mod calls the landing itself (emergency or soft landing) and records the hub in the same tick, which avoids the guess. `POLL_TICKS` (30 ticks, decided) sets the window.
- Every use of `platform_index` first checks `.valid` (calls with an invalid platform raise "Expected a valid LuaSpacePlatform").
- The mod never stores a `LuaSpacePlatform` reference across ticks. It stores the index and resolves with `game.forces[force_index].platforms` when needed.

## Detection without events

Thud raises no custom events (07-planet-loop-tests.md, section 8). The mod uses four signals.

1. `on_built_entity`, `on_robot_built_entity`, `script_raised_built` and `on_space_platform_built_entity`, filtered to `thud-landed-hub`. Whether Thud's creation of the hub raises any of these is not found. The mod treats a hit as a fast path and does not rely on it.
2. `on_surface_created` with `surface.platform` for new platforms (register and rebind).
3. `on_surface_deleted` to confirm that a slot surface is gone.
4. A poll every `POLL_TICKS` (decided 30) over `storage.platforms`. For `orbit` and `landing` entries it checks `platform.valid` and `is_landing`. For `landed` entries it checks `hub.valid` and `is_taking_off`. A pass visits at most a handful of platforms, so the cost is small. The poll runs as one `on_nth_tick` handler.

A landing finishes when the platform is invalid, or when `is_landing` turns false while the hub exists (04-thud-api and 07 section 8: `is_landing` returns false for invalid objects).

## Data stage

- `mod-data` prototype `sky-platforms-lifecycle` with `data` fields `warning_stages` (default `{ {kind="fraction", value=0.5}, {kind="seconds", value=120}, {kind="seconds", value=60}, {kind="seconds", value=45, text="automatic-takeoff"}, {kind="seconds", value=26, text="too-late"} }`), `auto_takeoff_ticks = 2700`, `last_start_ticks = 1560`, `collapse_grace_ticks = 60`. The runtime read path (`prototypes.mod_data`) was not checked in runtime-api.json for this draft. ModData exists in prototype-api.json.
- Planet slot prototypes and the `sky-drift` space-location come from docs/spec/planet-types.md and the Drift spec. Every space connection has `length` 20000 (decided 2026-11-15): from `sky-drift` to each slot, and between slots. Slot prototypes live in `data.lua` so that Thud's data-final-fixes builds their descent entries (07-planet-loop-tests.md, verified facts).
- Entities `sky-skip-scanner` and `sky-planet-timer` with recipes and a technology (cost TBD).
- Virtual signals `sky-time-left`, `sky-time-total`, `sky-planet-state`, `sky-skip`.
- Locale for warnings, the top-bar element and the platform-lost message.

## Control stage

Storage

```lua
storage.planets = {}      -- [slot_name] = planet
storage.live_count = 0
storage.lifetime_mod = { force = {}, type = {} }   -- see statement 20
storage.saved_landing_sites = {}   -- [registry id] = previous landing site, kept while the planet is in its last 90 s

-- planet
{
  slot = "sky-nauvis-1",
  type = "nauvis",
  state = "open",            -- "open" | "counting" | "collapsing"
  open_tick = 3600,
  start_tick = nil,          -- tick of the first landing
  total_ticks = nil,
  end_tick = nil,            -- start_tick + total_ticks
  half_done = false,
  warned = {},               -- [stage_index] = true
  took_off = {},             -- [registry id] = true once take-off started here
}
```

Handlers and order

1. `on_init`, `on_configuration_changed` create the tables and register existing platforms.
2. `on_nth_tick(POLL_TICKS)` runs the registry poll first (so landings are known), then the planet pass.
3. Planet pass, per planet in ascending slot name order. Check `counting` stages (warnings, half-life), then the late-landing block (`end_tick - now <= 5400`, statements 26 to 29), then auto take-off (`end_tick - now <= auto_takeoff_ticks`), then collapse (`now >= end_tick`).
4. Timer ticks are computed from `game.tick`, so a stage fires at the first poll after its tick. With `POLL_TICKS = 30` a warning may be 29 ticks late at most. Warnings are cosmetic. The auto take-off margin of 1200 ticks absorbs that. The collapse itself uses `now >= end_tick`, so it lands within `POLL_TICKS` of zero. The top bar shows `end_tick - game.tick`, updated each second by a separate `on_nth_tick(60)` handler.
5. Collapse sequence in one tick, in order: set state `collapsing`, move orbiting and inbound platforms to `sky-drift`, re-read each platform's `space_location` to confirm the move, restore the saved landing sites, clear `storage.platform_by_*` entries for lost platforms, call `game.delete_surface`, lock the location, set `free`, run statement 5.

Code shape for Thud calls (closures, not `pcall(obj.method, obj, ...)`)

```lua
local function try_take_off(hub)
  if not hub.valid then return false end
  local ok, result = pcall(function()
    return remote.call("thud", "take_off", hub, {})
  end)
  return ok and result == true
end
```

## Settings

| Name | Type | Default | Note |
| --- | --- | --- | --- |
| `sky-platforms-planet-lifetime-minutes` | runtime-global int | 30 | Base countdown length. Range 5 to 240 (decided 2026-11-15). |
| `sky-platforms-easy-mode` | runtime-global bool | false | Statement 16. Runtime-global so a group can switch it mid-game. A startup setting was considered and rejected because it needs a restart. |
| `sky-platforms-poll-ticks` | startup int | 30 | Poll interval. A startup setting because `on_nth_tick` is registered at load. |
| `sky-platforms-skip-processing-units` | runtime-global int | 100 | Processing units per skip (statement 21). A map setting, so it can change mid-game. |
| `sky-platforms-skip-low-density-structures` | runtime-global int | 50 | Low density structures per skip (statement 21). A map setting, so it can change mid-game. |

The warning stages and take-off ticks are mod-data defaults, not settings.

## Storage and migrations

None for a first release. Later releases that add fields to `storage.planets` or `storage.platforms` ship a migration file `migrations/<version>.lua`. The migration for docs/spec/start-and-respawn.md and docs/spec/orbit-bootstrap.md (index to registry ID) is needed once those specs have shipped with `platform_index`. It rebuilds `storage.platforms` from `force.platforms`, maps each stored index to the new ID, and rewrites `storage.home_platform` and `storage.respawn_choice`. Name it in the release that changes them (version TBD).

## Multiplayer and determinism

- Everything runs in `on_nth_tick` handlers from `game.tick` and `storage`. No handler uses `math.random` outside `game.create_random_generator` seeded from storage (the planet roll is in planet-types.md).
- Iterate planets and platforms in sorted order, never by `pairs` order where order changes the result (collapse order, matching rules above).
- Remote calls to Thud run on every peer in the same tick, so they stay in sync.
- v1 is co-op on one force. All timers and modifiers key on `force_index`. Several forces would need one registry per force and per-force planets (out of scope).
- Risk. Hub matching with two simultaneous landings on one surface (see matching rules). Mitigation is the mod-made landing and the sorted fallback.
- Risk. The top-bar element must be created for players who join mid-countdown (`on_player_joined_game`).

## Slices

- [ ] L1. Platform registry and landing detection
- [ ] L2. A planet appears and stays
- [ ] L3. The first landing starts a countdown and the planet collapses
- [ ] L4. Timer display and staged warnings
- [ ] L5. Half-life brings the next planet, at most 2 live
- [ ] L6. Automatic take-off for charged platforms
- [ ] L7. Easy mode
- [ ] L8. Skip scanner
- [ ] L9. Circuit signals
- [ ] L10. Timer modifier hook
- [ ] L11. Block late landings

### L1. Platform registry and landing detection

After it ships, a player sees a chat line when a platform lands and when it takes off, with the platform name and ID. Nothing else changes.

- [ ] `storage.platforms` has one entry per platform after load, including platforms that exist before the mod was added.
- [ ] The ID of a platform stays the same after a landing and a take-off.
- [ ] Two platforms landing on one surface get different hubs.
- [ ] A removed or destroyed platform deletes its entry.
- [ ] docs/spec/start-and-respawn.md and docs/spec/orbit-bootstrap.md are updated to store the ID (their own slices).

Path to prod. Target release TBD. Migration yes (builds the registry on load). Test steps 1 to 4 below. Changelog "Added a platform registry that follows platforms through landing and take-off."

Test steps. 1. Start a save with two platforms. 2. Land one with `emergency_land` through the console. 3. Check `storage.platforms` shows `landed` and a hub unit number. 4. Call take-off and confirm the same ID has a new `platform_index`.

### L2. A planet appears and stays

After it ships, one Nauvis-like planet is available to travel to from the Drift at game start. It has no timer. Skipping is not yet possible.

- [ ] Exactly one slot is `open` after the first tick of a new game.
- [ ] The planet is unlocked for the force and reachable from `sky-drift`.
- [ ] The surface exists and chunks near the landing area generate over several ticks (no tick over 20 ms in the log).
- [ ] Reloading a save keeps the state.

Path to prod. Target release TBD. Migration no. Test steps. New game, open the starmap, travel from the Drift to the planet, check the surface exists. Changelog "A temporary planet now appears in orbit."

### L3. The first landing starts a countdown and the planet collapses

After it ships, landing on the open planet starts a 30 minute countdown. At zero the planet collapses. Orbiting platforms go to the Drift. Landed platforms are lost.

- [ ] State is `counting` after the first completed landing and `end_tick` is `start_tick + 108000`.
- [ ] A second landing on the same planet does not restart the timer.
- [ ] At zero the surface is deleted and the slot is `free`.
- [ ] Orbiting platforms have `space_location` `sky-drift`. Platforms travelling to the planet turn back to the Drift.
- [ ] A landed platform is lost and a chat message names it.
- [ ] With zero live planets after collapse, a new planet appears at once (statement 5).

Path to prod. Target release TBD. Migration no. Test steps. Land, set the setting to 5 minutes, wait, confirm the above. Changelog "Planets collapse after the first landing plus a countdown."

### L4. Timer display and staged warnings

After it ships, every player sees the countdown in the top bar and gets warnings at 50%, 2 min, 60 s, 45 s and 26 s.

- [ ] The top bar shows time left to the second for every connected player and for a player who joins later.
- [ ] Each stage shows once, in order, with a sound.
- [ ] The 45 s warning reads "automatic take-off at 45 s". The 26 s warning reads "too late: platforms without charge will be lost".
- [ ] With a 2 minute countdown, the 2 min stage is skipped as later than the total.

Path to prod. Target release TBD. Migration no. Changelog "Added the planet timer and warnings."

### L5. Half-life brings the next planet, at most 2 live

After it ships, the second planet appears at half-life.

- [ ] At 50% a free slot opens a second planet, `open`, with no timer.
- [ ] No third planet appears while 2 are live.
- [ ] If no slot is free at half-life, nothing appears and nothing errors.

Path to prod. Target release TBD. Migration no. Changelog "A second planet appears at half-life."

### L6. Automatic take-off for charged platforms

After it ships, platforms with a full damper charge lift off before the collapse and survive.

- [ ] A full-charge landed platform starts take-off at 2700 ticks before zero and has a new valid platform before zero, with the same registry ID.
- [ ] A platform without full charge stays and is lost.
- [ ] A platform whose charge fills between 2700 and 1560 ticks before zero starts take-off.
- [ ] No surface is deleted while a take-off that started in time is in progress.

Path to prod. Target release TBD. Migration no. Changelog "Charged platforms lift off automatically before a collapse."

### L7. Easy mode

After it ships, a map setting makes every landed platform take off without loss.

- [ ] With `sky-platforms-easy-mode` on, a platform with zero charge takes off at 2700 ticks before zero.
- [ ] `set_charge` is called before `take_off`.
- [ ] Turning it off mid-game applies to the next auto take-off pass.

Path to prod. Target release TBD. Migration no. Changelog "Added easy mode."

### L8. Skip scanner

After it ships, a player can skip an unwanted open planet.

- [ ] The scanner consumes its cost only when the skip runs.
- [ ] Skipping an `open` planet frees the slot and a replacement appears.
- [ ] Skipping a `counting` planet is refused with a message and no cost.
- [ ] A circuit `sky-skip` signal triggers the same skip.

Path to prod. Target release TBD. Migration no. Changelog "Added the planet skip scanner."

### L9. Circuit signals

After it ships, a timer building outputs the planet state.

- [ ] `sky-time-left` and `sky-time-total` match the top bar to the second.
- [ ] `sky-planet-state` shows 1, 2 or 3 as the planet changes.

Path to prod. Target release TBD. Migration no. Changelog "Added planet timer circuit signals."

### L10. Timer modifier hook

After it ships, other content can lengthen countdowns.

- [ ] The remote call sets a force modifier and a type modifier.
- [ ] A countdown that starts after the call uses `base * force_mod * type_mod`. A running countdown does not change.
- [ ] Modifiers persist in `storage` across save and load.

Path to prod. Target release TBD. Migration no. Changelog "Added a hook for timer research."

### L11. Block late landings

After it ships, a landing that starts in the last 90 s of a countdown shows a warning, and the mod tries to block it.

- [ ] A landing that starts in the last 90 s shows a warning message and an alert to the force.
- [ ] In the last 90 s, every orbiting platform's landing site is set to an impossible position with `remote.call("thud", "set_landing_site", platform, position)`. This needs a headless test.
- [ ] Each platform's previous landing site is restored after the collapse, or when the countdown leaves the last 90 s.
- [ ] Once Thud's cancellable pre-landing hook exists, the mod refuses the landing with it.

Path to prod. Target release TBD. Migration no, unless a release after L1 has already shipped without `storage.saved_landing_sites`. Test steps. Start a countdown, wait until 90 s are left, send a platform to land, and confirm the warning and that Thud refuses the landing. Changelog "Added a warning and a block for landings in the last 90 seconds of a countdown."

## Path to prod

Target release: TBD
Save migration: yes for L1 (registry build), no for others, unless a later slice adds fields.

Every release passes three checks. First, `emmylua_check` with the Factorio type library. Second, a headless `factorio --create` load with the mod and Thud. Third, the in-game self-test.

In-game test steps (full lifecycle):
1. New game with Thud. Confirm one open planet.
2. Land a platform. Confirm the timer starts and every player sees it.
3. Wait for half-life. Confirm a second planet.
4. Let a charged platform take off at 45 s left and an uncharged one stay.
5. Confirm collapse, loss message, orbiters at the Drift.
6. Turn on easy mode and repeat. Nothing is lost.

Changelog section (mod portal): see each slice.

## Decided 2026-11-15

1. Late landings. In the last 90 s of a countdown, a landing shows a warning and an alert to the force. The mod tries to block it by moving landing sites (statements 26 to 29). Once Thud adds a cancellable pre-landing hook, the mod uses that hook instead.
2. Warning stages. 50%, 2 min, 60 s, "automatic take-off at 45 s" and "too late: platforms without charge will be lost" at 26 s. These are mod defaults. The old 25 s "last chance" warning is removed.
3. Automatic take-off starts at 45 s left (`AUTO_TAKEOFF_TICKS` 2700). The last start is at 1560 ticks (`LAST_START_TICKS`, 26 s).
4. Timer start. The countdown starts when the landed hub exists.
5. Replacement after a collapse. After a collapse with no planet live, a new planet appears at once.
6. Skip cost. Each skip costs 100 `processing-unit` and 50 `low-density-structure`, set by a map setting so it can change. Skipping is meant for the mid and late game.
7. Travel distance. Every space connection (the Drift to each slot, and between slots) has length 20000. Players must design a reasonably fast platform, which steers them toward small lander ships. This also leaves room to start planet timers on arrival instead of on landing, if play tests ask for it.
8. Lifetime setting. Range 5 to 240 minutes, default 30.
9. Technical defaults. Poll every 30 ticks (`POLL_TICKS`). A lost platform's record stays for 1 hour. Collapse grace is 60 ticks (`COLLAPSE_GRACE_TICKS`).

## Open numbers

1. Late-landing block. Thud refuses landings with water under the hub or at the map edge, so `set_landing_site` to such a position should block a landing. This needs a headless test.
2. Thud pre-landing hook. Requested from the author. Until it ships, the landing-site move in statement 27 is the only block.

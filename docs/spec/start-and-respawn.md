# Spec: Start and respawn

## Summary

The player is a normal character standing on a space platform. This spec defines where a new player appears, where a dead player respawns, and what happens to the corpse. Vanilla respawns players on Nauvis, which the full mod hides, so the mod overrides respawn. The spec also defines the "home platform" concept and its storage. The rescue snapshot design (#12) reuses that concept and adds nothing here.

Decided on 2026-11-15:

- The character is a vanilla `character`. Handcrafting stays on.
- Empty space blocks movement, as in vanilla. The starting kit includes `mech-armor`, which lets the character fly over empty space and planet obstacles.
- Losing the armor over empty space kills the character. This is vanilla behaviour and needs no code.
- Respawn is a per-player choice of respawn point, defaulting to the home platform.
- When a character dies, the mod moves the corpse's items into the home platform hub. The fallback is the nearest platform tile.
- The home platform is the starting platform unless the player picks another.
- Multiplayer v1 is co-op on one force. Every new player spawns on the home platform.

## Parent design

#6, `docs/design/gameplay-flow.md`. Related: #8 (orbit bootstrap, `docs/spec/orbit-bootstrap.md`), #12 (rescue snapshot, uses the home platform), #9 (planets, hides Nauvis from the star map).

## Behaviour

1. A force has at most one home platform. `storage.home_platform[force_index]` holds it.
2. The first home platform of a force is the platform created by orbit bootstrap at game start.
3. A new player (`on_player_created`, or first join of an existing save) gets a fresh `character` on the home platform surface, within 5 tiles of the hub, on a tile that is not `empty-space`. The proposed radius is `TBD (proposed: 5)`.
4. The character that vanilla created on Nauvis for that player is destroyed after the new controller is set. No character is left on Nauvis.
5. The new character wears the items the kit gives it. At game start that includes `mech-armor` in the armor slot. A player who joins later gets no armor from the mod: `TBD (proposed: no extra armor; later joiners take one from the hub if one exists)`.
6. A player who dies respawns on the platform in their respawn choice. With no choice stored, the respawn point is the home platform.
7. If the chosen platform no longer exists or is not valid, the respawn point falls back to the home platform. If that also does not exist, it falls back to any platform of the force, lowest platform index first. If the force has no platform, the player respawns with the vanilla result and the mod prints one message to that player.
8. After a respawn, the player never stands on Nauvis (or any non-platform surface) unless no platform exists (statement 7).
9. A respawned character stands on a non-`empty-space` tile within 5 tiles of the hub of the respawn platform.
10. When a character dies, the items in the corpse move into the hub of the home platform. The hub inventory is `defines.inventory.chest`.
11. Items that do not fit in the hub stay in the corpse. The corpse then moves to the nearest platform tile of the death surface, searched within a radius of 32 tiles. The proposed radius is `TBD (proposed: 32)`.
12. If the hub does not exist (destroyed or platform deleted), statement 11 applies to all items.
13. If the death surface is not a platform surface, statements 10 to 12 use the home platform surface. The corpse is not moved to a platform it cannot reach, so the mod moves the items, not the entity.
14. A player may set a respawn point to any platform of their force that has a hub. The choice persists across saves and sessions.
15. A player may set the home platform of the force to any platform of the force that has a hub. Any player of the force may do this in v1 (co-op, one force).
16. A death over empty space (armor removed in flight) triggers statements 6 and 10 the same way as any other death.
17. Handcrafting is not disabled by this mod. `LuaPlayer.cheat_mode` and `LuaControl.character_crafting_speed_modifier` are not touched.

## Data stage

- Item `mech-armor`: vanilla Space Age item, no change. The mod only inserts it. The name comes from the brief. A direct check of `base/prototypes/item.lua` found no `"mech-armor"` entry, so the file that defines it is not found. Slice 1 includes one check that the item exists in `data.raw.armor`.
- Custom input and shortcut for the respawn and home picker GUI (slice 4):
  - `custom-input` `sky-platforms-respawn-menu`, default key `CONTROL + H`.
  - `shortcut` `sky-platforms-respawn-menu`, action `lua`, `associated_control_input = "sky-platforms-respawn-menu"`.
- Locale keys for the GUI (slice 4). No other prototypes.

## Control stage

### Storage

```lua
storage.home_platform = {}      -- [force_index] = platform_index
storage.respawn_choice = {}     -- [player_index] = platform_index; nil means "use home"
storage.pending_corpse = {}     -- [player_index] = { surface_index, position }
```

`LuaSpacePlatform.index` is the key used. Check that the attribute exists in `runtime-api.json` before slice 1 closes. It was not looked up for this draft.

### Events and handlers

| Event | Handler |
| --- | --- |
| `on_init` | Create the three storage tables. |
| `on_configuration_changed` | Create missing tables. Drop entries whose platform no longer exists. |
| `on_player_created` | If the player has no character on a platform, call `place_on_home(player)`. |
| `on_player_joined_game` | Safety net: if `player.surface` is not a platform surface and the force has a home platform, call `place_on_home(player)`. This covers existing saves. |
| `on_pre_player_died` | Record `storage.pending_corpse[player_index] = { surface_index, position }` from `player.character`. |
| `on_player_died` | Find the corpse near the recorded position and move its items (statements 10 to 13). Clear `pending_corpse`. |
| `on_player_respawned` | Call `relocate_respawn(player)` (statements 6 to 9). |
| `on_surface_deleted`, `on_space_platform_changed_state` | Remove stale `home_platform` and `respawn_choice` entries, then re-pick the home platform by statement 7 order. |

Platform deletion has no dedicated event looked up for this draft. Not found: confirm the exact event name (`on_space_platform_pre_mined`, `on_surface_deleted`) in `runtime-api.json` in slice 1.

### Placing a character on a platform

This is the verified route (Factorio 2.1.24, prototype branch `prototype/phase-1`):

```lua
local function place_on_platform(player, platform)
  local surface = platform.surface
  local pos = find_spawn_position(platform) -- non-empty-space tile near the hub
  local old = player.character
  local char = surface.create_entity({ name = "character", position = pos, force = player.force })
  player.set_controller({ type = defines.controllers.character, character = char })
  if old and old.valid then
    old.destroy()
  end
end
```

Rules for all code in this mod: Factorio API methods are dot calls with no self. Never write `pcall(obj.method, obj, ...)`. Wrap the call in a closure, for example `pcall(function() return old.destroy() end)`.

### Respawn

Vanilla creates the respawned character on the force's spawn surface (Nauvis). The mod relocates it in `on_player_respawned`:

1. Pick the platform: `respawn_choice[player_index]`, else `home_platform[force_index]`, else the fallbacks in statement 7.
2. Call `place_on_platform(player, platform)`. This reuses the verified route and destroys the Nauvis character.
3. `LuaForce.set_spawn_position(position, surface)` and `get_spawn_position(surface)` exist in `runtime-api.json`. They take a surface, so they set a per-surface spawn point. The runtime API does not say which surface a respawn uses. Not found. The mod therefore does not rely on spawn positions. It relocates after the fact.
4. A player who dies over empty space becomes a ghost (prototype finding) and would respawn on Nauvis at 0,0. `on_player_respawned` fires after that respawn, so statement 1 above handles it. `LuaPlayer.ticks_to_respawn` can be set to `nil` for an immediate respawn. The mod does not change the respawn timer in v1.

### Corpse handling

1. In `on_pre_player_died`, store the surface index and position of `player.character`.
2. In `on_player_died`, search with `surface.find_entities_filtered({ name = "character-corpse", position = pos, radius = 2 })`. Pick the corpse whose `character_corpse_player_index` equals the player index. The attribute name is from memory and not checked. Check it in `runtime-api.json` in slice 3.
3. Read the corpse inventory with `corpse.get_inventory(defines.inventory.character_corpse)`. Insert each stack into `hub.get_inventory(defines.inventory.chest)` and remove the inserted count from the corpse. Count what `insert` returns, never what was asked.
4. If anything is left, move the corpse with `corpse.teleport(tile_position)` to the nearest non-`empty-space` tile. Search tiles in growing rings up to the radius setting.

### Picker GUI (slice 4)

A small frame opened by the custom input. It lists the force's platforms by name (`platform.name`) with two buttons per row, "Respawn here" and "Make home". Handlers use `on_gui_click`. The GUI reads and writes the storage keys above and nothing else.

## Settings

| Name | Type | Default | Use |
| --- | --- | --- | --- |
| `sky-platforms-corpse-search-radius` | runtime-global, int, min 4, max 128 | 32 `TBD (proposed: 32)` | Radius for the nearest platform tile fallback (statement 11). |
| `sky-platforms-spawn-radius` | runtime-global, int, min 1, max 16 | 5 `TBD (proposed: 5)` | Distance from the hub for new and respawned characters (statements 3 and 9). |

The respawn choice is not a setting. It holds a platform index, which a settings value cannot express safely, so it lives in `storage`.

## Storage and migrations

- New saves: `on_init` creates the tables.
- Existing saves of this mod (before 0.1.0 there are none): None.
- Saves that load the mod for the first time: `on_configuration_changed` creates the tables. `on_player_joined_game` pulls players who stand off-platform onto the home platform. If no home platform exists, `home_platform` stays empty until orbit bootstrap creates one.
- Migration file: `migrations/0.2.0.lua` only if slice 2 changes the table shape. At present, None.

## Multiplayer and determinism

- All handlers run on every peer with identical inputs. They read only `storage` and game state.
- Iterate platforms with `force.platforms` in a stable order. Sort by `platform.index` before picking a fallback. Never use `pairs` order on a table keyed by index to decide the result.
- A player who joins later takes the same path as the first player (statement 3). Their `player_index` is new, so `respawn_choice` has no entry and the home platform applies.
- Several players who die in the same tick are handled one `on_player_died` at a time. Each corpse is matched by `character_corpse_player_index`, so two corpses on one tile do not swap. The hub is filled in event order. Event order is the same on all peers.
- A player who respawns while another player edits the home platform sees the home platform of the tick when `on_player_respawned` ran.
- The GUI changes `storage` only inside `on_gui_click`, which Factorio replays on all peers. No GUI state is stored in module-level variables.
- Do not use `math.random` or `game.tick`-seeded values for spawn offsets. Use a fixed ring order around the hub, indexed by the count of players already placed.
- Desync risk: moving a corpse with `teleport` while a player stands on the same tile. The mod does not move the character, so the risk is limited to the corpse entity.

## Slices

- [ ] 1. Spawn on the home platform
- [ ] 2. Respawn on the platform
- [ ] 3. Corpse into the hub
- [ ] 4. Pick respawn point and home platform

### Slice 1. Spawn on the home platform

After this ships, a new game or a new player puts the character on the home platform instead of Nauvis. Orbit bootstrap slice 1 calls this code, so both ship in 0.1.0.

Acceptance criteria:

- [ ] `storage.home_platform` and `storage.respawn_choice` exist after `on_init` and after `on_configuration_changed`.
- [ ] The first player stands on the home platform within the spawn radius, on a non-`empty-space` tile.
- [ ] No character of that player remains on Nauvis (`game.surfaces.nauvis.find_entities_filtered({ name = "character" })` is empty).
- [ ] A second player who joins later stands on the same platform.
- [ ] `emmylua_check` passes, and a headless `factorio --create` run loads the mod.

Path to prod:

- Target release: 0.1.0.
- Save migration: no.
- In-game test steps: 1. New game with the mod. 2. Confirm the character stands on the platform. 3. Join a second client. Confirm it stands on the same platform. 4. Check that Nauvis has no character.
- Changelog line: "You now start on a space platform, and new players join there."

### Slice 2. Respawn on the platform

After this ships, a dead player respawns on the home platform. A player killed over empty space no longer ends up on Nauvis.

Acceptance criteria:

- [ ] Die by damage on the platform. The player respawns within 5 tiles of the hub.
- [ ] Remove the armor while flying over `empty-space`. The player dies, then respawns on the platform, not on Nauvis at 0,0.
- [ ] Delete the home platform with other platforms present. The next respawn uses the lowest-index platform.
- [ ] No platform exists. The player respawns by vanilla rules and sees one message.
- [ ] Two players die in the same tick. Both respawn on the platform.

Path to prod:

- Target release: 0.2.0.
- Save migration: no.
- In-game test steps: 1. Run `/c game.player.character.die()`. 2. Check position and surface after respawn. 3. Fly over space, remove armor, repeat. 4. Repeat with two players.
- Changelog line: "Dead players respawn on the home platform instead of Nauvis."

### Slice 3. Corpse into the hub

After this ships, a player's items come back through the hub after any death, including a death over empty space.

Acceptance criteria:

- [ ] A death on the platform moves all corpse items into the hub. The corpse entity is gone when it is empty.
- [ ] A death over empty space puts the items in the hub. The player can pick the armor up there.
- [ ] A full hub leaves the overflow in the corpse, and the corpse sits on the nearest platform tile.
- [ ] A missing hub leaves all items in a corpse on a platform tile.
- [ ] Two simultaneous deaths yield two separate sets of items, each matched to its player.

Path to prod:

- Target release: 0.3.0.
- Save migration: no.
- In-game test steps: 1. Give the character items. 2. Kill the character on the platform and in space. 3. Open the hub and check items. 4. Fill the hub with a test script and repeat.
- Changelog line: "A dead player's items now move into the home platform hub."

### Slice 4. Pick respawn point and home platform

After this ships, a player opens a small window and chooses where they respawn, and the force can change its home platform.

Acceptance criteria:

- [ ] The shortcut and the key `CONTROL + H` open a list of the force's platforms.
- [ ] "Respawn here" stores `respawn_choice[player_index]`. The next death respawns there.
- [ ] "Make home" stores `home_platform[force_index]`. New players and corpses use it.
- [ ] Choices survive save and load.
- [ ] A choice that points to a deleted platform falls back to home (statement 7).

Path to prod:

- Target release: 0.4.0.
- Save migration: no (tables exist since 0.1.0).
- In-game test steps: 1. Create a second platform. 2. Pick it as respawn point. 3. Die and check. 4. Make it home. 5. Join a second client and check. 6. Save, load, check again.
- Changelog line: "Added a window to pick your respawn platform and the home platform."

## Path to prod

Releases are 0.1.0, 0.2.0, 0.3.0 and 0.4.0, one per slice. Slice 1 ships together with orbit-bootstrap slice 1 as 0.1.0.

Every release passes these checks before upload:

1. `emmylua_check` with the Factorio type library.
2. A headless `factorio --create` load of the zipped mod with its dependencies (Space Age, Thud).
3. The in-game self-test: the test steps of every slice shipped so far.

Target release: 0.1.0 to 0.4.0 as above.
Save migration: no, in all four slices.

In-game test steps: see each slice.

Changelog section (mod portal): one line per slice, as written in the slices.

## Open numbers

- `TBD (proposed: 5)` spawn and respawn radius around the hub, in tiles. Close enough to find the hub at once, far enough that several players do not stack.
- `TBD (proposed: 32)` corpse search radius for the nearest platform tile. A starting platform is a few dozen tiles wide, so 32 covers it.
- `TBD (proposed: no extra armor)` armor for a late joiner. Free armor would undo the "lose it over space and die" risk, and the hub holds the armor after a death.
- `TBD (proposed: CONTROL + H)` key for the picker window. Not bound in vanilla Factorio 2.1 to the best of the brief's knowledge. Check for conflicts before 0.4.0.
- `TBD (proposed: no change to respawn timer)` vanilla respawn delay stays as it is.

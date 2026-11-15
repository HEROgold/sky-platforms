# Bodiless start: mod-driven space platform start without a character

## Sources

- API: `C:\Program Files (x86)\Steam\steamapps\common\Factorio\doc-html\runtime-api.json` (Factorio 2.1.24). Names below are API member names. Descriptions are quoted from this file.
- Prototypes: `C:\Program Files (x86)\Steam\steamapps\common\Factorio\doc-html\prototype-api.json`.
- Freeplay scenario (read only): `C:\Program Files (x86)\Steam\steamapps\common\Factorio\data\base\script\freeplay\freeplay.lua`. Cited below as `freeplay.lua:N`.
- Platformer (GPL, read for ideas only): `C:\Users\marti\Documents\GitHub\FactorioMods\Platformer\`. Cited below as `control\init.lua:N` and so on.
- Research notes: `C:\Users\marti\Documents\GitHub\sky-platforms\docs\research\00-summary.md` and `01-platformer-voidblock.md`.

The API descriptions are one line for most members. They do not list which actions each controller allows. Where this file says "not stated", the API does not answer the question, and a prototype has to test it.

## Summary

The god controller is the only documented controller that is not tied to a character (`defines.controllers.god`: "The controller isn't tied to a character."). Setting it with `LuaPlayer.set_controller` removes the body from the player's control path. Two things stay open after that:

- The god controller has its own crafting list (`GodControllerPrototype.crafting_categories`), so handcrafting is not off by default.
- The docs do not say what a platform does to the controller. A mod must set the controller itself and test the result.

## 1. Options for "no body"

Each row lists what the API says. "Not stated" means the API gives no answer.

### God controller

- Definition: `defines.controllers.god`, "The controller isn't tied to a character. This is the default controller in sandbox."
- Set with `LuaPlayer.set_controller` (`type = defines.controllers.god`).
- Inventory: `LuaControl.insert` inserts "into this entity" and picks the inventory itself. The player has an inventory size (`GodControllerPrototype.inventory_size`). Whether the hub GUI accepts drag and drop: not stated.
- Hub items: the hub is `LuaControl.hub` ("the space platform hub the player is currently sitting in"). Taking items from the hub by hand: not stated.
- Build: not stated. The sandbox default suggests free building, but the API gives no reach or permission rule for this controller.
- Handcraft: allowed by default in the prototype's sense. `GodControllerPrototype.crafting_categories` is "Names of the crafting categories the player can craft recipes from." Its vanilla value is not in the docs.
- Machine GUIs: not stated.
- Map: not stated.
- Walk: `GodControllerPrototype.movement_speed` exists, so the controller moves something. Whether it moves on a platform: not stated.

### Remote controller

- Definition: `defines.controllers.remote`, "Can't move/change items but can build ghosts/change settings."
- Set with `LuaPlayer.set_controller` (`type = defines.controllers.remote`, plus `surface` and `position`).
- Inventory: no. "Can't move/change items."
- Hub items: no.
- Build: ghosts only.
- Handcraft: no. Changing items is blocked, so crafting is blocked too. Not stated directly.
- Machine GUIs: "change settings" may cover some GUIs. Not stated.
- Map: remote view. `LuaPlayer.exit_remote_view` exists.
- Walk: no.
- Risk: `LuaPlayer.physical_controller_type` says a remote player "will return to" its physical controller. If that physical controller is a character-less god controller, it is fine. The API does not say what the return does if the player has no body.
- Risk: whether a platform surface is valid for `surface` is not stated.

### Character kept but hidden

- No API member found to hide a character. A search of `LuaPlayer` and `LuaEntity` members for "hide" and "visible" returned no match in the descriptions I read. Not found.
- Handcraft: the character's list is `CharacterPrototype.crafting_categories` ("the crafting categories the character can craft recipes from"). It stays on unless a data stage edit removes it.
- Walk, build, GUIs, inventory: all as a normal character. Not found as a restriction.
- Risk: this is the Platformer path. See section 5.

### Spectator controller

- Definition: `defines.controllers.spectator`, "Can't change anything in the world but can view anything."
- Use: view only. No build, no inventory, no hub.

### Cutscene controller

- Definition: `defines.controllers.cutscene`, "The player can't interact with the world, and the camera pans around in a predefined manner."
- Needs waypoints (`LuaPlayer.set_controller`, `waypoints` is mandatory for this type).
- Freeplay uses it for the crash site cutscene (`freeplay.lua:91-92`).

### Ghost controller

- Definition: `defines.controllers.ghost`, "Can't interact with the world, can only observe. Used in the multiplayer waiting-to-respawn screen."
- Use: a holding state for a player with no body. It is not a play state.

### Character with a disassociated body

- `LuaPlayer.disassociate_character` and `LuaEntity.associated_player` say a character can exist without a player controlling it. The docs say: "A character associated with a player is not directly controlled by any player."
- This does not hide the character from the world. It only cuts the link.

## 2. Vanilla platform start and the controller

- `LuaControl.hub` describes the hub as "the space platform hub the player is currently sitting in." This is the only place the API describes a player on a platform. It names no controller and no character.
- `LuaPlayer.enter_space_platform` takes a `LuaSpacePlatform` and returns a boolean. Its description does not mention the controller or the character.
- `LuaPlayer.leave_space_platform`: "The player is left on the platform at the position of the hub."
- `LuaPlayer.land_on_planet`: "Ejects this player from the current space platform and lands on the current planet."
- `LuaPlayer.physical_controller_type` and `physical_surface` describe a "physical" controller separate from a remote one. The API does not name the controller a vanilla platform uses.
- Not found: any member that names the controller a vanilla platform player has. The brief's claim that a platform player has no physical character is not confirmed by these docs. It needs a test in game.
- A mod does not get a bodiless platform for free from `enter_space_platform`, as far as the docs say. The mod still has to set the controller after entering. The docs do not say whether entering changes it.

Platform creation, from the API:

- `LuaForce.create_space_platform` takes `name`, `planet`, and `starter_pack`, and returns a `LuaSpacePlatform`.
- `LuaSpacePlatform.apply_starter_pack` returns the hub `LuaEntity`. The API says it applies the pack "if it hasn't already been applied."
- `LuaSpacePlatform.hub` "does not exist if the platform has not had the starter pack applied."
- `LuaSpacePlatform.surface` is the platform's surface, "if it has been created yet."

## 3. Placing the player on game start, joins, respawn, and character return

Game start and joins:

- `on_player_created` is "Called after the player was created." The API does not say whether it repeats for a player who rejoins.
- `on_player_joined_game` is "Called after a player joins the game." It is not called for a singleplayer save load.
- Freeplay's own handler runs on `on_player_created` (`freeplay.lua:235`). It inserts the created items into the player (`freeplay.lua:72`), creates a crash site and cutscene on the first run (`freeplay.lua:79-93`), and shows the intro message (`freeplay.lua:98`). The crash site path guards `player.character` (`freeplay.lua:88-90`).
- Freeplay's `util.insert_safe` is not read. Whether it works for a player with no character: not verified.
- Freeplay's created items are inserted on every player creation. A bodiless start must set the created items to empty (`freeplay.lua:149-150`, remote `set_created_items`), or the player still gets items.
- The crash site is skipped with the remote call `set_disable_crashsite` (`freeplay.lua:176-177`). Platformer calls it at `control\init.lua:101-106`.
- The order of freeplay's `on_init` and the first `on_player_created` for the remote call is not verified.

Respawn:

- `on_player_respawned` is "Called after a player respawns." Freeplay inserts the respawn items here (`freeplay.lua:102-105`).
- A player with no character does not die, so respawn does not come up by itself. Not stated directly.

Getting a character back:

- `LuaPlayer.create_character` "Creates and attaches a character entity to this player." It requires that the player has no character and is online.
- `LuaPlayer.associate_character` attaches an existing character. The character "must not be connected to any controller."
- `LuaPlayer.swap_characters` swaps bodies with another player.
- `LuaPlayer.set_controller` with `defines.controllers.character` needs a `character` argument.
- A cargo pod: `on_cargo_pod_finished_ascending` has `player_index` ("The player that is riding the cargo pod, if any."). A pod ride can bring the player back to a planet. The API does not say whether the ride gives the player a character.
- `LuaPlayer.land_on_planet` is the documented landing call. The API does not say what it does to the controller or the character.
- `on_player_changed_surface` is "Called after a player changes surfaces." It lets a mod watch a return.
- `on_player_controller_changed` fires after a controller change, with `old_type`.
- Not found: any event that fires when a character is created for a player. A mod must check `LuaPlayer.character` after a landing or a pod ride.

## 4. Disabling handcrafting

Two prototype fields control handcrafting. Both are data-stage edits, so they go in `data-updates.lua`:

- Character: `CharacterPrototype.crafting_categories`, "Names of the crafting categories the character can craft recipes from." Setting it to an empty list removes character handcraft. The data path is `data.raw.character` (the prototype name is `character`; the vanilla entry is not read here).
- God controller: `GodControllerPrototype.crafting_categories`, "Names of the crafting categories the player can craft recipes from." The prototype's `name` property is "default" in the base game (`prototype-api.json`, `GodControllerPrototype.name`). The data path is `data.raw["god-controller"]["default"]`.

Runtime options:

- `LuaControl.cheat_mode` makes handcraft "free and instant" when true. It is not a block.
- `LuaControl.begin_crafting`, `get_craftable_count` and `crafting_queue` are read and start functions. None of them describes a block.
- Removing recipes or setting them disabled per force was not checked. The recipe members were not read. Verify `LuaRecipe.enabled` before relying on it.

Claim check: the controller does not "have none". The god controller has a crafting list, so the default is not empty by docs. The docs do not give its vanilla value.

## 5. How Platformer does it

File references use `C:\Users\marti\Documents\GitHub\FactorioMods\Platformer\` as the base.

- `control.lua:2-4`: requires `control\init.lua`, `control\events.lua`, and `control\xdebug.lua`.
- `control\init.lua:2-7` (`on_init`): calls `disable_cutsceene`, `create_space_platform`, `set_starting_items`, `create_permission_group`, and shrinks the world and deletes its chunks.
- `control\init.lua:10-23` (`on_player_created`):
  - Adds the player to a "players" permission group (`:13-16`).
  - Destroys the character if one exists (`:18-20`).
  - Teleports the player to `{ x = 0, y = 0 }` on the platform surface (`:22`).
- `control\init.lua:63-68` (`create_permission_group`): sets `defines.input_action.land_at_planet` to false (`:66`). This blocks landing through the input action. It does not block handcraft.
- `control\init.lua:70-84` (`create_space_platform`): `force.create_space_platform` with name "Base One", planet "nauvis", and the starter pack (`:72-76`). Then `apply_starter_pack` (`:82`) and `storage.platform` (`:83`).
- `control\init.lua:86-98` (`set_starting_items`): inserts items into the hub (`hub.insert`, `:89-95`).
- `control\init.lua:100-106` (`disable_cutsceene`): calls freeplay's `set_disable_crashsite` (`:103`).
- `control\events.lua:1-3`: destroys each cargo pod on `on_cargo_pod_finished_ascending`.
- `data\prototypes\tips-and-tricks.lua:25-38`: a tutorial simulation. It uses `game.simulation.create_test_player`. It is not the live start.

What Platformer does not do, checked by grep over the Platformer folder:

- No `set_controller` call. The controller is never changed from character.
- No `crafting_categories` edit in data. Character handcraft stays on.
- No `set_created_items` call. The freeplay created items still go to the player (`freeplay.lua:72`).
- No `create_character` or `associate_character` call.

Research claims, and what the code shows:

- `00-summary.md:15`: "It kept handcrafting, so the start was not really bodiless." The code agrees. No handcraft block exists in the Platformer files.
- `01-platformer-voidblock.md:33`: the character "still exists", handcraft is enabled, and one player "opened the character GUI and handcrafted after visiting Nauvis." The code does destroy the character at `control\init.lua:18-20`, so the research and the code do not match on whether a character exists. The code does not show how a character returns after a visit to Nauvis. Not found in the Platformer code. The API does not say what landing does. The research note is the only source for the GUI and handcraft after the visit.
- `01-platformer-voidblock.md:122`: "Platformer left the character with handcrafting and the GUI opened when returning from a planet." Same issue. The code path is not visible in the repo, and the mechanism is not confirmed by the API.

Platformer's own code gives no clear reason for the character to return. The mismatch between `control\init.lua:18-20` and the research needs a test in game, not a guess.

## Options table

| Option | What the player can do | Risks |
| --- | --- | --- |
| God controller (`defines.controllers.god`) | Not tied to a body. Build, insert, and handcraft are not stated. Handcraft is on by default through `GodControllerPrototype.crafting_categories`. Walk: `movement_speed` exists, on a platform not stated. | Handcraft unless the list is emptied. Freeplay's created items. Hub GUI and map not stated. |
| Remote controller (`defines.controllers.remote`) | Build ghosts and change settings. No item moves, so no hub items and no handcraft. | Return target `physical_controller_type`. Platform surface validity not stated. Remote view has no body. |
| Character kept, hidden | Full character: walk, build, GUI, handcraft, inventory. | No hide API found. Handcraft stays unless `CharacterPrototype.crafting_categories` is emptied. This is the Platformer path with the complaints. |
| Spectator (`defines.controllers.spectator`) | View only. | Cannot build or use the hub. |
| Cutscene (`defines.controllers.cutscene`) | Camera only. | No interaction. Needs waypoints. |
| Ghost (`defines.controllers.ghost`) | Observe only. | Used for the waiting-to-respawn screen. |

## Questions a prototype must answer

1. Under `defines.controllers.god`, can the player insert items from the hub (`LuaControl.insert`) and open the hub GUI on a platform?
2. Under the god controller, is handcraft on by default? Read `GodControllerPrototype.crafting_categories` in game and test a handcraft.
3. Does `enter_space_platform` change `LuaPlayer.controller_type` or `LuaPlayer.character`? Log both before and after.
4. Under `defines.controllers.remote` with a platform `surface`, can the player place ghosts? Does `LuaPlayer.physical_controller_type` return to a valid controller after `exit_remote_view`?
5. Does `land_on_planet` or a cargo pod ride call `create_character` or change the controller? Check `LuaPlayer.character` and `controller_type` on arrival.
6. Does `on_player_created` fire again when a player rejoins? Test with a second client.
7. Does freeplay's `util.insert_safe` work with no character? Read `util` before relying on it.
8. Does the freeplay `on_init` set `disable_crashsite` before the first `on_player_created`? Test a new game.
9. Does Platformer's `control\init.lua:18-20` leave a character on the player in practice? Compare `LuaPlayer.character` in a new game and after a Nauvis visit. This settles the research mismatch in section 5.
10. Can a character be hidden at all? The API found no member for it. Confirm before using it as an option.
11. Does `set_created_items` with an empty map remove all starting items for a new player?

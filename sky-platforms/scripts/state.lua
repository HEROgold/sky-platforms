-- Creates every storage table. Safe to call again.
local registry = require("scripts.registry")

local state = {}

function state.init()
  registry.init()
  storage.home_platform = storage.home_platform or {}   -- [force_index] = platform ID
  storage.respawn_choice = storage.respawn_choice or {} -- [player_index] = platform ID
  storage.armor_given = storage.armor_given or {}       -- [player_index] = true
  -- bootstrap_done stays nil until it is known whether the save is new.
end

return state
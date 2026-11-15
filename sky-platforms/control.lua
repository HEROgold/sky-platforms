local state = require("scripts.state")
local bootstrap = require("scripts.bootstrap")

--- The freeplay scenario may be missing, so each call is guarded.
---@param fn "set_skip_intro"|"set_disable_crashsite"|"set_created_items"
local function call_freeplay(fn, ...)
  local interface = remote.interfaces["freeplay"] --[[@as table<string, boolean>?]]
  if interface and interface[fn] then
    ---@diagnostic disable-next-line: generic-constraint-mismatch
    return remote.call("freeplay", fn, ...)
  end
end

script.on_init(function()
  state.init()
  call_freeplay("set_skip_intro", true)
  call_freeplay("set_disable_crashsite", true)
  call_freeplay("set_created_items", {})
  storage.bootstrap_done = false
  bootstrap.run(game.forces["player"])
end)

script.on_configuration_changed(function()
  state.init()
  if storage.bootstrap_done == nil then
    -- An existing save adds the mod: it keeps its progress and gets no kit.
    storage.bootstrap_done = true
  end
end)
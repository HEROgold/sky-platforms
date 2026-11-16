-- Space Age limits the steel furnace to surfaces with pressure 10 or more. Thud takes that limit off
-- the prototype and keeps it in its "thud-surface-conditions" mod-data, where a script stops the
-- furnace on a space platform. Thud loads before this mod, so drop the kept limit and its tooltip line.
-- The kit has steel furnaces. Stone furnaces stay vanilla.
local steel_furnace = data.raw["furnace"]["steel-furnace"]
steel_furnace.surface_conditions = nil

local kept = data.raw["mod-data"]["thud-surface-conditions"]
if kept and kept.data then
  kept.data["steel-furnace"] = nil
end

local fields = steel_furnace.custom_tooltip_fields
if fields then
  for i = #fields, 1, -1 do
    local name = fields[i].name
    if type(name) == "table" and name[1] == "thud-tooltip.working-conditions" then
      table.remove(fields, i)
    end
  end
  if #fields == 0 then
    steel_furnace.custom_tooltip_fields = nil
  end
end

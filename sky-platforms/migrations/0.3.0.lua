-- Saves from 0.2.0 keep the old research effects, so recompute them for the new unlocks.
for _, force in pairs(game.forces) do
  force.reset_technology_effects()
end

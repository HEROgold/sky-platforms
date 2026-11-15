-- Saves from 0.1.0 load recipes from the saved state, so enable the new crushing recipes.
for _, force in pairs(game.forces) do
  for _, name in ipairs({ "sky-metallic-crushing-copper", "sky-oxide-crushing-stone" }) do
    force.recipes[name].enabled = true
  end
end

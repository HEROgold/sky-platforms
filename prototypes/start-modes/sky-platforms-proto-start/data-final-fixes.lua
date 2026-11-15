-- This is what is being tested: the god controller gets only a crafting category
-- that no recipe uses, so it has no handcrafting. Factorio refuses an empty list.
-- If a handcraft still works in god mode, this is wrong.
data:extend({ { type = "recipe-category", name = "sky-proto-no-handcraft" } })
local god = data.raw["god-controller"] and data.raw["god-controller"]["default"]
local count_before = 0
if god then
  count_before = god.crafting_categories and #god.crafting_categories or 0
  god.crafting_categories = { "sky-proto-no-handcraft" }
end

-- Lets control.lua report what the data stage did, since the runtime API has no
-- direct read of the god controller prototype.
data:extend({
  {
    type = "mod-data",
    name = "sky-start-god-info",
    data = { found = god ~= nil, categories_before = count_before, categories_after = 0 },
  },
})

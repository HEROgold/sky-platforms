data:extend({
  {
    type = "double-setting",
    name = "sky-platforms-kit-scale",
    setting_type = "startup",
    default_value = 1,
    minimum_value = 0.5,
    maximum_value = 4,
    order = "a",
  },
  {
    type = "int-setting",
    name = "sky-platforms-spawn-radius",
    setting_type = "runtime-global",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 16,
    order = "b",
  },
})
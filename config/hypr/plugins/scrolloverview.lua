hl.config({
  plugin = {
    scrolloverview = {
      gesture_distance = 300,
      scale = 0.75,
      workspace_gap = 50,
      layout = "vertical",
      wallpaper = 2,
      blur = true,
      shadow = {
        enabled = false,
        range = 50,
        render_power = 3,
        color = 0xee1a1a1a,
      },
    },
  },
})

-- Scrolloverview toggle binding.
--hl.bind("HOME", function()
  --hl.plugin.scrolloverview.overview("toggle")
--end)

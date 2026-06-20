-- Hyprland plugin configuration.
-- Plugins must be loaded via hyprpm before these settings take effect.

hl.config({
  plugin = {
    scrolloverview = {
      gesture_distance = 300,
      scale            = 0.75,
      workspace_gap    = 50,
      layout           = "vertical",
      wallpaper        = 2,
      blur             = true,
      shadow = {
        enabled      = false,
        range        = 50,
        render_power = 3,
        color        = 0xee1a1a1a,
      },
    },
  },
})

-- Scrolloverview toggle binding.
hl.bind("HOME", function()
  hl.plugin.scrolloverview.overview("toggle")
end)

-- hyprfocus and hyprbars are commented out until installed via hyprpm.
-- hl.config({
--   plugin = {
--     hyprfocus = {
--       enabled                  = true,
--       mode                     = "slide",
--       slide_height             = 5,
--       keyboard_focus_animation = "slide",
--       mouse_focus_animation    = "slide",
--     },
--     hyprbars = {
--       bar_height                 = 29,
--       bar_blur                   = true,
--       bar_part_of_window         = true,
--       bar_precedence_over_border = true,
--       bar_title_enabled          = false,
--       bar_text_size              = 11,
--       bar_text_font              = "SF Pro Display Semibold",
--       bar_text_align             = "center",
--       bar_buttons_alignment      = "left",
--       bar_padding                = 12,
--       bar_button_padding         = 8,
--       icon_on_hover              = true,
--       on_double_click            = "hyprctl dispatch fullscreen 1",
--     },
--   },
-- })
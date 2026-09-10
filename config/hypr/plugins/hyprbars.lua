hl.config({
  plugin = {
    hyprbars = {
      -- Layout & Dimensions
      bar_height                 = 29,
      bar_padding                = 12,
      bar_button_padding         = 8,
      bar_buttons_alignment      = "left",
      
      -- Typography & Titles
      bar_title_enabled          = false,
      bar_text_size              = 11,
      bar_text_font              = "SF Pro Display Semibold",
      bar_text_align             = "center",
      
      -- Behavior & Composition
      bar_blur                   = true,
      bar_part_of_window         = true,
      bar_precedence_over_border = true,
      icon_on_hover              = true,
      on_double_click            = "fullscreen 1", -- Direct dispatcher
      
      -- Colors
      bar_color                  = "rgba(1e1e22ee)",
      ["col.text"]               = "rgb(f0f0f5)",
    }
  }
})

-- Define titlebar buttons (Left to Right)
-- Close Window (Red)
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(ff6b6b)",
  fg_color = "rgb(1e1e22)",
  size     = 12,
  icon     = "󰖭",
  action   = "killactive", -- Direct dispatcher
})

-- Minimize Window (Yellow)
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(ffe66d)",
  fg_color = "rgb(1e1e22)",
  size     = 12,
  icon     = "",
  action   = "exec bash ~/.config/hypr/plugins/hyprbars-minimize.sh", -- Explicit path & execution
})

-- Maximize / Fullscreen Window (Green)
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(7bed9f)",
  fg_color = "rgb(1e1e22)",
  size     = 12,
  icon     = "",
  action   = "fullscreen 1", -- Direct dispatcher
})
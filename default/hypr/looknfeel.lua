-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

local active_border_color   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 }
local inactive_border_color = "rgba(595959aa)"

hl.config({
  general = {
    gaps_in      = 5,
    gaps_out     = 10,
    border_size  = 2,

    col = {
      active_border   = active_border_color,
      inactive_border = inactive_border_color,
    },

    resize_on_border = false,
    allow_tearing    = false,
    layout           = "dwindle",
  },

  decoration = {
    rounding = 0,

    shadow = {
      enabled      = true,
      range        = 2,
      render_power = 3,
      color        = "rgba(1a1a1aee)",
    },

    blur = {
      enabled    = true,
      size       = 2,
      passes     = 2,
      special    = true,
      brightness = 0.60,
      contrast   = 0.75,
    },
  },

  group = {
    col = {
      border_active          = active_border_color,
      border_inactive        = inactive_border_color,
      border_locked_active   = active_border_color,
      border_locked_inactive = inactive_border_color,
    },

    groupbar = {
      font_size                 = 12,
      font_family               = "monospace",
      font_weight_active        = "ultraheavy",
      font_weight_inactive      = "normal",
      indicator_height          = 0,
      indicator_gap             = 5,
      height                    = 22,
      gaps_in                   = 5,
      gaps_out                  = 0,
      text_color                = "rgb(ffffff)",
      text_color_inactive       = "rgba(ffffff90)",
      col = {
        active   = "rgba(00000040)",
        inactive = "rgba(00000020)",
      },
      gradients                 = true,
      gradient_rounding         = 0,
      gradient_round_only_edges = false,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
    force_split    = 2,
  },

  scrolling = {
    column_width = 0.49,
  },

  master = {
    new_status = "master",
  },

  misc = {
    disable_hyprland_logo      = true,
    disable_splash_rendering   = true,
    disable_scale_notification = true,
    focus_on_activate          = true,
    anr_missed_pings           = 3,
    on_focus_under_fullscreen  = 1,
  },

  cursor = {
    hide_on_key_press        = true,
    warp_on_change_workspace = 1,
  },

  binds = {
    hide_special_on_workspace_change = true,
  },
})

-- Default fallback animations (fast preset).
-- These are overridden by ~/.config/hypr/animations.lua if present.
-- Fast animation preset.

hl.config({ animations = { enabled = true } })

hl.curve("md3_decel",     { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("easeOutExpo",   { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("md3_accel",     { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("linear",        { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "windows",          enabled = true, speed = 3,   bezier = "md3_decel",   style = "popin 60%" })
hl.animation({ leaf = "border",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 2.5, bezier = "md3_decel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,   bezier = "md3_decel",   style = "slidevert" })
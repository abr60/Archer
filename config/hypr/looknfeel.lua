-- Personal look-and-feel overrides.
-- Colors reference matugen CSS variables set by the theme engine.

-- --- General ---
local ok, colors = pcall(require, "hypr.bin.colors")
local active_border   = ok and colors.primary              or "rgba(33ccffee)"
local inactive_border = ok and colors.secondary_container  or "rgba(595959aa)"

hl.config({
  general = {
    layout      = "master",
    gaps_in     = 2,
    gaps_out    = 2,
    border_size = 1,
    col = {
      active_border   = active_border,
      inactive_border = inactive_border,
    },
  },
})

-- --- Decoration ---
hl.config({
  decoration = {
    rounding        = 6,
    active_opacity  = 0.92,
    inactive_opacity = 0.95,

    blur = {
      enabled           = true,
      size              = 4,
      passes            = 3,
      contrast          = 0.95,
      brightness        = 0.9,
      vibrancy          = 0.15,
      vibrancy_darkness = 0.25,
      noise             = 0.015,
      ignore_opacity    = true,
    },
  },
})

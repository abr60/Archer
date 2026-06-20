-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Suppress maximize events globally.
hl.window_rule({ suppress_event = "maximize", match = { class = ".*" } })

-- Tag all windows for default opacity.
hl.window_rule({ tag = "+default-opacity", match = { class = ".*" } })

-- Fix some dragging issues with XWayland.
hl.window_rule({
  no_focus = true,
  match    = { class = "^$", title = "^$", xwayland = 1, float = 1, fullscreen = 0, pin = 0 },
})

-- App-specific tweaks.
local paths     = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")
require_all.files(paths.archer_path .. "/default/hypr/apps", "default.hypr.apps")

-- Apply default opacity after apps have had a chance to opt out.
hl.window_rule({ opacity = "0.97 0.9", match = { tag = "default-opacity" } })
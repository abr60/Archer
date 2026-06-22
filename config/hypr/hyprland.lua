-- Configuration Guide: https://wiki.hypr.land/Configuring/

-- Load user modules from ~/.config and Archer defaults from $ARCHER_PATH.
package.path = os.getenv("HOME")
  .. "/.config/?.lua;"
  .. (os.getenv("ARCHER_PATH") or (os.getenv("HOME") .. "/.local/share/Archer"))
  .. "/?.lua;"
  .. package.path

-- --- 1. Archer System Defaults (Do Not Edit) ---
require("default.hypr.archer")

-- --- 2. Personal Overrides (User Settings) ---
-- These files overwrite the defaults loaded above.
require("hypr.monitors")
require("hypr.envs")
require("hypr.input")
require("hypr.looknfeel")
require("hypr.animations")
require("hypr.bindings")
require("hypr.rules")
require("hypr.autostart")
require("hypr.gestures")

-- --- 3. Toggle config flags dynamically ---
require("default.hypr.toggles")

-- --- 4. Theme Configuration ---
-- do
--   local paths = require("default.hypr.paths")
--   local theme = io.open(paths.config_home .. "/Archer/current/theme/hyprland.lua", "r")
--   if theme then
--     theme:close()
--     require("archer.current.theme.hyprland")
--   end
-- end

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and resolutions possible: hyprctl monitors all

-- ThinkPad T14 Gen 2i — 1080p internal display at 1.5x scale.
hl.env("GDK_SCALE", "1")
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1.5, transform = 0 })

-- Uncomment to enable a secondary HDMI monitor:
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1280x0", scale = 1 })

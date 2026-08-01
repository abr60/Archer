-- Touchpad gesture configuration.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/

-- 3-finger horizontal swipe: switch workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 4-finger swipe up/down: toggle fullscreen
hl.gesture({ fingers = 3, direction = "up",   action = "fullscreen", scale = 1.5 })
hl.gesture({ fingers = 3, direction = "down",  action = "fullscreen", scale = 0.5 })

-- Scrolloverview plugin gesture (3-finger vertical)
-- hl.gesture({ fingers = 3, direction = "vertical", action = "scrolloverview:overview" })

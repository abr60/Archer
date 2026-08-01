-- Trackpad Gesture: Swipe up with 3 fingers
hl.gesture({
  fingers = 4,
  direction = "up", -- explicit direction is cleaner than generic "vertical"
  action = function()
    hl.exec_cmd("qs ipc -c overview call overview toggle")
  end,
})

-- Keybind: Super + ` (grave)
hl.bind("SUPER + grave", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))
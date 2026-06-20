-- Personal input overrides.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_options    = "compose:rctrl",
    repeat_rate   = 40,
    repeat_delay  = 600,
    numlock_by_default = true,
    accel_profile = "flat",
    sensitivity   = 0.54,

    touchpad = {
      scroll_factor        = 0.4,
      disable_while_typing = true,
    },
  },
})

-- Scroll sensitivity per terminal.
a.window("(Alacritty)", { scroll_touchpad = 1.5 })
a.window("(kitty|com.mitchellh.ghostty)", { scroll_touchpad = 0.2 })

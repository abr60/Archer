-- Laptop multimedia keys for volume and LCD brightness (with OSD).

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("archer-swayosd-client --output-volume raise"),      { description = "Volume up",             flags = { "el" } })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("archer-swayosd-client --output-volume lower"),      { description = "Volume down",           flags = { "el" } })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("archer-swayosd-client --output-volume mute-toggle"),{ description = "Mute",                  flags = { "el" } })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("audio-input-mute"),                                  { description = "Mute microphone",        flags = { "el" } })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness-display +5%"),                     { description = "Brightness up",          flags = { "el" } })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness-display 5%-"),                     { description = "Brightness down",        flags = { "el" } })
hl.bind("SHIFT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness-display 100%"),            { description = "Brightness maximum",     flags = { "el" } })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness-display 1%"),              { description = "Brightness minimum",     flags = { "el" } })
hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightness-keyboard up"),                     { description = "Keyboard brightness up", flags = { "el" } })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightness-keyboard down"),                   { description = "Keyboard brightness down", flags = { "el" } })
hl.bind("XF86KbdLightOnOff",     hl.dsp.exec_cmd("brightness-keyboard cycle"),                  { description = "Keyboard backlight cycle", flags = { "l" } })
hl.bind("XF86TouchpadToggle",    hl.dsp.exec_cmd("toggle-touchpad"),                            { description = "Toggle touchpad",        flags = { "l" } })
hl.bind("XF86TouchpadOn",        hl.dsp.exec_cmd("toggle-touchpad on"),                         { description = "Enable touchpad",        flags = { "l" } })
hl.bind("XF86TouchpadOff",       hl.dsp.exec_cmd("toggle-touchpad off"),                        { description = "Disable touchpad",       flags = { "l" } })

-- Precise 1% adjustments with Alt modifier.
hl.bind("ALT + XF86AudioRaiseVolume",  hl.dsp.exec_cmd("archer-swayosd-client --output-volume +1"), { description = "Volume up precise",      flags = { "el" } })
hl.bind("ALT + XF86AudioLowerVolume",  hl.dsp.exec_cmd("archer-swayosd-client --output-volume -1"), { description = "Volume down precise",    flags = { "el" } })
hl.bind("ALT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightness-display +1%"),             { description = "Brightness up precise",  flags = { "el" } })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightness-display 1%-"),             { description = "Brightness down precise",flags = { "el" } })

-- Requires playerctl.
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("archer-swayosd-client --playerctl next"),         { description = "Next track",  flags = { "l" } })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("archer-swayosd-client --playerctl play-pause"),   { description = "Pause",       flags = { "l" } })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("archer-swayosd-client --playerctl play-pause"),   { description = "Play",        flags = { "l" } })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("archer-swayosd-client --playerctl previous"),     { description = "Previous track", flags = { "l" } })

-- Switch audio output with Super + Mute.
hl.bind("SUPER + XF86AudioMute", hl.dsp.exec_cmd("audio-output-switch"), { description = "Switch audio output", flags = { "l" } })
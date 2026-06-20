-- Menus
a.bind("SUPER + CTRL + E",         "Emoji picker",              "rofimoji")
a.bind("SUPER + CTRL + C",         "Capture menu",              "menu capture")
a.bind("SUPER + CTRL + O",         "Toggle menu",               "menu toggle")
a.bind("SUPER + CTRL + H",         "Hardware menu",             "menu hardware")
a.bind("SUPER + ALT + SPACE",      "Archer menu",               "menu")
a.bind("SUPER + ESCAPE",           "Power Menu",                "rofi-powermenu")
a.bind("XF86PowerOff",             "Power menu",                "rofi-powermenu")
a.bind("SUPER + Delete",           "Logout",                    hl.dsp.exit())
a.bind("SUPER + K",                "Show key bindings",         "menu-keybindings")
a.bind("XF86Calculator",           "Calculator",                "gnome-calculator")

-- Aesthetics
a.bind("SUPER + SHIFT + SPACE",         "Toggle top bar",                   "toggle-waybar")
a.bind("SUPER + CTRL + SPACE",          "Theme background menu",            "menu background")
a.bind("SUPER + SHIFT + CTRL + SPACE",  "Theme menu",                       "menu theme")
a.bind("SUPER + BACKSPACE",             "Toggle window transparency",        "hyprland-window-transparency-toggle")
a.bind("SUPER + SHIFT + BACKSPACE",     "Toggle window gaps",                "hyprland-window-gaps-toggle")
a.bind("SUPER + CTRL + BACKSPACE",      "Toggle single-window square aspect","hyprland-window-single-square-aspect-toggle")

-- Notifications
a.bind("SUPER + COMMA",             "Dismiss last notification",         "makoctl dismiss")
a.bind("SUPER + SHIFT + COMMA",     "Dismiss all notifications",         "makoctl dismiss --all")
a.bind("SUPER + CTRL + COMMA",      "Toggle silencing notifications",    "toggle-notification-silencing")
a.bind("SUPER + ALT + COMMA",       "Invoke last notification",          "makoctl invoke")
a.bind("SUPER + SHIFT + ALT + COMMA","Restore last notification",        "makoctl restore")

-- Toggles
a.bind("SUPER + CTRL + I",        "Toggle locking on idle",           "toggle-idle")
a.bind("SUPER + CTRL + N",        "Toggle nightlight",                "toggle-nightlight")
a.bind("SUPER + CTRL + Delete",   "Toggle laptop display",            "hyprland-monitor-internal toggle")
a.bind("SUPER + CTRL + ALT + Delete","Toggle laptop display mirroring","hyprland-monitor-internal-mirror toggle")

hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("hw-external-monitors && hyprland-monitor-internal off"), { flags = { "l" } })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprland-monitor-internal on"),                         { flags = { "l" } })

-- Captures
a.bind("PRINT",           "Screenshot",                       "capture-screenshot")
a.bind("ALT + PRINT",     "Screenrecording",                  "menu screenrecord")
a.bind("SUPER + PRINT",   "Color picker",                     "pkill hyprpicker || hyprpicker -a")
a.bind("SUPER + CTRL + PRINT", "Extract text (OCR) from screenshot", "capture-text-extraction")

-- File sharing
a.bind("SUPER + CTRL + S", "Share", "menu share")

-- Transcoding
a.bind("SUPER + CTRL + period", "Transcode", "transcode")

-- Reminders
a.bind("SUPER + CTRL + R",         "Set reminder",     "menu reminder-set")
a.bind("SUPER + CTRL + ALT + R",   "Show reminders",   "reminder show")
a.bind("SUPER + SHIFT + CTRL + R", "Clear reminders",  "reminder clear")

-- Waybar-less information
a.bind("SUPER + CTRL + ALT + T", "Show time",             "notify-send -u low \"    $(date +'%A %H:%M  ·  %d %B %Y  ·  Week %V')\"")
a.bind("SUPER + CTRL + ALT + B", "Show battery remaining","notify-send -u low \"$(battery-status)\"")
a.bind("SUPER + CTRL + ALT + W", "Show weather",          "notify-send -u low \"$(weather-status)\"")

-- Control panels
a.bind("SUPER + CTRL + A", "Audio controls",     "launch-audio")
a.bind("SUPER + CTRL + B", "Bluetooth controls", "launch-bluetooth")
a.bind("SUPER + CTRL + W", "Wifi controls",      "launch-wifi")
a.bind("SUPER + CTRL + T", "Activity",           "launch-tui btop")

-- Dictation (push-to-talk)
hl.bind("F9",        hl.dsp.exec_cmd("voxtype record start"), { description = "Start dictation (push-to-talk)" })
hl.bind("F9",        hl.dsp.exec_cmd("voxtype record stop"),  { description = "Stop dictation (push-to-talk)", flags = { "r" } })

-- Zoom
a.bind("SUPER + CTRL + Z",       "Zoom in",    "hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float + 1')")
a.bind("SUPER + CTRL + ALT + Z", "Reset zoom", "hyprctl keyword cursor:zoom_factor 1")

-- Lock system
a.bind("SUPER + CTRL + L", "Lock system", "system-lock")
-- Copy / Paste

a.bind("SUPER + C",        "Universal copy",         hl.dsp.send_shortcut({ mods = "CTRL",  key = "Insert", window = "activewindow" }))
a.bind("SUPER + V",        "Universal paste",        hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert", window = "activewindow" }))
a.bind("SUPER + X",        "Universal cut",          hl.dsp.send_shortcut({ mods = "CTRL",  key = "X",      window = "activewindow" }))
a.bind("SUPER + CTRL + V", "Clipboard manager",      "cliphist list | rofi -dmenu | cliphist decode | wl-copy")
a.bind("CTRL + D",         "Delete clipboard entry", "cliphist list | rofi -dmenu | cliphist delete")
a.bind("SUPER + period",   "Emoji",                  "rofimoji")
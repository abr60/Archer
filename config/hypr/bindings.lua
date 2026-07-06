-- Personal keybinding overrides and additions.

-- === UI ===
a.bind("SUPER + SPACE",     "Applications launcher",  "rofi-applications")
a.bind("SUPER + ALT + RETURN", "Tmux",               a.launch("xdg-terminal-exec --dir=\"$(cmd-terminal-cwd)\" bash -c \"tmux attach || tmux new -s Work\""))
a.bind("XF86Favorites",    "Theme Mode",              "archer-set-mode $([ \"$(cat ~/.local/state/Archer/current-mode)\" = 'dark' ] && echo light || echo dark) && pkill -SIGRTMIN+1 waybar")
a.bind("SUPER + B",        "waybar-theme",   a.launch("waybar-theme"))

-- === Apps ===
a.bind("SUPER + SHIFT + M", "Music",      { launch = "spotify", focus = "spotify" })
a.bind("SUPER + SHIFT + D", "Docker",     "launch-tui lazydocker")
a.bind("SUPER + SHIFT + S", "Signal",     { launch = "signal-desktop", focus = "^signal$" })
a.bind("SUPER + SHIFT + O", "Obsidian",   a.launch("obsidian -disable-gpu --enable-wayland-ime"))
a.bind("SUPER + SHIFT + W", "Typora",     a.launch("typora --enable-wayland-ime"))
a.bind("SUPER + SHIFT + SLASH", "Passwords", a.launch("1password"))

-- === Tools ===
a.bind("ALT + M", "Toolbox", "[float; size 800 600] archer-hub")
a.bind("ALT + B",     "Set wallpaper",   "rofi-set-bg")
a.bind("ALT + SPACE", "Select theme",    "rofi-set-theme")
a.bind("ALT + comma", "Unmount",         "archer-hdd-unmount")
a.bind("ALT + Z",     "Dictation",       "voxtype record toggle")

-- === Special Keys ===
a.bind("XF86NotificationCenter", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

-- === Hardware ===
a.bind("SUPER + M", "Comic (Latin)", "archer-comic-translate lat")
a.bind("SUPER + N", "Comic (Asian)", "archer-comic-translate cjk")

-- === Floating TUI launchers ===
a.bind("ALT + C", "RMPC Music", "[float; center] kitty --title=rmpc-full -e rmpc")
a.bind("ALT + X", "Study",        "[float; size 700 200; center] kitty --class=Yazi --title=Yazi -e timeout 30s yazi \"~/Videos/Anime\"")

-- === Wifi QR popup ===
a.bind("SUPER + Q", "Wifi QR", "[float; size 302 416; move 967 40; pin] kitty --class=wifi-qr --title=wifi-qr -e archer-wifi-qr")

-- === Plugin Bindings ===

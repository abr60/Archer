-- Floating windows
hl.window_rule({ float = true,  match = { tag = "floating-window" } })
hl.window_rule({ center = true, match = { tag = "floating-window" } })
hl.window_rule({ size = "875 600", match = { tag = "floating-window" } })

hl.window_rule({ tag = "+floating-window", match = { class = "(org.archer.bluetui|org.archer.impala|org.archer.wiremix|org.archer.btop|org.archer.terminal|org.archer.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|Archer|About|TUI.float|imv|mpv)" } })
hl.window_rule({ tag = "+floating-window", match = { class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)", title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[Cc]hoose.*)" } })
hl.window_rule({ float = true, match = { class = "org.gnome.Calculator" } })

-- Fullscreen screensaver
hl.window_rule({ fullscreen = true, match = { class = "org.archer.screensaver" } })
hl.window_rule({ float = true,      match = { class = "org.archer.screensaver" } })
hl.window_rule({ animation = "slide", match = { class = "org.archer.screensaver" } })

-- No transparency on media windows
hl.window_rule({ tag = "-default-opacity", match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" } })
hl.window_rule({ opacity = "1 1",          match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" } })

-- Popped window rounding
hl.window_rule({ rounding = 8, match = { tag = "pop" } })

-- Prevent idle while open
hl.window_rule({ idle_inhibit = "always", match = { tag = "noidle" } })

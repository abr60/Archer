-- Floating windows
hl.window_rule({ float = true,  match = { tag = "floating-window" } })
hl.window_rule({ center = true, match = { tag = "floating-window" } })
hl.window_rule({ size = "875 600", match = { tag = "floating-window" } })

hl.window_rule({ tag = "+floating-window", match = { class = "(org.omarchy.bluetui|org.omarchy.impala|org.omarchy.wiremix|org.omarchy.btop|org.omarchy.terminal|org.omarchy.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|Omarchy|About|TUI.float|imv|mpv)" } })
hl.window_rule({ tag = "+floating-window", match = { class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)", title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[Cc]hoose.*)" } })
hl.window_rule({ float = true, match = { class = "org.gnome.Calculator" } })

-- Fullscreen screensaver
hl.window_rule({ fullscreen = true, match = { class = "org.omarchy.screensaver" } })
hl.window_rule({ float = true,      match = { class = "org.omarchy.screensaver" } })
hl.window_rule({ animation = "slide", match = { class = "org.omarchy.screensaver" } })

-- No transparency on media windows
hl.window_rule({ tag = "-default-opacity", match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" } })
hl.window_rule({ opacity = "1 1",          match = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" } })

-- Popped window rounding
hl.window_rule({ rounding = 8, match = { tag = "pop" } })

-- Prevent idle while open
hl.window_rule({ idle_inhibit = "always", match = { tag = "noidle" } })

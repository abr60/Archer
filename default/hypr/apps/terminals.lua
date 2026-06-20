hl.window_rule({ tag = "+terminal",        match = { class = "(Alacritty|kitty|com.mitchellh.ghostty|foot)" } })
hl.window_rule({ tag = "-default-opacity", match = { tag = "terminal" } })
hl.window_rule({ opacity = "0.97 0.9",     match = { tag = "terminal" } })

-- Puts the window exactly in the top-left corner
hl.window_rule({ float = true, match = { class = "(Share|localsend)" } })
hl.window_rule({ size = { 420, 756 }, match = { class = "localsend" } })
hl.window_rule({ move = { 5, 8 }, match = { class = "(Share|localsend)" } })

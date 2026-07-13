-- Position CLIAMP music player in the bottom right corner
hl.window_rule({ float = true,     match = { class = "^kitty$", title = "^cliamp$" } })
hl.window_rule({ size = "650 420", match = { class = "^kitty$", title = "^cliamp$" } })
hl.window_rule({ move = "620 290", match = { class = "^kitty$", title = "^cliamp$" } })

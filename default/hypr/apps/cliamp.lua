-- Position CLIAMP music player in the bottom right corner
hl.window_rule({ float = true,     match = { class = "^kitty$", title = "^cliamp$" } })
hl.window_rule({ size = "650 500", match = { class = "^kitty$", title = "^cliamp$" } })
hl.window_rule({ move = "5 260", match = { class = "^kitty$", title = "^cliamp$" } })

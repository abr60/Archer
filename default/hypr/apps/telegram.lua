-- Prevent Telegram from stealing focus on new messages.
hl.window_rule({ focus_on_activate = false, match = { class = "org.telegram.desktop" } })

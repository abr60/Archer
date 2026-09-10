-- Web app bindings.

a.bind("SUPER + SHIFT + C",        "Claude",       { webapp = "https://claude.ai" })
a.bind("SUPER + SHIFT + G",        "GitHub",       { webapp = "https://github.com/abr60/Archer" })
a.bind("SUPER + SHIFT + Y",        "YouTube",      { webapp = "https://youtube.com/" })
a.bind("SUPER + SHIFT + X",        "X",            { webapp = "https://x.com/" })
a.bind("SUPER + SHIFT + P",        "Google Photos",{ webapp = "https://photos.google.com/", focus = true })

a.bind("SUPER + SHIFT + ALT + A",  "Grok",         { webapp = "https://grok.com" })
a.bind("SUPER + SHIFT + ALT + G",  "WhatsApp",     { webapp = "https://web.whatsapp.com/", focus = true })
a.bind("SUPER + SHIFT + ALT + X",  "X Post",       { webapp = "https://x.com/compose/post" })
a.bind("SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
a.bind("SUPER + A", "Local LLM", { webapp = "http://localhost:8080" })
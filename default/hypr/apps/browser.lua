-- Browser types
hl.window_rule({ tag = "+chromium-based-browser", match = { class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)" } })
hl.window_rule({ tag = "+firefox-based-browser",  match = { class = "([fF]irefox|zen|librewolf)" } })
hl.window_rule({ tag = "-default-opacity", match = { tag = "chromium-based-browser" } })
hl.window_rule({ tag = "-default-opacity", match = { tag = "firefox-based-browser" } })

-- Video apps: remove chromium browser tag so they don't get opacity applied.
hl.window_rule({ tag = "-chromium-based-browser", match = { class = "(chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default)" } })
hl.window_rule({ tag = "-default-opacity",         match = { class = "(chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default)" } })

-- Force chromium-based browsers into a tile to deal with --app bug.
hl.window_rule({ tile = true, match = { tag = "chromium-based-browser" } })

-- Only a subtle opacity change, but not for video sites.
hl.window_rule({ opacity = "1.0 0.97", match = { tag = "chromium-based-browser" } })
hl.window_rule({ opacity = "1.0 0.97", match = { tag = "firefox-based-browser" } })

-- Hide the screen-sharing notification bar.
hl.window_rule({ workspace = "special silent", match = { title = ".*is sharing.*" } })

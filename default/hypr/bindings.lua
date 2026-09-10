-- Application bindings (Archer defaults).

-- Terminal
a.bind("SUPER + RETURN",        "Terminal",            a.launch("xdg-terminal-exec --dir=\"$(cmd-terminal-cwd)\""))
a.bind("SUPER + SHIFT + RETURN","Browser",             a.launch("launch-browser"))
a.bind("SUPER + SHIFT + F",     "File manager",        a.launch("thunar"))
a.bind("SUPER + ALT + SHIFT + F","File manager (cwd)", a.launch("thunar \"$(cmd-terminal-cwd)\""))
a.bind("SUPER + SHIFT + B",     "Browser",             a.launch("launch-browser"))
a.bind("SUPER + SHIFT + ALT + B","Browser (private)",  a.launch("launch-browser --private"))
a.bind("SUPER + SHIFT + N",     "Editor",              a.launch("launch-editor"))

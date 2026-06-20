-- Window management and tiling keybindings.

-- Close windows.
a.bind("SUPER + W",           "Close window",         hl.dsp.window.close())
a.bind("CTRL + ALT + DELETE", "Close all windows",    "hyprland-window-close-all")

-- Control tiling.
a.bind("SUPER + J",        "Toggle window split",              hl.dsp.layout("togglesplit"))
a.bind("SUPER + P",        "Pseudo window",                    hl.dsp.window.pseudo())
a.bind("SUPER + T",        "Toggle window floating/tiling",    hl.dsp.window.float({ action = "toggle" }))
a.bind("SUPER + F",        "Full screen",                      hl.dsp.window.fullscreen({ mode = "fullscreen" }))
a.bind("SUPER + CTRL + F", "Tiled full screen",                hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
a.bind("SUPER + ALT + F",  "Full width",                       hl.dsp.window.fullscreen({ mode = "maximized" }))
a.bind("SUPER + O",        "Pop window out (float & pin)",     "hyprland-window-pop")
a.bind("SUPER + L",        "Toggle workspace layout",          "hyprland-workspace-layout-toggle")

-- Move focus.
a.bind("SUPER + LEFT",  "Focus on left window",  hl.dsp.focus({ direction = "l" }))
a.bind("SUPER + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }))
a.bind("SUPER + UP",    "Focus on above window", hl.dsp.focus({ direction = "u" }))
a.bind("SUPER + DOWN",  "Focus on below window", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with SUPER + [1-9; 0].
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  a.bind("SUPER + " .. key,           "Switch to workspace "              .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  a.bind("SUPER + SHIFT + " .. key,   "Move window to workspace "         .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  a.bind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end

-- Scratchpad.
a.bind("SUPER + S",       "Toggle scratchpad",         hl.dsp.workspace.toggle_special("scratchpad"))
a.bind("SUPER + ALT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- TAB between workspaces.
a.bind("SUPER + TAB",         "Next workspace",    hl.dsp.focus({ workspace = "e+1" }))
a.bind("SUPER + SHIFT + TAB", "Previous workspace",hl.dsp.focus({ workspace = "e-1" }))
a.bind("SUPER + CTRL + TAB",  "Former workspace",  hl.dsp.focus({ workspace = "previous" }))

-- Move workspaces to other monitors.
a.bind("SUPER + SHIFT + ALT + LEFT",  "Move workspace to left monitor",  hl.dsp.workspace.move({ monitor = "l" }))
a.bind("SUPER + SHIFT + ALT + RIGHT", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
a.bind("SUPER + SHIFT + ALT + UP",    "Move workspace to up monitor",    hl.dsp.workspace.move({ monitor = "u" }))
a.bind("SUPER + SHIFT + ALT + DOWN",  "Move workspace to down monitor",  hl.dsp.workspace.move({ monitor = "d" }))

-- Swap windows.
a.bind("SUPER + SHIFT + LEFT",  "Swap window to the left",  hl.dsp.window.swap({ direction = "l" }))
a.bind("SUPER + SHIFT + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
a.bind("SUPER + SHIFT + UP",    "Swap window up",           hl.dsp.window.swap({ direction = "u" }))
a.bind("SUPER + SHIFT + DOWN",  "Swap window down",         hl.dsp.window.swap({ direction = "d" }))

-- Cycle windows.
a.bind("ALT + TAB",             "Focus on next window",      hl.dsp.window.cycle_next())
a.bind("ALT + SHIFT + TAB",     "Focus on previous window",  hl.dsp.window.cycle_next({ next = false }))

-- Cycle monitors.
a.bind("CTRL + ALT + TAB",       "Focus on next monitor",     hl.dsp.focus({ monitor = "+1" }))
a.bind("CTRL + ALT + SHIFT + TAB","Focus on previous monitor",hl.dsp.focus({ monitor = "-1" }))

-- Resize active window.
a.bind("SUPER + code:20",            "Expand window left",       hl.dsp.window.resize({ x = -100, y = 0,    relative = true }))
a.bind("SUPER + code:21",            "Shrink window left",       hl.dsp.window.resize({ x = 100,  y = 0,    relative = true }))
a.bind("SUPER + SHIFT + code:20",    "Shrink window up",         hl.dsp.window.resize({ x = 0,    y = -100, relative = true }))
a.bind("SUPER + SHIFT + code:21",    "Expand window down",       hl.dsp.window.resize({ x = 0,    y = 100,  relative = true }))

-- Scroll through workspaces.
a.bind("SUPER + mouse_down", "Scroll active workspace forward",  hl.dsp.focus({ workspace = "e+1" }))
a.bind("SUPER + mouse_up",   "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Groups.
a.bind("SUPER + G",       "Toggle window grouping",            hl.dsp.group.toggle())
a.bind("SUPER + ALT + G", "Move active window out of group",   hl.dsp.window.move({ out_of_group = true }))

a.bind("SUPER + ALT + LEFT",  "Move window to group on left",   hl.dsp.window.move({ into_group = "l" }))
a.bind("SUPER + ALT + RIGHT", "Move window to group on right",  hl.dsp.window.move({ into_group = "r" }))
a.bind("SUPER + ALT + UP",    "Move window to group on top",    hl.dsp.window.move({ into_group = "u" }))
a.bind("SUPER + ALT + DOWN",  "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))

a.bind("SUPER + ALT + TAB",         "Next window in group",     hl.dsp.group.next())
a.bind("SUPER + ALT + SHIFT + TAB", "Previous window in group", hl.dsp.group.prev())
a.bind("SUPER + CTRL + LEFT",        "Move grouped window focus left",  hl.dsp.group.prev())
a.bind("SUPER + CTRL + RIGHT",       "Move grouped window focus right", hl.dsp.group.next())

a.bind("SUPER + ALT + mouse_down", "Next window in group",     hl.dsp.group.next())
a.bind("SUPER + ALT + mouse_up",   "Previous window in group", hl.dsp.group.prev())

for index = 1, 5 do
  a.bind("SUPER + ALT + code:" .. tostring(index + 9), "Switch to group window " .. index, hl.dsp.group.active({ index = index }))
end

-- Cycle monitor scaling.
a.bind("SUPER + code:61",       "Cycle monitor scaling",           "hyprland-monitor-scaling-cycle")
a.bind("SUPER + ALT + code:61", "Cycle monitor scaling backwards", "hyprland-monitor-scaling-cycle --reverse")
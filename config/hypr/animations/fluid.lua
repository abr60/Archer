-- Fluid animation preset.

hl.config({ animations = { enabled = true } })

hl.curve("wind",      { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn",     { type = "bezier", points = { { 0.1, 1.1 },  { 0.1, 1.1 } } })
hl.curve("winOut",    { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("linear",    { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })
hl.curve("slowEase",  { type = "bezier", points = { { 0.3, 0 },    { 0.2, 1 } } })
hl.curve("md3_decel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })

hl.animation({ leaf = "windows",          enabled = true, speed = 6,  bezier = "wind",     style = "popin 80%" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 7,  bezier = "winIn",    style = "slide" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 5,  bezier = "winOut",   style = "slide" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 5,  bezier = "wind",     style = "slide" })
hl.animation({ leaf = "border",           enabled = true, speed = 12, bezier = "slowEase" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 50, bezier = "linear",   style = "loop" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3,  bezier = "md3_decel" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 6,  bezier = "wind" })
hl.animation({ leaf = "layers",           enabled = true, speed = 3,  bezier = "slowEase" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5,  bezier = "wind",     style = "slidevert" })
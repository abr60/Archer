hl.gesture({ fingers = 3, direction = "vertical", action = function() hl.exec_cmd("qs ipc -c overview call overview toggle") end })


hl.bind("SUPER + grave", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))


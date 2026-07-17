hl.config({
    plugin = {
        hyprexpo = {
            columns = 3,
            gaps_in = 5,
            gaps_out = 0,
            bg_col = "rgb(111111)",
            workspace_method = "center current",
            gesture_distance = 200,
            cancel_key = "escape",
            show_cursor = 1,
        },
    },
})


hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = function()
        if hl.plugin and hl.plugin.hyprexpo then
            hl.plugin.hyprexpo.expo("toggle")
        else
            hl.exec_cmd("hyprctl dispatch hyprexpo:expo toggle")
        end
    end
})


hl.bind("SUPER + grave", function() 
    hl.plugin.hyprexpo.expo("toggle") 
end)
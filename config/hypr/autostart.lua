-- Personal autostart processes.
-- These run in addition to Archer's default autostart.

-- --- System Daemons & Services ---
a.exec_on_start("ollama serve")
a.exec_on_start("archer-earbuds-status")
a.exec_on_start("easyeffects --gapplication-service") -- EasyEffects DSP
--a.exec_on_start("xdg-terminal-exec bash ~/Archer/post-install.sh")
--exec_on_start("kitty --class cava-desktop --override background_opacity=0.0 --override background=#000000 -e cava")
-- --- Commented / Optional ---
-- a.exec_on_start("qs -c ii")
-- a.exec_on_start("archer-battery-monitor")
-- a.exec_on_start("archer-inject.sh")
-- a.exec_on_start("sleep 1 && paplay ~/.config/hypr/assets/sounds/TempleOS-Hymn-Risen.wav")

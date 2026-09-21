local mainMod = "SUPER"
hl.bind(mainMod .. "+R", hl.dsp.exec_cmd("hyprlauncher"))

-- Power menu. The flags matter for the styling: -n keeps it on one monitor
-- and -L/-R pull the buttons in toward the centre. See ~/.config/wlogout/style.css
hl.bind(mainMod .. "+SHIFT+X", hl.dsp.exec_cmd("wlogout -n -b 3 -L 400 -R 400 -T 360 -B 360 -c 20"))

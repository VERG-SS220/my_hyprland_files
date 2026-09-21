-- Wallpapers, one per monitor, driven over hyprpaper's IPC.
-- hyprpaper has no Lua config of its own, so we assign the images with
-- `hyprctl hyprpaper wallpaper` once its socket is up. hyprpaper 0.8.x
-- loads the file itself, so no separate preload request is needed (and
-- `preload`/`unload` are in fact rejected as invalid requests there).
-- hyprpaper itself is started in func/autoexec.lua.
-- See https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/

local pictures = os.getenv("HOME") .. "/Pictures"

-- output -> image file inside ~/Pictures
local wallpapers = {
	["DP-2"] = "wp5995111-anime-city-4k-wallpapers.jpg", -- left monitor
	["DP-1"] = "thumb-1920-1348663.jpeg",                -- right monitor
}

hl.on("hyprland.start", function()
	local cmds = {}

	for output, image in pairs(wallpapers) do
		table.insert(cmds, string.format(
			"hyprctl hyprpaper wallpaper '%s,%s/%s'", output, pictures, image))
	end

	-- Wait for hyprpaper to come up before talking to it, then apply.
	hl.exec_cmd(string.format(
		"sh -c 'for i in $(seq 50); do hyprctl hyprpaper listactive >/dev/null 2>&1 && break; sleep 0.1; done; %s'",
		table.concat(cmds, "; ")
	))
end)

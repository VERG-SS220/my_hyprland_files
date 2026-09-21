-- Apps launched once when Hyprland starts.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

local autoexec = {
	"hyprpaper",
	"waybar",
	"mako",
	"steam",
	"chromium",
}

hl.on("hyprland.start", function()
	for _, cmd in ipairs(autoexec) do
		hl.exec_cmd(cmd)
	end
end)

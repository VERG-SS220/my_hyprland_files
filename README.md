# my_hyprland_files

Hyprland desktop configuration — Hyprland itself (Lua config), Waybar, hyprpaper,
mako and wlogout.

Everything in this repo is the **source of truth**: the real files live here and
`~/.config` holds symlinks pointing back at them. Editing either path is editing
the same file, so a `git status` in this directory always reflects the running
desktop.

---

## Prerequisites

### Required — the desktop will not come up without these

| Package | Version tested | Why it is needed |
| --- | --- | --- |
| `hyprland` | 0.56.2 | The compositor. These files use the **Lua** config backend (`hl.bind`, `hl.config`, `hl.monitor`, `hl.curve` springs, `hl.gesture`). An older Hyprland that only parses `hyprland.conf` will ignore all of it. |
| `hyprpaper` | 0.8.4 | Wallpapers. `hyprpaper.lua` drives it over IPC with `hyprctl hyprpaper wallpaper`. Note that 0.8.x rejects `preload`/`unload` as invalid requests — the config deliberately does not send them. |
| `hyprlauncher` | 0.1.6 | App launcher, bound to `SUPER+R` and to the Arch button in Waybar. |
| `waybar` | 0.15.0 | Status bar. The config uses the `wlr/taskbar` module, so a build with wlroots protocol support is required. |
| `mako` | 1.11.0 | Notification daemon. `mako-config` uses the sectioned `[urgency=low|normal|critical]` syntax. |
| `wlogout` | 1.2.2 | Power menu (`SUPER+SHIFT+X`). **Its icon PNGs are a hard dependency of the styling** — `wlogout-style.css` loads `/usr/share/wlogout/icons/{reboot,shutdown,lock}.png` by absolute path. Without the package's icons the buttons render empty. |
| `ttf-jetbrains-mono-nerd` | 3.5.1 | Supplies the glyphs used in the bar — `󰣇` (Arch/launcher) and `⏻` (power). Any other Nerd Font works if you change `font-family` in `waybar-style.css`; a plain font shows tofu boxes. |

A working Wayland session underneath is assumed: `seatd`/`logind` for seat
access, and a GPU driver with functioning DRM + EGL. Hyprland aborts at startup
if EGL cannot be initialised (a common failure inside VMs on virtual GPU
drivers).

### Required by the keybinds in `hyprland.lua`

These are not needed to *start* the session, but the bound keys do nothing
without them:

| Package | Used by |
| --- | --- |
| `kitty` | `SUPER+Q` — terminal |
| `dolphin` | `SUPER+E` — file manager |
| `wireplumber` (`wpctl`) | `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` / `MicMute` |
| `brightnessctl` | `XF86MonBrightnessUp` / `Down` |
| `playerctl` | `XF86AudioNext` / `Prev` / `Play` / `Pause` |

### Autostarted at login

`autoexec.lua` launches these on `hyprland.start`. A missing one is logged and
skipped, it does not block the session:

`hyprpaper`, `waybar`, `mako`, `steam`, `chromium`

### Optional

| Package | Why |
| --- | --- |
| `nwg-displays` | Regenerates `monitors.lua`. That file is machine-generated — edit it through nwg-displays rather than by hand. |

---

## Hardware and environment assumptions

The configs are not display-agnostic. Adjust these before using them on another
machine:

- **Two 1920x1080@60 outputs, named `DP-2` (left, at `0x0`) and `DP-1` (right, at
  `1920x0`)** — `monitors.lua`. On different outputs Hyprland falls back to
  preferred modes and the wallpaper assignment silently misses.
- **Wallpaper images, not included in this repo** — `hyprpaper.lua` expects
  `~/Pictures/wp5995111-anime-city-4k-wallpapers.jpg` (DP-2) and
  `~/Pictures/thumb-1920-1348663.jpeg` (DP-1). Point the `wallpapers` table at
  your own files.
- **1920x1080 for the power menu geometry** — the round wlogout buttons come out
  circular only because the launch flags (`-b 3 -L 400 -R 400 -T 360 -B 360 -c 20`)
  make each grid cell square at that resolution. The arithmetic is written out in
  the comment at the top of `wlogout-style.css`; change resolution and both the
  flags and the CSS margins have to be re-balanced or the circles become ellipses.
  The flags live in two places that must stay in sync: the `SUPER+SHIFT+X` bind in
  `keybinds.lua` and the `custom/power` click action in `waybar-config.jsonc`.
- **Keyboard layout `us,ru`, switched with Caps Lock** — `hyprland.lua`
  (`kb_options = "grp:caps_toggle"`).

---

## File map

`hyprland.lua` is the entry point; Hyprland reads it from `~/.config/hypr/` and
it `require()`s the rest:

```
hyprland.lua
├── require("monitors")          -> monitors.lua
├── require("func/autoexec")     -> autoexec.lua
├── require("func/hyprpaper")    -> hyprpaper.lua
├── require("func/keybinds")     -> keybinds.lua
└── require("func/windowrules")  -> windowrules.lua
```

| Repo file | Symlinked to |
| --- | --- |
| `hyprland.lua` | `~/.config/hypr/hyprland.lua` |
| `monitors.lua` | `~/.config/hypr/monitors.lua` |
| `autoexec.lua` | `~/.config/hypr/func/autoexec.lua` |
| `hyprpaper.lua` | `~/.config/hypr/func/hyprpaper.lua` |
| `keybinds.lua` | `~/.config/hypr/func/keybinds.lua` |
| `windowrules.lua` | `~/.config/hypr/func/windowrules.lua` |
| `waybar-config.jsonc` | `~/.config/waybar/config.jsonc` |
| `waybar-style.css` | `~/.config/waybar/style.css` |
| `waybar-scratch.sh` | `~/.config/waybar/scripts/scratch.sh` |
| `mako-config` | `~/.config/mako/config` |
| `wlogout-layout` | `~/.config/wlogout/layout` |
| `wlogout-style.css` | `~/.config/wlogout/style.css` |

`waybar-scratch.sh` is a stub for the free module next to the clock. It prints
`{"text":""}`, which keeps the module hidden; `waybar-config.jsonc` runs it every
5 seconds, so if the file is missing or not executable Waybar logs an exec error
on every tick.

`original_files/` holds the untouched upstream versions of files that were
modified, kept for reference only — nothing links to them.

---

## Installation

```sh
# Arch
sudo pacman -S hyprland hyprpaper waybar mako wlogout kitty dolphin \
               wireplumber brightnessctl playerctl ttf-jetbrains-mono-nerd
# hyprlauncher and nwg-displays: pacman if available on your setup, otherwise AUR

git clone https://github.com/VERG-SS220/my_hyprland_files ~/.hyprfiles
```

Then link the files into place (this **overwrites** any existing config at those
paths — back them up first):

```sh
cd ~/.hyprfiles
mkdir -p ~/.config/hypr/func ~/.config/waybar/scripts ~/.config/mako ~/.config/wlogout

ln -sf ~/.hyprfiles/hyprland.lua        ~/.config/hypr/hyprland.lua
ln -sf ~/.hyprfiles/monitors.lua        ~/.config/hypr/monitors.lua
ln -sf ~/.hyprfiles/autoexec.lua        ~/.config/hypr/func/autoexec.lua
ln -sf ~/.hyprfiles/hyprpaper.lua       ~/.config/hypr/func/hyprpaper.lua
ln -sf ~/.hyprfiles/keybinds.lua        ~/.config/hypr/func/keybinds.lua
ln -sf ~/.hyprfiles/windowrules.lua     ~/.config/hypr/func/windowrules.lua
ln -sf ~/.hyprfiles/waybar-config.jsonc ~/.config/waybar/config.jsonc
ln -sf ~/.hyprfiles/waybar-style.css    ~/.config/waybar/style.css
ln -sf ~/.hyprfiles/waybar-scratch.sh   ~/.config/waybar/scripts/scratch.sh
ln -sf ~/.hyprfiles/mako-config         ~/.config/mako/config
ln -sf ~/.hyprfiles/wlogout-layout      ~/.config/wlogout/layout
ln -sf ~/.hyprfiles/wlogout-style.css   ~/.config/wlogout/style.css
```

Adjust `monitors.lua` and the wallpaper paths in `hyprpaper.lua` for your
hardware, then start Hyprland.

---

## Keybinds

From `keybinds.lua`:

| Bind | Action |
| --- | --- |
| `SUPER+R` | hyprlauncher |
| `SUPER+SHIFT+X` | wlogout power menu (Restart / Shutdown / Lock) |

The rest — `SUPER+Q` terminal, `SUPER+C` close, `SUPER+E` files, `SUPER+V`
float, `SUPER+1..0` workspaces, `SUPER+S` scratchpad, drag/resize with
`SUPER`+mouse, and the media keys — are defined in `hyprland.lua`.

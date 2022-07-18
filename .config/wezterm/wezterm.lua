local wezterm = require 'wezterm'
local act = wezterm.action

return {
  enable_wayland = false, -- temporary for working clipboard between two wezterm instances in linux
  font = wezterm.font("Iosevka Term", {weight="Medium", stretch="Expanded"}),
  font_size = 13,
  font_dirs = {"fonts"},
  font_locator = "ConfigDirsOnly",
  color_scheme = "Solarized Dark Higher Contrast",
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  window_decorations = "RESIZE",
  enable_tab_bar = false,
  keys = {
    {key="U", mods="CTRL", action=act.ScrollByPage(-0.5)},
    {key="D", mods="CTRL", action=act.ScrollByPage(0.5)},
    {key="K", mods="CTRL", action=act.ScrollByLine(-1)},
    {key="J", mods="CTRL", action=act.ScrollByLine(1)},
    {key="E", mods="CTRL",
     action=wezterm.action.QuickSelectArgs{
         label = "open url",
         patterns={
            "https?://\\S+"
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info("opening: " .. url)
            wezterm.open_with(url)
         end)
       }
     },
  },
  default_prog = {"C:/Program Files/Git/bin/bash.exe", "-i", "-l"},
}

-- Scrollback mode: Control+Shift+F
-- Quick select mode: Control+Shift+Space
-- Copy mode: Control+Shift+X
-- Font from ttf-iosevka-term-15.6.0.zip

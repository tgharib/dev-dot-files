local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
  check_for_updates = false,
  -- Font from ttf-iosevka-term-15.6.0.zip
  font = wezterm.font("Iosevka Term", {weight="Medium", stretch="Expanded"}),
  font_size = 13,
  font_dirs = {"fonts"},
  font_locator = "ConfigDirsOnly",
  color_scheme = "tokyonight_night",
  window_padding = {left=0, right=0, top=0, bottom=0},
  window_decorations = "RESIZE",
  enable_tab_bar = false,
  keys = {
    {key="U",mods="CTRL",action=act.ScrollByPage(-0.5)},
    {key="D",mods="CTRL",action=act.ScrollByPage(0.5)},
    {key="K",mods="CTRL",action=act.ScrollByLine(-1)},
    {key="J",mods="CTRL",action=act.ScrollByLine(1)},
    {key="E", mods="CTRL", -- open url
      action=wezterm.action.QuickSelectArgs{
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
    {key="P",mods="CTRL",action=act.QuickSelect,}, -- select path
    {key="L",mods="CTRL",action=act.QuickSelectArgs{patterns={"^.+$"},},}, -- select line
    {key="S",mods="CTRL",action=act.Search{Regex="",},}, -- search mode
    {key="G",mods="CTRL",action=act.ActivateCopyMode}, -- copy mode
  },
  key_tables = {
    search_mode = {
      {key="Escape",mods='NONE',action=act.Multiple{act.CopyMode'Close',act.CopyMode'ClearPattern'}},
      {key="Enter",mods='NONE',action=act.Multiple{act.CopyTo'Clipboard',act.CopyMode'Close',act.CopyMode'ClearPattern'}},
      {key="p",mods='CTRL',action=act.CopyMode'PriorMatch'},
      {key="n",mods='CTRL',action=act.CopyMode'NextMatch'},
      {key="r",mods='CTRL',action=act.CopyMode'CycleMatchType'},
      {key="u",mods='CTRL',action=act.CopyMode'ClearPattern'},
    },
  },
  -- performance
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  default_prog = {"C:/Users/tahag_science/scoop/apps/git/current/bin/bash.exe", "-i", "-l"},
}

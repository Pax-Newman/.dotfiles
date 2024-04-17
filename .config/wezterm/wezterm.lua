local wez = require("wezterm")
local config = wez.config_builder()
local act = wez.action

---- Layout and Aesthetics

-- Font settings
config.font = wez.font("CaskaydiaCove Nerd Font")
config.font_size = 11.0

config.color_scheme = "rose-pine"

-- Leave inactive panes at full brightness
config.inactive_pane_hsb = {
   saturation = 1.0,
   brightness = 1.0,
}

-- Hide tab bar and window padding
config.enable_tab_bar = false
config.window_padding = {
   left = 0,
   right = 0,
   top = 0,
   bottom = 0,
}

---- Keymaps

config.keys = {

   ---- Move between panes
   {
      key = "l",
      mods = "SUPER",
      action = act.ActivatePaneDirection("Right"),
   },
   {
      key = "h",
      mods = "SUPER",
      action = act.ActivatePaneDirection("Left"),
   },
   {
      key = "k",
      mods = "SUPER",
      action = act.ActivatePaneDirection("Up"),
   },
   {
      key = "j",
      mods = "SUPER",
      action = act.ActivatePaneDirection("Down"),
   },

   ---- Resize panes
   {
      key = "H",
      mods = "SUPER",
      action = act.AdjustPaneSize({ "Left", 3 }),
   },
   {
      key = "J",
      mods = "SUPER",
      action = act.AdjustPaneSize({ "Down", 3 }),
   },
   {
      key = "K",
      mods = "SUPER",
      action = act.AdjustPaneSize({ "Up", 3 }),
   },
   {
      key = "L",
      mods = "SUPER",
      action = act.AdjustPaneSize({ "Right", 3 }),
   },

   ---- Split panes
   {
      key = "\\",
      mods = "SUPER",
      action = act.SplitHorizontal({}),
   },
   {
      key = "-",
      mods = "SUPER",
      action = act.SplitVertical({}),
   },

   ---- Close pane
   {
      key = "w",
      mods = "SUPER",
      action = act.CloseCurrentPane({ confirm = true }),
   },

   ---- Move between tabs
   { key = "LeftArrow", mods = "SUPER", action = act.ActivateTabRelative(-1) },
   { key = "RightArrow", mods = "SUPER", action = act.ActivateTabRelative(1) },

   ---- Change font size
   {
      key = "+",
      mods = "SUPER",
      action = act.IncreaseFontSize,
   },
   {
      key = "_",
      mods = "SUPER",
      action = act.DecreaseFontSize,
   },
}

return config

local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Auto Reload
config.automatically_reload_config = true

-- Audio
config.audible_bell = 'SystemBeep'

-- Color
config.color_scheme = 'Tokyo Night'

-- Window
config.initial_rows = 40
config.initial_cols = 120
config.macos_window_background_blur = 20
config.window_background_opacity = 0.8
config.text_background_opacity = 0.95
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.45,
}
config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 6,
}
config.window_decorations = 'RESIZE'
config.window_frame = {
  inactive_titlebar_bg = 'none',
  active_titlebar_bg = 'none',
}

-- Tab
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false

-- Font
config.font = wezterm.font_with_fallback({
  'JetBrainsMono Nerd Font',
  'Hiragino Sans',
  'Apple Color Emoji',
})
config.font_size = 16
config.line_height = 1.10
config.use_ime = true

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- Render
config.freetype_load_flags = 'NO_HINTING'
config.freetype_render_target = 'HorizontalLcd'

-- Key bindings
config.keys = {
  -- macOS-style shortcut (kept intentionally)
  { key = 'Enter', mods = 'CMD', action = wezterm.action.ToggleFullScreen },

  -- Enter "pane mode" (a key-table) to operate on layout: split/move/resize + tab ops
  -- Press Ctrl-; to enter, then use the keys defined in `config.key_tables.pane`
  {
    key = ';',
    mods = 'CTRL',
    action = wezterm.action.ActivateKeyTable({ name = 'pane', one_shot = false }),
  },
}

config.key_tables = {
  pane = {
    -- Pane focus (vim-like)
    { key = 'h', action = wezterm.action.ActivatePaneDirection('Left') },
    { key = 'j', action = wezterm.action.ActivatePaneDirection('Down') },
    { key = 'k', action = wezterm.action.ActivatePaneDirection('Up') },
    { key = 'l', action = wezterm.action.ActivatePaneDirection('Right') },

    -- Split panes: v = horizontal, s = vertical
    { key = 'v', action = wezterm.action.SplitHorizontal({}) },
    { key = 's', action = wezterm.action.SplitVertical({}) },

    -- Close pane (confirm)
    { key = 'w', action = wezterm.action.CloseCurrentPane({ confirm = true }) },

    -- Resize pane (fine): H/J/K/L
    -- { key = 'H', action = wezterm.action.AdjustPaneSize({ 'Left', 5 }) },
    -- { key = 'J', action = wezterm.action.AdjustPaneSize({ 'Down', 5 }) },
    -- { key = 'K', action = wezterm.action.AdjustPaneSize({ 'Up', 5 }) },
    -- { key = 'L', action = wezterm.action.AdjustPaneSize({ 'Right', 5 }) },
    { key = 'h', mods = 'META', action = wezterm.action.AdjustPaneSize({ 'Left', 5 }) },
    { key = 'j', mods = 'META', action = wezterm.action.AdjustPaneSize({ 'Down', 5 }) },
    { key = 'k', mods = 'META', action = wezterm.action.AdjustPaneSize({ 'Up', 5 }) },
    { key = 'l', mods = 'META', action = wezterm.action.AdjustPaneSize({ 'Right', 5 }) },

    -- Tab operations (while in pane mode)
    { key = 't', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
    { key = 'n', action = wezterm.action.ActivateTabRelative(1) },
    { key = 'p', action = wezterm.action.ActivateTabRelative(-1) },
    { key = 'o', action = wezterm.action.ActivateLastTab },
    { key = 'x', action = wezterm.action.CloseCurrentTab({ confirm = true }) },

    -- Direct tab jump: 1..9 -> tab index 0..8 (1st tab = 1)
    { key = '1', action = wezterm.action.ActivateTab(0) },
    { key = '2', action = wezterm.action.ActivateTab(1) },
    { key = '3', action = wezterm.action.ActivateTab(2) },
    { key = '4', action = wezterm.action.ActivateTab(3) },
    { key = '5', action = wezterm.action.ActivateTab(4) },
    { key = '6', action = wezterm.action.ActivateTab(5) },
    { key = '7', action = wezterm.action.ActivateTab(6) },
    { key = '8', action = wezterm.action.ActivateTab(7) },
    { key = '9', action = wezterm.action.ActivateTab(8) },

    -- Exit pane mode
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'q', action = 'PopKeyTable' },
  },
}

-- Status: show the active key-table name on the right side of the tab bar
wezterm.on('update-right-status', function(window, _)
  local mode = window:active_key_table()
  if mode then
    window:set_right_status(wezterm.format({
      { Attribute = { Intensity = 'Bold' } },
      { Foreground = { Color = '#7aa2f7' } },
      { Text = '  [' .. string.upper(mode) .. ']  ' },
    }))
  else
    window:set_right_status('')
  end
end)

return config

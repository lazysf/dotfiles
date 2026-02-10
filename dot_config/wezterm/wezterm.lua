local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- OS detection
local target = wezterm.target_triple or ''
local is_windows = target:find('windows') ~= nil
local is_macos = target:find('darwin') ~= nil

-- macOS-first defaults
local primary_font = 'JetBrainsMono Nerd Font'
local sans_font = 'Hiragino Sans'
local emoji_font = 'Apple Color Emoji'
local font_size = 16
local line_height = 1.06
local fullscreen_mods = 'CMD'
local resize_mods = 'META'
local default_shell = os.getenv('SHELL') or '/bin/zsh'
local default_prog = { default_shell, '-l' }

-- Windows overrides
if is_windows then
  sans_font = 'Yu Gothic UI'
  emoji_font = 'Segoe UI Emoji'
  font_size = 12
  line_height = 1.03
  fullscreen_mods = 'ALT'
  resize_mods = 'ALT'
  default_prog = { 'pwsh.exe', '-NoLogo' }
end

-- Auto Reload
config.automatically_reload_config = true

-- Audio
config.audible_bell = 'SystemBeep'

-- Shell
config.default_prog = default_prog

-- Color
config.color_scheme = 'Tokyo Night'

-- Window
config.initial_rows = 40
config.initial_cols = 120
if is_macos then
  config.macos_window_background_blur = 20
end
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
  primary_font,
  sans_font,
  emoji_font,
})
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = font_size
config.line_height = line_height
config.use_ime = true

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- Render
config.freetype_load_flags = 'NO_HINTING'
config.freetype_render_target = 'HorizontalLcd'

-- Key bindings
config.keys = {
  { key = 'Enter', mods = fullscreen_mods, action = wezterm.action.ToggleFullScreen },

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

    -- Resize pane (fine): h/j/k/l
    { key = 'h', mods = resize_mods, action = wezterm.action.AdjustPaneSize({ 'Left', 5 }) },
    { key = 'j', mods = resize_mods, action = wezterm.action.AdjustPaneSize({ 'Down', 5 }) },
    { key = 'k', mods = resize_mods, action = wezterm.action.AdjustPaneSize({ 'Up', 5 }) },
    { key = 'l', mods = resize_mods, action = wezterm.action.AdjustPaneSize({ 'Right', 5 }) },

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

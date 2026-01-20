-- [[ SETTINGS ]]
-- Centralized configuration for Neovim
local settings = {}

-- [[ NAMESPACE ]]
-- Available namespaces
-- Note: We use dot notation here.
-- "settings.namespace" is safer than settings["namespace"] regarding variable scope.
---@type table<string, boolean>
settings.namespace = {
  [""] = true,
  ["free"] = true,
  ["bly"] = true,
  ["lazya"] = true,
}

-- Enable namespace isolation
-- Valid options: true, false
---@type boolean
settings.enable_namespace = true

-- Active namespace
-- Valid options: "free", "bly", "lazya", ""
---@type string
settings.active_namespace = "bly"

-- [[ USER ]]
-- Active user profile
-- Valid options: "dev", "admin", "noconfig"
---@type string
settings.active_user = "dev"

-- Enable Lazyvim plugins
-- Valid options: true, false
---@type boolean
settings.enable_lazyvim_plugins = false

-- Enable noconfig Lazyvim plugins
-- Valid options: true, false
---@type boolean
settings.enable_noconfig_lazyvim_plugins = false

-- [[ VIM OPTIONS ]]
-- Mapleader key
-- Valid options: string
---@type string
settings.mapleader = " "

-- Maplocalleader key
-- Valid options: string
---@type string
settings.maplocalleader = " "

-- Enable line numbers
-- Valid options: true, false
---@type boolean
settings.number = true

-- Enable relative line numbers
-- Valid options: true, false
---@type boolean
settings.relative_number = true

-- Mouse support
-- Valid options: "a", "n", "v", "c", "i", etc. (see :h mouse)
---@type string
settings.mouse = "nv"

-- Enable background
-- Valid options: "dark", "light"
---@type "dark"|"light"
settings.background = "dark"

-- Tab line visibility
-- Valid options: 0 (never), 1 (if >1 tab), 2 (always)
---@type integer
settings.showtabline = 2

-- Highlight current column
-- Valid options: true, false
---@type boolean
settings.cursorcolumn = false

-- Enable listchars
-- Valid options: true, false
---@type boolean
settings.list = false

-- Listchars configuration
-- Valid options: table
---@type table
settings.listchars = {
  eol = "⤶",
  tab = ">.",
  trail = "~",
  extends = "◀",
  precedes = "▶",
}

-- Grep format string
-- Valid options: string
---@type string
settings.grepformat = "%f:%l:%c:%m"

-- Grep program
-- Valid options: string
---@type string
settings.grepprg = "rg --hidden --vimgrep --smart-case --"

-- Verbose mode
-- Valid options: true, false
---@type boolean
settings.verbose = false

-- Session options
-- Valid options: table of strings
---@type table
settings.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
}

-- [[ COLORSCHEMES ]]
-- Enable colorscheme support
-- Valid options: true, false
---@type boolean
settings.enable_colorschemes = true

-- Enable Catppuccin
-- Valid options: true, false
---@type boolean
settings.enable_catppuccin = true

-- Enable TokyoNight
-- Valid options: true, false
---@type boolean
settings.enable_tokyonight = true

-- Enable Kanagawa
-- Valid options: true, false
---@type boolean
settings.enable_kanagawa = true

-- Enable Nightfox
-- Valid options: true, false
---@type boolean
settings.enable_nightfox = true

-- Enable Gruvbox
-- Valid options: true, false
---@type boolean
settings.enable_gruvbox = true

-- Enable OneDark Pro
-- Valid options: true, false
---@type boolean
settings.enable_onedark_pro = true

-- Enable Monokai Pro
-- Valid options: true, false
---@type boolean
settings.enable_monokai_pro = true

-- Enable Dracula
-- Valid options: true, false
---@type boolean
settings.enable_dracula = true

-- Enable Nightfly
-- Valid options: true, false
---@type boolean
settings.enable_nightfly = true

-- Enable Cyberdream
-- Valid options: true, false
---@type boolean
settings.enable_cyberdream = true

-- Enable Night Owl
-- Valid options: true, false
---@type boolean
settings.enable_night_owl = true

-- Enable Solarized Ozaka
-- Valid options: true, false
---@type boolean
settings.enable_solarized_ozaka = true

-- Enable Zenbones
-- Valid options: true, false
---@type boolean
settings.enable_zenbones = true

-- Enable Yorumi
-- Valid options: true, false
---@type boolean
settings.enable_yorumi = true

-- Enable Shadow
-- Valid options: true, false
---@type boolean
settings.enable_shadow = true

-- Active colorscheme name
-- Valid options: string (theme name)
---@type string
settings.active_colorscheme = "tokyonight"

-- Active colorscheme theme variant
-- Valid options: string
---@type string
settings.active_colorscheme_theme = "tokyonight-night"

-- [[ SEPARATORS ]]
-- Lualine left separator
-- Valid options: string
---@type string
settings.section_separators_left = ""

-- Lualine right separator
-- Valid options: string
---@type string
settings.section_separators_right = ""

-- Lualine left component separator
-- Valid options: string
---@type string
settings.component_separators_left = ""

-- Lualine right component separator
-- Valid options: string
---@type string
settings.component_separators_right = ""

-- [[ PLUGINS ]]
-- Enable Conform (Formatter)
-- Valid options: true, false
---@type boolean
settings.enable_conform = true

-- Enable Dressing (UI)
-- Valid options: true, false
---@type boolean
settings.enable_dressing = true

-- Session manager
-- Valid options: "persistence", "autossession", "none"
---@type string
settings.session_manager = "persistence"

-- File explorer
-- Valid options: "neo-tree", "nvim-tree", "none"
---@type string
settings.file_tree = "neo-tree"

-- Enable Noice (UI)
-- Valid options: true, false
---@type boolean
settings.enable_noice = true

-- Enable Surround
-- Valid options: true, false
---@type boolean
settings.enable_surround = true

-- Enable Telescope
-- Valid options: true, false
---@type boolean
settings.enable_telescope = true

-- Enable Telescope Themes
-- Valid options: true, false
---@type boolean
settings.enable_telescope_themes = true

-- Lualine separator style
-- Valid options: string
---@type string
settings.lualine_separator = "bubble"

-- Enable Statusline
-- Valid options: true, false
---@type boolean
settings.enable_statusline = true

-- Enable Fancy Lualine
-- Valid options: true, false
---@type boolean
settings.enable_fancy = false

-- Enable Colorizer (Filetype)
-- Valid options: true, false
---@type boolean
settings.enable_colorizer_ft = false

-- Colorizer mode
-- Valid options: "background", "foreground", "virtualtext"
---@type string
settings.enable_colorizer_mode = "virtualtext"

-- Colorizer virtualtext inline
-- Valid options: true, false
---@type boolean
settings.enable_colorizer_virtualtext_inline = true

-- Enable Awesome
-- Valid options: true, false
---@type boolean
settings.awesome_enabled = false

-- [[ TERMINAL ]]
-- Enable Toggleterm
-- Valid options: true, false
---@type boolean
settings.enable_toggleterm = true

-- Enable Floaterm
-- Valid options: true, false
---@type boolean
settings.enable_floaterm = true

-- Enable Ghostty support
-- Valid options: true, false
---@type boolean
settings.enable_ghostty = true

-- Enable Kitty support
-- Valid options: true, false
---@type boolean
settings.enable_kitty = false

-- Enable Alacritty support
-- Valid options: true, false
---@type boolean
settings.enable_alacritty = false

-- Enable Wezterm support
-- Valid options: true, false
---@type boolean
settings.enable_wezterm = false

-- [[ PROJECT ]]
-- Enable Project manager
-- Valid options: true, false
---@type boolean
settings.enable_project = true

-- [[ LSP SERVERS ]]
-- Enable CCLS
-- Valid options: true, false
---@type boolean
settings.enable_ccls = true

-- Enable Clangd
-- Valid options: true, false
---@type boolean
settings.enable_clangd = false

-- Typescript server strategy
-- Valid options: "tsserver", "tools", "none"
---@type string
settings.typescript_server = "tools"

-- Mason lock out
-- Valid options: true, false
---@type boolean
settings.enable_mason_lock_out = false

-- [[ DIAGNOSTICS ]]
-- Diagnostics display mode
-- Valid options: "none", "icons", "popup"
---@type string
settings.show_diagnostics = "popup"

-- Enable Treesitter context
-- Valid options: true, false
---@type boolean
settings.enable_treesitter_context = true

-- [[ CACHE & PERSISTENCE ]]
-- Cache directory configuration
-- Valid options: table
---@type table
settings.cache = {
  -- Required directories
  -- Valid options: string[]
  ---@type string[]
  required_dirs = {
    "session",
    "backup",
    "swap",
    "tags",
    "undo",
    "view",
  },
}

-- GUI settings for clients like `neovide` or `neovim-qt`.
-- NOTE: Only the following GUI options are supported; others will be ignored.
---@type { font_name: string, font_size: number }
settings["gui_config"] = {
  font_name = "JetBrainsMono Nerd Font",
  font_size = 12,
}

-- [[ DASHBOARD ]]
-- Set the dashboard startup image here.
-- Generate ASCII art with: https://github.com/TheZoraiz/ascii-image-converter
-- More info: https://github.com/ayamir/nvimdots/wiki/Issues#change-dashboard-startup-image
--
-- Path to the custom ASCII header file
-- Note: The file content is read by the plugin, not stored here.
-- Valid options: string (absolute or relative path)
---@type string
settings.dashboard_header_path = vim.fn.stdpath("config") .. "/static/header.cat"

return settings

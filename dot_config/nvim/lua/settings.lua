-- [[ SETTINGS ]]
-- Centralized configuration table for Neovim settings
local conf = {}

-- [[ NAMESPACE ]]
-- Namespace for isolation (Available: "free" | "bly" | "")
conf.enable_namespace = false
conf.namespace = "bly"

-- [[ USER ]]
-- Active user profile (Available: "dev" | "admin" | "noconfig")
conf.active_user = "dev"
conf.enable_lazyvim_plugins = false
conf.enable_noconfig_lazyvim_plugins = false

-- [[ VIM OPTIONS ]]
-- Leader keys configuration
conf.mapleader = " "
conf.maplocalleader = " "
-- Enable line numbers
conf.number = true
-- Enable relative line numbers
conf.relative_number = true
-- Enable mouse support (see :h mouse)
conf.mouse = "nv"
-- Tab line visibility: 0 = never, 1 = if >1 tab, 2 = always
conf.showtabline = 2
-- Highlight the current column
conf.cursorcolumn = false
-- Enable listchars to display invisible characters
conf.list = false
-- Define symbols for listchars
conf.listchars = {
	eol = "⤶",
	tab = ">.",
	trail = "~",
	extends = "◀",
	precedes = "▶",
}
-- Grep configuration (use ripgrep instead of grep)
conf.grepformat = "%f:%l:%c:%m"
conf.grepprg = "rg --hidden --vimgrep --smart-case --"
-- Verbose mode
conf.verbose = false
-- Session persistence options
conf.sessionoptions = {
	"buffers",
	"curdir",
	"tabpages",
	"winsize",
}

-- [[ COLORSCHEMES ]]
-- Enable colorscheme support
conf.enable_colorschemes = true
-- Individual theme toggles
conf.enable_catppuccin = true
conf.enable_tokyonight = true
conf.enable_kanagawa = true
conf.enable_nightfox = true
conf.enable_gruvbox = true
conf.enable_onedark_pro = true
conf.enable_monokai_pro = true
conf.enable_dracula = true
conf.enable_nightfly = true
conf.enable_cyberdream = true
conf.enable_night_owl = true
conf.enable_solarized_ozaka = true
conf.enable_zenbones = true
conf.enable_yorumi = true
conf.enable_shadow = true

-- Active theme settings
conf.active_colorscheme = "tokyonight"
conf.active_colorscheme_theme = "tokyonight-night"

-- [[ SEPARATORS ]]
-- Lualine/UI separators (Powerline style)
conf.section_separators_left = ""
conf.section_separators_right = ""
conf.component_separators_left = ""
conf.component_separators_right = ""

-- Alternative separators (Bubble style - Disabled)
-- conf.section_separators_left = ""
-- conf.section_separators_right = ""
-- conf.component_separators_left = ""
-- conf.component_separators_right = ""

-- [[ PLUGINS ]]
-- Formatters & Linters
conf.enable_conform = true
-- UI improvements
conf.enable_dressing = true
-- Session manager choice: persistence, autossession, or none
conf.session_manager = "persistence"
-- File explorer choice: neo-tree, nvim-tree, or none
conf.file_tree = "neo-tree"
-- UI replacement for messages, cmdline, and popupmenu
conf.enable_noice = true
-- Delimiter management
conf.enable_surround = true
-- Fuzzy finder
conf.enable_telescope = true
-- Telescope extension for themes
conf.enable_telescope_themes = true
-- Statusline configuration
conf.lualine_separator = "bubble"
conf.enable_statusline = true
conf.enable_fancy = false
-- Color highlighting
conf.enable_colorizer_ft = false
conf.enable_colorizer_mode = "virtualtext" -- background | foreground | virtualtext
conf.enable_colorizer_virtualtext_inline = true
-- Extra plugins
conf.awesome_enabled = false

-- [[ TERMINAL ]]
-- Terminal plugins
conf.enable_toggleterm = true
conf.enable_floaterm = true
-- Terminal emulator integration/support
conf.enable_ghostty = true
conf.enable_kitty = false
conf.enable_alacritty = false
conf.enable_wezterm = false

-- [[ PROJECT ]]
-- Enable project manager
conf.enable_project = true

-- [[ LSP SERVERS ]]
-- Refer to utils/tables/servers.lua for full list
-- C/C++ server selection (ccls or clangd)
-- Note: Tool must be installed and in PATH if enabled
conf.enable_ccls = true
conf.enable_clangd = false
-- Typescript server strategy: "tsserver", "tools", or "none"
conf.typescript_server = "tools"
-- Mason lock file location
conf.enable_mason_lock_out = false

-- [[ DIAGNOSTICS ]]
-- Diagnostic display mode: "none", "icons", or "popup"
-- "none": diagnostics disabled but underlined
-- "icons": only icon visible (use ',de' to see detail)
-- "popup": icon visible + hover popup
conf.show_diagnostics = "popup"
-- Enable Treesitter code context
conf.enable_treesitter_context = true

return conf

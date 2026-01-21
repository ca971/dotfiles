-- [[ OPTIONS ]]

-- [[ PATHS & PERSISTENCE ]]
-- Use Env.cache_dir to define absolute paths for temporary files.
-- These folders are automatically created by Env:ensure_directories()
local cache = Env.cache_dir

vim.opt.directory = cache .. "/swap"   -- Directory for swap files
vim.opt.undodir = cache .. "/undo"     -- Directory for undo files
vim.opt.backupdir = cache .. "/backup" -- Directory for backup files
vim.opt.viewdir = cache .. "/view"     -- Directory for view files (folds, etc.)
vim.opt.undofile = true                -- Enable persistent undo (undodir is set above)

-- [[ GENERAL ]]
-- Basic editor behavior and default settings
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.mouse = Env.settings.mouse                       -- Enable mouse support
vim.opt.title = true                                     -- Set window title to filename
vim.opt.completeopt = { "fuzzy", "menuone", "noselect" } -- Completion behavior

-- [[ PERFORMANCE & APPEARANCE ]]
-- UI and visual enhancements
vim.opt.termguicolors = true                          -- Enable 24-bit RGB colors
vim.opt.cursorline = true                             -- Highlight the current line
vim.opt.cursorcolumn = Env.settings.cursorcolumn      -- Highlight the current column
vim.opt.signcolumn = "yes:1"                          -- Reserve space for signs/gutter
vim.opt.number = Env.settings.number                  -- Print line numbers
vim.opt.relativenumber = Env.settings.relative_number -- Use relative line numbers
vim.opt.wrap = false                                  -- Disable line wrapping
vim.opt.scrolloff = 8                                 -- Keep 8 lines visible when scrolling
vim.opt.sidescrolloff = 8                             -- Keep 8 columns visible when scrolling
vim.opt.splitright = true                             -- Split vertical windows to the right
vim.opt.splitbelow = true                             -- Split horizontal windows below
vim.opt.updatetime = 250                              -- Faster completion (default is 4000ms)
vim.opt.timeout = true
vim.opt.timeoutlen = 300                              -- Time to wait for mapped sequence
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0                               -- No timeout for key codes (fast chords)
vim.opt.hidden = true                                 -- Enable modified buffers in background
vim.opt.showcmd = true                                -- Show command in status line
vim.opt.showmode = false                              -- Hide mode since we have a statusline
vim.opt.list = Env.settings.list                      -- Enable listchars to display invisible characters
vim.opt.listchars = Env.settings.listchars            -- Define symbols for listchars

-- [[ WINDOW ]]
-- Command window and status line behavior
vim.opt.cmdheight = 1 -- Height of command line
vim.opt.winblend = 0 -- Window transparency level
vim.opt.winminwidth = 10 -- Minimum window width
vim.opt.winwidth = 30 -- Default width for split windows
vim.opt.wrapscan = true -- Searches wrap around the end of the file
vim.opt.showbreak = "↳  " -- Show ... at the end of the file in wrap mode
vim.opt.pumheight = 15 -- Height of the popup menu
vim.opt.pumwidth = 10 -- Minimum width of the popup menu
vim.opt.laststatus = 3 -- Global statusline (2 = separate, 3 = global)
vim.opt.magic = true -- Enable regex magic patterns
vim.opt.ruler = true -- Show cursor line/column position
vim.opt.display = "lastline" -- Show last line in status line

-- [[ INDENTATION & TABS ]]
-- Configure indentation behavior (Spaces preferred)
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.tabstop = 2        -- Number of spaces per tab
vim.opt.shiftwidth = 2     -- Number of spaces for indent
vim.opt.softtabstop = 2    -- Number of spaces for tab key
vim.opt.shiftround = true  -- Round indent
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Maintain indent of previous line
vim.opt.smarttab = true    -- Smart tabbing at start of line
vim.opt.breakindent = true -- Enable break indent

-- [[ SEARCH ]]
-- Configure search behavior
vim.opt.ignorecase = true    -- Case insensitive search
vim.opt.smartcase = true     -- Case sensitive when uppercase present
vim.opt.inccommand = "split" -- Show preview for substitute commands
vim.opt.incsearch = true     -- Show search matches as you type
vim.opt.infercase = true     -- Case inference

-- [[ BACKUP ]]
-- Note: swapfile and backup are disabled via Security section below.
-- We keep undodir and undofile for persistent undo.
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.clipboard = "unnamedplus" -- System clipboard integration

-- [[ SECURITY ]]
-- Explicitly disable swap/backup via commands (Redundant but safe)
vim.cmd([[set noswapfile ]])
vim.cmd([[set nobackup ]])
vim.cmd([[set nowritebackup ]])

-- [[ SESSIONS ]]
-- Read session options from Settings
vim.opt.sessionoptions = Env.settings.sessionoptions

-- [[ COMMENTS BEHAVIOR ]]
-- Disable automatic insertion of comment leader on new lines
vim.cmd([[autocmd FileType * set formatoptions-=ro]])

-- [[ FOLDING ]]
-- Secure folding configuration using Lib helpers.
-- Logic: If Treesitter is loaded, use it. Otherwise, use standard indent.
-- We use Lib functions to keep options.lua clean and readable.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = Lib.get_fold_expr()
vim.opt.foldlevel = 99
vim.opt.foldcolumn = "0"

-- [[ SMART FOLDTEXT ]]
-- We use 'v:lua' to call a global function dynamically.
-- This allows the fold text content to be calculated on the fly.
vim.opt.foldtext = "v:lua _G.Lib.get_fold_text()"

-- [[ FONTS & ICONS ]]
-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ ADVANCED UI ]]
-- Netrw liststyle configuration
-- See: https://medium.com/usevim/the-netrw-style-options-3be91d42456
vim.g.netrw_liststyle = 3

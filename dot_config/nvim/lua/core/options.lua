-- [[ GENERAL ]]
-- Basic editor behavior and default settings
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.title = true -- Set window title to filename
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Completion behavior

-- [[ PERFORMANCE & APPEARANCE ]]
-- UI and visual enhancements
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.cursorline = true -- Highlight the current line
vim.opt.cursorcolumn = true -- Highlight the current column
vim.opt.signcolumn = "yes:1" -- Reserve space for signs/gutter
vim.opt.number = true -- Print line numbers
vim.opt.relativenumber = true -- Use relative line numbers
vim.opt.wrap = false -- Disable line wrapping
vim.opt.scrolloff = 8 -- Keep 8 lines visible when scrolling
vim.opt.sidescrolloff = 8 -- Keep 8 columns visible when scrolling
vim.opt.splitright = true -- Split vertical windows to the right
vim.opt.splitbelow = true -- Split horizontal windows below
vim.opt.updatetime = 300 -- Faster completion (default is 4000ms)
vim.opt.timeoutlen = 500 -- Time to wait for mapped sequence
vim.opt.hidden = true -- Enable modified buffers in background
vim.opt.showcmd = true -- Show command in status line
vim.opt.showmode = false -- Hide mode since we have a statusline
vim.opt.list = false -- Disable listchars by default
vim.opt.listchars = "eol:.,tab:>-,trail:~,extends:>,precedes:<"

-- [[ INDENTATION & TABS ]]
-- Configure indentation behavior (Spaces preferred)
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 2 -- Number of spaces per tab
vim.opt.shiftwidth = 2 -- Number of spaces for indent
vim.opt.softtabstop = 2 -- Number of spaces for tab key
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true -- Maintain indent of previous line
vim.opt.smarttab = true -- Smart tabbing at start of line

-- [[ SEARCH ]]
-- Configure search behavior
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive when uppercase present
vim.opt.inccommand = "split" -- Show preview for substitute commands
vim.opt.incsearch = true -- Show search matches as you type

-- [[ BACKUP ]]
-- Configure swap, undo, and clipboard
vim.opt.swapfile = false -- Disable swap files
vim.opt.backup = false -- Disable backup files
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir" -- Undo directory
vim.opt.undofile = true -- Enable persistent undo
vim.opt.clipboard = "unnamedplus" -- System clipboard integration

-- [[ SECURITY ]]
-- Explicitly disable swap/backup via commands (Redundant but safe)
vim.cmd([[set noswapfile ]])
vim.cmd([[set nobackup ]])
vim.cmd([[set nowritebackup ]])

-- [[ COMMENTS BEHAVIOR ]]
-- Disable automatic insertion of comment leader on new lines
vim.cmd([[autocmd FileType * set formatoptions-=ro]])

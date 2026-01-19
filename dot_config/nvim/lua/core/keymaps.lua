-- [[ GLOBAL KEYMAPS ]]
-- Default options for keymaps (noremap = do not recurse, silent = no feedback)
local opts = { noremap = true, silent = true }

-- [[ LEADER KEY ]]
-- Deactivate <Space> default behavior (Reserved for leader)
-- vim.keymap.set("", "<Space>", "<Nop>", opts)

-- [[ WINDOW NAVIGATION ]]
-- Navigate between windows using Ctrl (HJKL)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Navigate using Arrow keys (Mapped to window movement)
vim.keymap.set("n", "<RIGHT>", "<C-w>h", opts)
vim.keymap.set("n", "<LEFT>", "<C-w>j", opts)
vim.keymap.set("n", "<UP>", "<C-w>k", opts)
vim.keymap.set("n", "<DOWN>", "<C-w>l", opts)

-- [[ WINDOW RESIZING ]]
-- Resize windows using Alt + Arrows
vim.keymap.set("n", "<A-Up>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<A-Down>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<A-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<A-Right>", ":vertical resize +2<CR>", opts)

-- [[ WINDOW SPLITS ]]
-- Split windows vertically and horizontally
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", opts)
vim.keymap.set("n", "<leader>sh", ":split<CR>", opts)

-- [[ BUFFER MANAGEMENT ]]
-- Navigate buffers (Previous/Next)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", opts) -- Delete current buffer

-- [[ DISABLES ]]
-- Disable Ex-mode (Q) to prevent accidental mode switch
vim.keymap.set("n", "Q", "<nop>")

-- [[ TEXT MANIPULATION ]]
-- Better indenting (Visual mode) - Keeps selection after indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Move selected text lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- [[ SEARCH ]]
-- Center screen after search jumps
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

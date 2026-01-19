-- [[ AUTOCMDS ]]
-- Define automatic commands for editor behavior
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- [[ GENERAL AUTOCMDS ]]
-- Create a general autocommand group
local auto_group = augroup("Auto", { clear = true })

-- [[ YANK HIGHLIGHTING ]]
-- Highlight yanked text for visual feedback
autocmd("TextYankPost", {
	group = auto_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 40 })
	end,
})

-- [[ CURSOR POSITION ]]
-- Restore cursor position when reopening a file
autocmd("BufReadPost", {
	group = auto_group,
	pattern = "*",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- [[ FORMATTING ]]
-- Format code automatically before saving using LSP
autocmd("BufWritePre", {
	group = auto_group,
	pattern = "*",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- [[ UI TOGGLING ]]
-- Dynamically show/hide UI elements (Statusline/Tabline) for clean startup
local ui_group = augroup("UIControl", { clear = true })

-- Hide UI elements on the Dashboard (Snacks.nvim)
autocmd("FileType", {
	pattern = "snacks_dashboard", -- snacks.nvim uses this filetype by default
	group = ui_group,
	callback = function()
		vim.cmd("set laststatus=0") -- Hide statusline
		vim.cmd("set showtabline=0") -- Hide bufferline
	end,
})

-- Restore UI elements when entering other buffers
autocmd("BufEnter", {
	pattern = "*",
	group = ui_group,
	callback = function()
		-- Ensure we are NOT on the dashboard
		if vim.bo.filetype ~= "snacks_dashboard" then
			vim.cmd("set laststatus=3") -- Show global statusline
			vim.cmd("set showtabline=2") -- Show bufferline
		end
	end,
})

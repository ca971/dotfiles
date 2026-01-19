-- [[ BOOTSTRAP LAZY.NVIM ]]
-- Path to the lazy.nvim plugin directory
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Auto-install lazy.nvim if not found
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

	-- Handle git clone errors
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- [[ USER CONFIGURATION ]]
-- Retrieve the active user profile
local active_user = Utils.tables.active_user or "noconfig"

-- [[ LAZY CONFIGURATION ]]
-- Initialize the plugin manager
require("lazy").setup({
	-- Load plugins based on the active user profile
	spec = Utils.plugins.get_active_user_plugins(active_user),
	defaults = {
		lazy = false, -- Disable lazy loading for custom plugins by default
		version = false, -- Always use the latest version
	},
	install = { colorscheme = { "tokyonight", "habamax" } }, -- Fallback colorschemes
	checker = { enabled = true, notify = false }, -- Periodically check for updates
	performance = {
		rtp = {
			-- Disable specific built-in plugins to improve startup time
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

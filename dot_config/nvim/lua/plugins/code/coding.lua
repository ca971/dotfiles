-- [[ SYNTAX HIGHLIGHTING (Treesitter) ]]
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		opts = function()
			-- Load language lists from the centralized server table
			local Servers = require("utils.tables.servers")

			return {
				-- [[ IMMEDIATE INSTALLATION ]]
				-- Install essential parsers on startup
				ensure_installed = Servers.treesitter_ensure_installed,

				-- [[ LAZY / ON-DEMAND INSTALLATION ]]
				-- Automatically install missing parsers when opening a file
				-- This mimics the behavior of mason-lspconfig's 'automatic_installation'
				auto_install = true,

				-- Use asynchronous installation to prevent blocking startup
				sync_install = false,

				-- [[ PARSING CONFIGURATION ]]
				highlight = {
					enable = true,
					-- Disable this if you experience performance issues or flickering
					additional_vim_regex_highlighting = false,
				},

				indent = {
					enable = true,
				},
			}
		end,
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)
		end,
	},
}

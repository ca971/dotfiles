-- [[ LUA LANGUAGE SERVER CONFIGURATION ]]
-- Specific settings for the Lua language server (lua_ls)

-- Load shared configuration (on_attach, capabilities)
local Shared = require("plugins.code.lsp_config.lsp_shared")

return {
	-- Merge with shared configuration
	on_attach = Shared.on_attach,
	capabilities = Shared.capabilities,

	settings = {
		Lua = {
			diagnostics = {
				-- Define global variables to avoid "undefined global" warnings
				globals = { "vim", "Settings", "Utils" },
			},
			telemetry = { enable = false }, -- Disable telemetry
			workspace = {
				library = {
					-- Add Neovim runtime files to the workspace for autocomplete
					vim.env.VIMRUNTIME,
				},
			},
		},
	},
}

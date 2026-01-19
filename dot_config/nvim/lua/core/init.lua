-- [[ CORE INITIALIZATION ]]
-- Polyfill for vim.uv compatibility across Neovim versions
vim.uv = vim.uv or vim.loop

-- [[ GLOBAL VARIABLES ]]
-- Load global Settings table if not already cached
if not Settings then
	Settings = require("settings")
end

-- Load global Utils table if not already cached
if not Utils then
	Utils = require("utils")
end

-- Load global Shared LSP configuration if not already cached
if not Shared then
	Shared = require("plugins.code.lsp_config.lsp_shared")
end

-- [[ CORE MODULES ]]
-- Initialize editor options
require("core.options")

-- Initialize plugin manager
require("core.lazy")

-- Initialize global keymaps
require("core.keymaps")

-- Initialize autocommands
require("core.autocmds")

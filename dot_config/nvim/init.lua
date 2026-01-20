-- [[ INIT ]]
-- Entry point for the Neovim configuration.
-- Loads the core modules (settings, keymaps, lazy, etc.).

if not vim.g.vscode then
	require("core")
end

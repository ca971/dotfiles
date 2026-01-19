-- [[ LSP SHARED CONFIGURATION ]]
-- Common configuration for all LSP clients (Keymaps, Signs, Diagnostics)
local M = {}

-- [[ DIAGNOSTIC SIGNS ]]
-- Setup icons for diagnostic signs
local signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "" },
	{ name = "DiagnosticSignInfo", text = "" },
}
for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

-- [[ DIAGNOSTIC CONFIGURATION ]]
-- Configure global diagnostic behavior
vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	signs = { active = signs },
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- [[ ON_ATTACH FUNCTION ]]
-- Runs when an LSP attaches to a buffer
M.on_attach = function(client, bufnr)
	-- Exit if not a normal file (e.g., terminal, quickfix)
	if vim.bo[bufnr].buftype ~= "" then
		return
	end

	-- Helper to define buffer-local keymaps
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	-- [[ NAVIGATION ]]
	nmap("<leader>rn", vim.lsp.buf.rename, "[R]ename")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	-- [[ DOCUMENTATION ]]
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- [[ DIAGNOSTICS ]]
	nmap("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
	nmap("]d", vim.diagnostic.goto_next, "Next diagnostic")
	nmap("<leader>e", vim.diagnostic.open_float, "Open floating diagnostic")

	-- [[ POWER USER FEATURE ]]
	-- Enable Inlay Hints (Inline type information)
	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(bufnr, true)
	end
end

-- Note: Capabilities are handled in the main LSP plugin configuration
-- to ensure proper lazy-loading and dependency management.
return M

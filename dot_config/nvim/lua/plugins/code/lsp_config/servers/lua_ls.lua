-- [[ LUA LANGUAGE SERVER CONFIGURATION ]]
-- Specific settings for the Lua language server (lua_ls)

-- Load shared configuration (on_attach, capabilities)
local Lsp_shared = Env.lsp_shared

return {
  -- Merge with shared configuration
  on_attach = Lsp_shared.on_attach,
  capabilities = Lsp_shared.capabilities,

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

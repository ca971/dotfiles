-- [[ BOOTSTRAP LAZY.NVIM ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

  if vim.v.shell_error ~= 0 then
    Lib.fatal("Failed to clone lazy.nvim:\n" .. out)
  end
end

vim.opt.rtp:prepend(lazypath)

-- [[ LOAD UTILS (Secure) ]]
-- Since Env has already loaded utils safely via Lib, we can use Lib.tbl_get safely.
local active_user = Lib.tbl_get(Env.utils, "tables", "active_user")

-- [[ VALIDATION ]]
if not active_user then
  Lib.fatal("Failed to resolve 'active_user'. Check your settings and user tables.")
end

require("lazy").setup({
  spec = Env.utils.plugins.get_active_user_plugins(active_user),
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
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

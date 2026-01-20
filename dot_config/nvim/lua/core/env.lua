-- [[ ENVIRONMENT MANAGER ]]
-- Object-Oriented environment singleton (OS, Modules, Core Initialization)
local Env = {}

-- [[ METHOD: LOAD VARIABLES ]]
-- Detect OS and define system paths
function Env:load_variables()
  -- Get UV interface (OS abstraction)
  local uv = vim.uv or vim.loop
  local uname = uv.os_uname()
  local realpath = vim.uv.fs_realpath

  -- [[ OS DETECTION ]]
  self.is_windows = vim.fn.has("win32") == 1
  self.is_mac = vim.fn.has("mac") == 1
  self.is_linux = vim.fn.has("unix") == 1 and not self.is_mac

  -- [[ WSL DETECTION ]]
  if self.is_linux and uname.release:lower():find("microsoft") ~= nil then
    self.is_wsl = true
  else
    self.is_wsl = false
  end

  -- [[ PATH DEFINITIONS ]]
  -- Cross-platform Home directory detection
  self.home = self.is_windows and vim.env.USERPROFILE or vim.env.HOME

  self.data_dir = vim.fn.stdpath("data")   -- ~/.local/share/nvim
  self.cache_dir = vim.fn.stdpath("cache") -- ~/.cache/nvim

  -- Resolve absolute paths for config and modules
  self.vim_path = realpath(vim.fn.stdpath("config")) -- ~/.config/nvim
  self.modules_dir = self.vim_path .. "/modules"     -- ~/.config/nvim/modules
end

-- [[ METHOD: ENSURE DIRECTORIES ]]
-- Create required subdirectories in cache_dir if they don't exist.
-- Reads the list dynamically from Env.settings.cache (OOP: Data Source).
function Env:ensure_directories()
  -- Read the list from Settings using Lib.tbl_get for safety.
  -- If the path is nil (e.g., settings cache changed), defaults to empty.
  local required_dirs = Lib.tbl_get(self.settings, "cache", "required_dirs") or {}

  for _, dir_name in ipairs(required_dirs) do
    -- Construct full path
    local path = self.cache_dir .. "/" .. dir_name

    -- Check if directory already exists using UV
    local stat = vim.uv.fs_stat(path)

    -- If stat is nil, path does not exist
    if not stat then
      -- Use pcall to handle potential permission errors gracefully
      local success, err = pcall(vim.fn.mkdir, path, "p", "0755")

      if success then
        -- Optional: Log success for debugging
        -- Lib.notify("Created directory: " .. path, vim.log.levels.DEBUG)
      else
        -- Use Lib.notify to warn user if creation fails (e.g., permission denied)
        Lib.notify("Failed to create directory: " .. path, vim.log.levels.WARN)
      end
    end
  end
end

-- [[ METHOD: LOAD SETTINGS ]]
-- Load Settings first (Required to know leader key)
function Env:load_settings()
  self.settings = Lib.require_safe("settings")
end

-- [[ METHOD: SET LEADERS ]]
-- Define global and local leader keys using Settings.
-- CRITICAL: This must run BEFORE lazy.nvim is initialized to avoid warnings.
function Env:set_leaders()
  -- Fallback to space if settings are missing
  local mapleader = self.settings.mapleader or " "
  local maplocalleader = self.settings.maplocalleader or " "

  vim.g.mapleader = mapleader
  vim.g.maplocalleader = maplocalleader
end

-- [[ METHOD: LOAD UTILITIES ]]
-- Load Utils and Shared LSP configs
function Env:load_utilities()
  -- Utils library (tables, plugins, colorschemes)
  self.utils = Lib.require_safe("utils")

  -- Shared LSP configuration (keymaps, capabilities)
  self.lsp_shared = Lib.require_safe("plugins.code.lsp_config.lsp_shared")
end

-- [[ METHOD: LOAD CORE MODULES ]]
-- Initialize behavior modules (options, keymaps, autocmds, lazy)
function Env:load_core_modules()
  -- Initialize editor options
  -- Note: Leader is already set, so options.lua can skip redundant definitions
  require("core.options")

  -- Initialize plugin manager (Lazy needs leader key set)
  require("core.lazy")

  -- Initialize global keymaps
  require("core.keymaps")

  -- Initialize autocommands
  require("core.autocmds")
end

-- [[ METHOD: LOAD ALL ]]
-- Master method to initialize entire environment
-- The order here is CRITICAL: Variables -> Settings -> Leaders -> Utilities -> Core
function Env:load_all()
  self:load_variables()     -- 1. Load environment variables
  self:load_settings()      -- 2. Load Settings
  self:ensure_directories() -- 3.Ensure cache folders exist immediately
  self:set_leaders()        -- 4. Set Leader (BEFORE LAZY)
  self:load_utilities()     -- 5. Load Utils
  self:load_core_modules()  -- 6. Init Core (Lazy, Options, etc.)
end

return Env

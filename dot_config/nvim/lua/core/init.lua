-- [[ CORE INITIALIZATION ]]
-- Polyfill for vim.uv compatibility across Neovim versions
vim.uv = vim.uv or vim.loop

-- [[ GLOBAL LIBRARY ]]
-- Load Lib first to enable Safe Require and Error Handling globally
if not Lib then
  Lib = require("utils.lib")
end

-- [[ GLOBAL ENVIRONMENT ]]
-- Import Env object
if not Env then
  Env = require("core.env")
end


-- [[ METHOD: ENSURE DIRECTORIES ]]
-- Create required subdirectories in cache_dir if they don't exist.
-- Reads the list dynamically from Settings (OOP: Data Source).
function Env:ensure_directories()
  -- Read the list from the Settings object instead of hardcoding it here.
  -- If Settings.cache or required_dirs is missing, fallback to empty table.
  local raw_dirs = Lib.tbl_get(self.settings, "cache", "required_dirs")
  local required_dirs = raw_dirs or {}

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
        -- Use Lib.notify to warn user if creation fails
        Lib.notify("Failed to create directory: " .. path, vim.log.levels.WARN)
      end
    end
  end
end

-- [[ BOOTSTRAP ]]
-- Execute master loading method.
-- This triggers: Variable Detection -> Config Loading -> Core Module Init
Env:load_all()

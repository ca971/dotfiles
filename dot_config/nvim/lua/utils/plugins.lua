-- [[ UTILITIES PLUGINS MANAGER ]]
-- Object-Oriented plugin loader based on User Profile and Namespace
local M = {}

-- [[ METHOD: GET ACTIVE USER PLUGINS ]]
-- Main entry point for Lazy.nvim to generate plugin specifications.
-- @param active_user table: The user profile object (from utils/tables/users.lua)
function M.get_active_user_plugins(active_user)
  local specs = {}

  -- Retrieve active namespace from Env settings
  local namespace = Env.settings.enable_namespace and Env.settings.active_namespace or ""

  -- [[ HELPER: INJECT ]]
  -- Helper to add a plugin spec to the list
  local function inject(import_path)
    table.insert(specs, { import = import_path })
  end

  -- ==========================================
  -- 1. CORE PLUGINS (Universal Access)
  -- ==========================================
  -- Accessible to everyone, regardless of namespace or role.
  -- These are the baseline tools.
  inject("plugins")
  inject("plugins.themes")

  -- ==========================================
  -- 2. LAZyVIM (Optional Distro)
  -- ==========================================
  -- If enabled in settings, load the LazyVim distribution.
  if active_user.name:lower() ~= "noconfig" or Env.settings.enable_noconfig_lazyvim_plugins then
    if Env.settings.enable_lazyvim_plugins then
      -- Import core LazyVim configuration
      table.insert(specs, { "LazyVim/LazyVim", import = "lazyvim.plugins" })

      -- OPTIONAL: Import specific LazyVim Extras
      -- You can add specific extras here based on your needs.
      -- Example: inject("lazyvim.plugins.extras.lang.typescript")
    end
  end

  -- ==========================================
  -- 3. ROLE-BASED PLUGINS
  -- ==========================================
  -- Load plugins defined by the user's role (e.g., "dev", "admin").
  -- Accesses the 'plugins' list in the user profile (e.g., "code", "ai", "misc").
  if active_user.plugins then
    for _, group in ipairs(active_user.plugins) do
      -- Load group from plugins/{group}
      -- Example: "plugins/code"
      inject("plugins/" .. group)

      -- Special handling for "lang" group (Load sub-folders)
      if group == "lang" and active_user.lang then
        for _, lang in ipairs(active_user.lang) do
          inject("plugins/lang/" .. lang)
        end
      end
    end
  end

  -- ==========================================
  -- 4. NAMESPACE ISOLATION (Multi-User Setup)
  -- ==========================================
  -- If a namespace is active (e.g., "bly", "free", "lazya"),
  -- load user-specific overrides or additions located in plugins/_ns/{name}.
  if namespace ~= "" then
    -- Load namespace root (e.g., plugins/_ns.bly)
    inject("plugins._ns." .. namespace)

    -- Load role-based plugins inside the namespace folder
    -- This allows user "bly" with role "dev" to override/extend "code".
    -- Example: plugins/_ns.bly/code
    if active_user.plugins then
      for _, group in ipairs(active_user.plugins) do
        inject("plugins._ns." .. namespace .. "." .. group)
      end
    end

    -- Load language-specific plugins inside the namespace
    -- Example: plugins/_ns.bly.lang.python
    if active_user.lang then
      for _, lang in ipairs(active_user.lang) do
        inject("plugins._ns." .. namespace .. ".lang." .. lang)
      end
    end
  end

  return specs
end

return M

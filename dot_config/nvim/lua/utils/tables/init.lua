-- [[ UTILITIES TABLES INITIALIZATION ]]
-- Central module to load all data tables (Users, Colorschemes, Servers)
local M = {}

-- [[ SUBMODULES IMPORT ]]
-- Import user profiles and settings
M.users = require("utils.tables.users")
-- Import colorscheme definitions
M.colorschemes = require("utils.tables.colorschemes")
-- Import server configurations (LSP, Formatters, etc.)
M.servers = require("utils.tables.servers")

-- [[ ACTIVE USER RESOLUTION ]]
-- Resolve the active user configuration based on the settings table
M.active_user = M.users[M.users.active_user]

-- [[ ERROR HANDLING ]]
-- Critical check: Ensure the active user configuration exists
if not M.active_user then
	error("Error: Active user configuration is missing!")
end

return M

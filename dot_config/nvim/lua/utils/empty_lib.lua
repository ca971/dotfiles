-- [[ UTILITIES LIBRARY ]]
-- Object-Oriented helper library for error handling, modules, and tables.
-- This library is designed to be imported globally as `Lib`.
local Lib = {}

-- [[ 1. ERROR HANDLING ]]

-- Fatal error handler: Echo message to command line and exit.
-- Used when initialization fails and we must stop to prevent corruption.
function Lib.fatal(msg, exit_code)
    exit_code = exit_code or 1

    -- Format message for command line visibility
    vim.api.nvim_echo({
        { "[Lib] Fatal Error:\n", "ErrorMsg" },
        { msg, "WarningMsg" },
        { "\n\nPress any key to exit...", "Normal" },
    }, true, {})

    -- Pause so user can read the error
    vim.fn.getchar()

    -- Force exit
    os.exit(exit_code)
end

-- Safe wrapper for vim.notify that checks if UI is ready
function Lib.notify(msg, level)
    level = level or vim.log.levels.INFO
    -- Use pcall in case notify plugin isn't loaded yet
    pcall(vim.notify, msg, level)
end

-- [[ 2. MODULE LOADING ]]

-- Secure module loader.
-- Wraps pcall to catch missing dependencies immediately and stop execution.
-- @param module_name string: The path to the require (e.g., "settings")
-- @return table: The loaded module or exits on error.
function Lib.require_safe(module_name)
    local ok, module = pcall(require, module_name)

    if not ok then
        local error_msg = string.format(
            "Failed to load module '%s'.\n\nError details:\n%s",
            module_name,
            module
        )
        Lib.fatal(error_msg)
    end

    return module
end

-- Lazy module loader.
-- Returns nil instead of crashing if module doesn't exist.
-- Useful for optional features.
-- @param module_name string
-- @return table|nil
function Lib.require_lazy(module_name)
    local ok, module = pcall(require, module_name)
    if ok then return module end
    return nil
end

-- [[ 3. TABLE OPERATIONS ]]

-- Safe dot-notation access to nested tables.
-- Prevents "attempt to index a nil value" errors.
-- @param tbl table: Source table
-- @param ... string: Keys in order (e.g., "a", "b", "c")
-- @param any: Default value if path is nil
function Lib.tbl_get(tbl, ...)
    if tbl == nil then return nil end
    
    -- Traverse the path
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        tbl = tbl[key]
        if tbl == nil then return nil end
    end
    
    return tbl
end

-- Create a new class (OOP helper).
-- Uses setmetatable to implement instantiation and inheritance.
-- Usage: local MyClass = Lib.new_class({ init = function(self, ...) ... end })
-- local obj = MyClass:new()
function Lib.new_class(prototype)
    local class = {}
    class.__index = class

    -- Metatable allows calling the table as a function (The "constructor")
    setmetatable(class, {
        __call = function(cls, ...)
            local self = setmetatable({}, cls)
            -- Run the init function if it exists (Constructor)
            if cls.init then
                cls.init(self, ...)
            end
            return self
        end
    })

    -- Copy prototype methods to the class
    for key, value in pairs(prototype) do
        class[key] = value
    end

    return class
end

return Lib

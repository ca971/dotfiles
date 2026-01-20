-- [[ USER PROFILES ]]
-- Define environments for different users (dev, admin, etc.)
-- Each profile sets active plugins, languages, themes, and AI tool preferences.
return {
  -- [[ ACTIVE USER SELECTION ]]
  -- Select which user profile to load based on global settings
  active_user = Env.settings.active_user or "noconfig",

  -- [[ DEV USER ]]
  -- Full-featured development environment with coding, AI, and web support
  dev = {
    name = "Dev",
    namespace = Env.settings.active_namespace == "bly",
    -- Load specific plugin groups (directories)
    plugins = {
      "code",
      "ai",
      "misc",
    },
    -- Supported languages for this profile
    lang = { "python", "docker", "web" },
    -- Colorscheme preferences
    colorscheme = {
      name = Env.settings.active_colorscheme or "tokyonight",
      theme = Env.settings.active_colorscheme_theme or "tokyonight-night",
    },
    -- Override core configurations (options, keymaps, autocmds)
    bypass = {
      options = false,  -- Use global options
      keymaps = true,   -- Override global keymaps
      autocmds = false, -- Use global autocmds
    },
    -- AI Tools Configuration
    ai_tools = {
      enabled = true,
      -- Directories where AI tools are permitted to run
      public_dirs = {
        "~/.config/nvim",
        "~/projects/public",
        "~/dev",
        "~/dotfiles",
      },
      -- Toggle specific AI assistants
      tools = {
        copilot = {
          enabled = Env.settings.enable_ai and Env.settings.enable_copilot,
        },
        tabnine = {
          enabled = Env.settings.enable_ai and Env.settings.enable_tabnine,
        },
        chatgpt = {
          enabled = Env.settings.enable_ai and Env.settings.enable_chatgpt,
          allowed_commands = { "ExplainCode", "GenerateTests" },
        },
        gen = {
          enabled = Env.settings.enable_ai and Env.settings.enable_gen,
        },
        codeium = {
          enabled = Env.settings.enable_ai and Env.settings.enable_codeium,
        },
        continue = {
          enabled = Env.settings.enable_ai and Env.settings.enable_continue,
        },
        -- Add other AI tools here
      },
    },
  },

  -- [[ ADMIN USER ]]
  -- Lightweight administration environment
  admin = {
    name = "Admin",
    namespace = Env.settings.active_namespace == "free",
    plugins = {
      "misc",
    },
    lang = {
      "bash",
      "zsh",
      "python",
    },
    colorscheme = {
      name = Env.settings.active_colorscheme or "catppuccin",
      theme = Env.settings.active_colorscheme_theme or "catppuccin-macchiato",
    },
    bypass = {
      options = true,  -- Override global options
      keymaps = false, -- Use global keymaps
      autocmds = true, -- Override global autocmds
    },
    ai_tools = {
      enabled = false, -- All AI tools deactivated for this user
    },
  },

  -- [[ NO CONFIG USER ]]
  -- Fallback minimal configuration
  noconfig = {
    name = "Noconfig",
    namespace = Env.settings.active_namespace == "",
    plugins = {},
    lang = {},
    colorscheme = {
      name = Env.settings.active_colorscheme or "default",
    },
    bypass = {
      options = true,  -- Override global options
      keymaps = true,  -- Override global keymaps
      autocmds = true, -- Override global autocmds
    },
    ai_tools = {
      enabled = false,
    },
  },
}

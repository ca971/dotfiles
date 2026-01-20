-- [[ UI & EDITOR INTERFACE ]]
return {
  -- [[ STATUSLINE ]]
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy", -- Load after UI is available
    opts = {
      options = {
        theme = Env.settings.active_colorscheme,

        section_separators = {
          left = Env.settings.section_separators_left,
          right = Env.settings.section_separators_right,
        },

        component_separators = {
          left = Env.settings.component_separators_left,
          right = Env.settings.component_separators_right,
        },
      },
    },
  },

  -- [[ AUTO PAIRS ]]
  {
    "altermo/ultimate-autopair.nvim",
    event = { "InsertEnter" },
    config = true,
  },

  -- [[ AUTO TAG ]]
  {
    "windwp/nvim-ts-autotag",

    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },

  -- [[ COMMENTS ]]
  {
    "numToStr/Comment.nvim",

    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
          ---Line-comment toggle keymap
          line = "gcc",
          ---Block-comment toggle keymap
          block = "gbc",
        },
      })
    end,
  },

  -- [[ CONTEXT COMMENTSTRING ]]
  -- Provides context-aware comment strings (e.g., correct comment syntax in JSX/HTML)
  {
    "JoosepAlviste/nvim-ts-context-commentstring",

    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
  },

  -- [[ INDENTATION GUIDES ]]
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = { "│" },
      },
    },
    event = { "BufReadPost", "BufNewFile" },
  },

  -- [[ SMOOTH SCROLLING ]]
  {
    "declancm/cinnamon.nvim",
    event = "VeryLazy",
    opts = {
      keymaps = {
        basic = true, -- Enable for C-d, C-u, G, gg
        extra = false, -- Disable for w, b, etc (can be too slow)
        -- You can set 'extra' = true if you want everything smooth
      },
      options = {
        delay = 5, -- Delay in ms before scrolling (lower = more responsive, less smooth)
      },
    },
  },

  -- [[ NOTIFICATIONS ]]
  {
    "rcarriga/nvim-notify",
    lazy = false, -- Load immediately to capture startup errors
    config = function()
      require("notify").setup({
        background_colour = "#000000", -- Black background (or your theme background)
        timeout = 3000,            -- Display duration
        stages = "fade",           -- Animation style
      })
      vim.notify = require("notify") -- Override native vim.notify
    end,
  },

  -- [[ BUFFER TABS ]]
  {
    "akinsho/bufferline.nvim",
    version = "*", -- Keep stable version
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    opts = {
      options = {
        numbers = "none",          -- "ordinal" | "buffer_id" | "both"
        close_command = "bdelete! %d", -- Close correctly
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = { style = "icon", icon = "▎" },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        separator_style = "slant", -- "slant" | "padded_slant" | "slope" | "thick" | "thin" | { 'any', 'any' }
        offsets = {
          {
            filetype = "neo-tree", -- Adapt to Neo-tree if open
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  -- [[ ICONS ]]
  {
    "nvim-tree/nvim-web-devicons",
    opts = {},
  },

  -- [[ UI COMPONENT LIBRARY ]]
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },
}

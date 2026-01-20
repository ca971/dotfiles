-- [[ YANKY.NVIM ]]
-- Clipboard ring buffer integration with Telescope support
return {
  "gbprod/yanky.nvim",
  dependencies = {
    -- Required for Telescope integration
    { "nvim-telescope/telescope.nvim" },
  },
  event = "TextYankPost",
  keys = {
    -- Yank ring navigation
    { "y",     "<Plug>(YankyYank)",          mode = { "n", "x" },   desc = "Yank" },
    { "p",     "<Plug>(YankyPutAfter)",      mode = { "n", "x" },   desc = "Put" },
    { "P",     "<Plug>(YankyPutBefore)",     mode = { "n", "x" },   desc = "Put Before" },
    { "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Previous Yank" },
    { "<c-n>", "<Plug>(YankyNextEntry)",     desc = "Next Yank" },
  },
  opts = {
    ring = {
      -- Store the ring in Neovim's shada file (persistent)
      storage = "shada",
    },
    system_clipboard = {
      -- Sync the OS clipboard with the yanky ring
      sync_with_ring = true,
    },
  },
  config = function(_, opts)
    require("yanky").setup(opts)
  end,
}

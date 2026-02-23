-- reminds you of keymaps after having pressed the leader key for configured time
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 1000
  end,
  opts = {
    preset = "modern",
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}

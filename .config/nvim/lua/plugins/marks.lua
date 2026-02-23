-- better looking marks
return {
  "chentoast/marks.nvim",
  event = "VeryLazy",

  opts = {},

  config = function(_, opts)
    require("marks").setup(opts)

    -- highlight override
    vim.api.nvim_set_hl(0, "MarkSignHL", { fg = "#ff00ff" })
  end,
}


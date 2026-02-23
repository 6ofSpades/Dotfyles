return {
  "norcalli/nvim-colorizer.lua", -- Color highlighter
  config = function()
    -- Attaches to every FileType mode
    require 'colorizer'.setup()
  end,
}

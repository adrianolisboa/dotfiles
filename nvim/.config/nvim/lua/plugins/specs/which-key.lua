return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    window = {
      border = "single",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 2, 2, 2, 2 },
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "center",
    },
    ignore_missing = false,
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
    show_help = true,
    triggers = "auto",
    triggers_blacklist = {
      i = { "j", "k" },
      v = { "j", "k" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    
    -- Registrar grupos de teclas para melhor organização
    wk.register({
      ["<leader>"] = {
        f = { name = "Telescope/Find" },
        b = { name = "Buffer" },
        n = { name = "NvimTree" },
        t = { name = "Tests" },
        m = { name = "Format" },
        c = { name = "Copy Paths" },
        a = { name = "Avante/AI" },
      },
    })
  end,
}

require("ibl").setup({
  indent = {
    char = "▏", -- Character for indentation guides
  },
  scope = {
    enabled = true, -- Enable scope highlighting
    show_start = true,
    show_end = false,
    char = "┃", -- Character for scope guides
  },
  exclude = {
    filetypes = { "help", "dashboard", "NvimTree", "packer" }, -- Exclude certain file types
    buftypes = { "terminal", "nofile" }, -- Exclude certain buffer types
  },
})

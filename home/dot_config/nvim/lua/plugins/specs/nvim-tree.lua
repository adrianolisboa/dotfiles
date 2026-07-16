-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Nvim-tree configuration
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
    highlight_opened_files = "all", -- Highlight the opened file in the tree
  },
  filters = {
    dotfiles = false,
  },
  update_focused_file = {
    enable = true, -- Automatically focus on the current file
    update_cwd = true, -- Update the working directory to match the file's directory
  },
})

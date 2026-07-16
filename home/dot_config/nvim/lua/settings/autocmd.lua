-- Automatically resize splits when resizing Neovim
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
})

-- Highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Command to copy the full file path
vim.api.nvim_create_user_command('CopyFullPath', function()
  local filepath = vim.fn.expand('%:p') -- Get the full file path
  vim.fn.setreg('+', filepath) -- Copy to system clipboard
  print('Full file path copied to clipboard: ' .. filepath)
end, {})

-- Command to copy the file path relative to the current working directory
vim.api.nvim_create_user_command('CopyRelativePath', function()
  local filepath = vim.fn.expand('%:.') -- Get the relative file path
  vim.fn.setreg('+', filepath) -- Copy to system clipboard
  print('Relative file path copied to clipboard: ' .. filepath)
end, {})

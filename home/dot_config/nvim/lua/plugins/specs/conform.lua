require("conform").setup({
  formatters_by_ft = {
    elixir = { "mix" }, -- Use the mix formatter for Elixir files
    javascript = { "prettier" }, -- Example: Use Prettier for JavaScript
    typescript = { "prettier" },
    lua = { "stylua" }, -- Example: Use Stylua for Lua
    python = { "black" }, -- Example: Use Black for Python
  },
  format_on_save = {
    timeout_ms = 1000, -- Set a timeout for formatting
    lsp_fallback = true, -- Use LSP formatting if no Conform formatter is found
  },
})

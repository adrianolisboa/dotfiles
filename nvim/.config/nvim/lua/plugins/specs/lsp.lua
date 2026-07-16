-- LSP configuration (Neovim 0.11+ API: vim.lsp.config / vim.lsp.enable)

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Defaults applied to every server
vim.lsp.config("*", {
  capabilities = capabilities,
  root_markers = { ".git" },
})

-- Lexical (Elixir) — packaged build at ~/Projects/lexical
-- Refresh with: cd ~/Projects/lexical && mix package
vim.lsp.config("lexical", {
  cmd = { vim.fn.expand("~/Projects/lexical/_build/dev/package/lexical/bin/start_lexical.sh") },
  filetypes = { "elixir", "eelixir", "heex", "surface" },
  root_markers = { "mix.exs", ".git" },
})

-- Lua (for editing this nvim config). No-op if lua-language-server isn't installed.
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ "lexical", "lua_ls" })

-- Buffer-local keymaps when an LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local opts = function(desc)
      return { buffer = bufnr, desc = desc, noremap = true, silent = true }
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("LSP: Go to definition"))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("LSP: Go to declaration"))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("LSP: Go to implementation"))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("LSP: References"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("LSP: Hover docs"))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("LSP: Rename symbol"))
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("LSP: Code action"))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("LSP: Prev diagnostic"))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("LSP: Next diagnostic"))
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts("LSP: Show diagnostic"))
  end,
})

-- Diagnostic display
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

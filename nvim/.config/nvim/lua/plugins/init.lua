local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
  -- Manage lazy.nvim itself
  { "folke/lazy.nvim" },

  ------ UI Plugins ------
  -- Colorscheme (Solarized Dark)
  {
    "ishan9299/nvim-solarized-lua",
    lazy = false, -- Load during startup
    priority = 1000, -- Ensure it loads before other plugins
    config = function()
      vim.cmd [[ colorscheme solarized ]]
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Add all required parsers here
        ensure_installed = { "lua", "python", "javascript", "elixir", "eex", "heex" },

        -- Enable syntax highlighting
        highlight = {
          enable = true, -- Enable Treesitter-based highlighting
          additional_vim_regex_highlighting = false, -- Disable legacy Vim regex highlighting
        },

        -- Enable Treesitter-based indentation for supported languages
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("plugins.specs.nvim-tree")
    end,
  },

  -- Icons for file explorer
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      default = true, -- Enable default icons
    },
  },

  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },

  -- Telescope for fuzzy finding
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'CFLAGS=-march=native make' },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-github.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-fzf-native.nvim'
    },
    config = function()
      require("plugins.specs.telescope")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
      })
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("plugins.specs.bufferline")
    end,
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "v3.*",
    config = function()
      require("plugins.specs.indent_blankline")
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    config = function()
      require("plugins.specs.conform")
    end,
  },

  ------ A.I Plugins ------
  require("plugins.specs.claudecode"),

  ------ Programming Plugins ------
  -- test.nvim: Test runner
  {
    "vim-test/vim-test",
    config = function()
      require("plugins.specs.vim-test")
    end,
  },

  -- nvim-cmp: Auto-completion plugin
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.specs.gitsigns")
    end,
  },

  ------ Language Server Plugins ------
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.specs.lsp")
    end,
  },

  -- Which-key for displaying keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.specs.which-key")
    end,
  },
})

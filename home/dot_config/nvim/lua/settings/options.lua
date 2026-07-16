local g = vim.g
local o = vim.opt

--- Global options

-- Leader key
g.mapleader = " "

--- Local options

-- Indentation settings
o.expandtab = true            -- Use spaces instead of tabs
o.shiftwidth = 4              -- Indent size for auto-indent
o.tabstop = 4                 -- Tab size
o.smartindent = true          -- Enable smart indentation

-- Search settings
o.ignorecase = true           -- Ignore case in searches
o.smartcase = true            -- Case-sensitive when uppercase is used
o.hlsearch = true             -- Highlight search results
o.incsearch = true            -- Show search matches as you type

-- Enable mouse support
o.mouse = "a"

-- Use system clipboard
o.clipboard = "unnamedplus"

-- Visual settings
o.number = true               -- Show line numbers
o.relativenumber = true       -- Relative line numbers
o.termguicolors = true        -- Enable 24-bit RGB colors
o.splitright = true           -- Vertical splits go to the right
o.splitbelow = true           -- Horizontal splits go below

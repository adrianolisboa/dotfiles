local bufferline = require("bufferline")

bufferline.setup({
  options = {
    numbers = "none", -- "none", "ordinal", "buffer_id", or "both"
    close_command = "bdelete! %d", -- Command to delete buffers
    right_mouse_command = "bdelete! %d", -- Right-click to delete
    left_mouse_command = "buffer %d", -- Left-click to switch
    middle_mouse_command = nil, -- Middle-click does nothing
    diagnostics = "nvim_lsp", -- Show LSP diagnostics
    offsets = { -- Add an offset for file tree plugins
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center",
        separator = true,
      },
    },
    separator_style = "slant", -- "slant", "thick", "thin", etc.
    show_buffer_icons = true, -- Show filetype icons
    show_buffer_close_icons = true,
    show_close_icon = false,
    enforce_regular_tabs = false,
    always_show_bufferline = true,
  },
})

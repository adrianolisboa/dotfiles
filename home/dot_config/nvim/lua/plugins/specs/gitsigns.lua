require("gitsigns").setup({
  signs = {
    add          = { text = "+" },
    change       = { text = "~" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },
  current_line_blame = true, -- Enable inline git blame
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- Key mappings
    local function keymap(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Git blame
    keymap("n", "<leader>gb", function()
      gs.blame_line({ full = true })
    end, { desc = "Git blame" })

    -- Git status
    keymap("n", "<leader>gs", ":Gitsigns status<CR>", { desc = "Git status" })

    -- Checkout (revert changes to file)
    keymap("n", "<leader>gr", function()
      if vim.fn.confirm("Revert file to original status?", "&Yes\n&No", 1) == 1 then
        gs.reset_buffer()
      end
    end, { desc = "Revert file" })

    -- Navigation
    keymap("n", "]c", function()
      gs.next_hunk()
    end, { desc = "Next hunk" })

    keymap("n", "[c", function()
      gs.prev_hunk()
    end, { desc = "Previous hunk" })

    -- Actions
    keymap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
    keymap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
    keymap("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
    keymap("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
    keymap("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
  end,
})

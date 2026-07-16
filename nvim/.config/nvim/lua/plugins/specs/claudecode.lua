return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>co", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      { "<leader>ce", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude Code" },
      { "<leader>cn", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude Code" },
      { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>cs", "<cmd>ClaudeCodeTreeAdd<cr>", ft = { "NvimTree", "neo-tree" }, desc = "Add file to Claude" },
    },
  },
}

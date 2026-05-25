return {
  {
    "carlos-algms/agentic.nvim",
    keys = {
      { "<leader>aa", function() require("agentic").toggle() end, desc = "Toggle Codex ACP Chat", mode = { "n", "v", "i" } },
      { "<leader>ac", function() require("agentic").add_selection_or_file_to_context() end, desc = "Add File or Selection to Codex ACP", mode = { "n", "v" } },
      { "<leader>an", function() require("agentic").new_session() end, desc = "New Codex ACP Session", mode = { "n", "v", "i" } },
      { "<leader>ad", function() require("agentic").add_current_line_diagnostics() end, desc = "Add Line Diagnostics to Codex ACP" },
      { "<leader>aD", function() require("agentic").add_buffer_diagnostics() end, desc = "Add Buffer Diagnostics to Codex ACP" },
    },
    opts = {
      provider = "codex-acp",
    },
  },
}

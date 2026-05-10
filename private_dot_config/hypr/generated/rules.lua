return {
  windows = {
    {
      name = "terminal-workspace",
      match = { class = "kitty" },
      workspace = "name:terminal",
    },
    {
      name = "browser-workspace",
      match = { class = "chromium" },
      workspace = "name:web",
    },
  },

  layers = {},
}

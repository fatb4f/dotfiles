local home = os.getenv("HOME")

return {
  home = {
    root = home,
    workspace = "home",
  },

  dots = {
    root = home .. "/src/dotfiles",
    workspace = "dots",
  },
}

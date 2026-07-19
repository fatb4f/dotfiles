# Neovim System Tooling

LazyVim manages Neovim plugins. Language tools are installed outside Neovim.

## Go

Arch Linux package:

```bash
sudo pacman -S --needed golangci-lint
```

Go-installed tools:

```bash
mkdir -p "${GOBIN:-${XDG_DATA_HOME:-$HOME/.local/share}/go/bin}"

go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
```

The zsh environment exports `GOBIN`, defaulting to
`${XDG_DATA_HOME:-$HOME/.local/share}/go/bin`, and adds the same directory to
`PATH`.

## Rust

```bash
rustup component add rust-analyzer rustfmt clippy
```

## CUE

```bash
go install cuelang.org/go/cmd/cue@latest
```

## Bun-managed Tools

```bash
bun add -g bash-language-server prettier
```

## CodeCompanion ACP

```bash
npm config set prefix "${XDG_DATA_HOME:-$HOME/.local/share}/npm"
npm install -g @agentclientprotocol/codex-acp
codex-acp --version
```

The configured npm prefix's `bin` directory is on `PATH`. Validate the full
Neovim integration with `:checkhealth codecompanion`.

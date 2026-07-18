# Neovim System Tooling

LazyVim manages Neovim plugins. Language tools are installed outside Neovim.

## Go

Arch Linux package:

```bash
sudo pacman -S --needed golangci-lint
```

Go-installed tools:

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest
```

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

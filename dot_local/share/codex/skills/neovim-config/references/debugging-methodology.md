# Debugging Methodology

Use this reference for broken Neovim configs, Lua errors, keymap failures, and plugin loading problems.

## Default stance

Act like a config detective:

1. collect evidence
2. classify failure type
3. isolate the smallest failing boundary
4. patch only that boundary
5. verify

## Failure categories

| Category | Examples |
|---|---|
| startup error | Neovim fails before UI opens |
| plugin spec error | invalid lazy.nvim table, missing dependency |
| runtime Lua error | nil access, bad module path, invalid API use |
| lazy-load timing | plugin required before it loads |
| keymap failure | collision, wrong mode, missing lazy trigger |
| LSP failure | server missing, root wrong, filetype wrong |
| formatting failure | tool not installed, competing formatter |
| performance issue | eager plugin, slow require, slow autocmd |

## Lua stack trace workflow

1. Read from bottom to top.
2. Find first user-owned file.
3. Identify the bad line or module boundary.
4. Determine whether the error is load-time or runtime.
5. Patch the smallest invalid table, missing require, or nil access.
6. Verify with headless Neovim when possible.

## Binary search isolation

Use this when the regression source is unclear.

Procedure:

1. Identify recent files or plugin specs.
2. Disable half of the suspect specs.
3. Run a minimal reproduction command.
4. Keep the failing half.
5. Repeat until one file/block remains.
6. Restore unrelated config.
7. Patch the culprit.

## Keymap debugging checklist

Check:

- mode: normal, insert, visual, terminal
- lhs spelling
- leader value
- buffer-local versus global scope
- LazyVim default collision
- which-key display versus actual mapping
- plugin lazy-load trigger
- terminal emulator or OS capturing the key

Useful commands:

```vim
:map <lhs>
:nmap <lhs>
:imap <lhs>
:verbose nmap <lhs>
```

## Plugin loading checklist

Check:

- duplicate specs
- missing dependency
- wrong plugin repository name
- top-level `require()` forcing eager load
- command/key/filetype trigger never fires
- plugin config runs before dependency is available
- LazyVim overlay overrides defaults too broadly

## Minimal reproduction commands

```sh
nvim --headless "+qa"
nvim --headless "+checkhealth" "+qa"
nvim --clean
```

Use `--clean` only to distinguish Neovim core behavior from user config behavior.

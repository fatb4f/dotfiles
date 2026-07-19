# WezTerm Bindings

This is the effective WezTerm binding set for workspace, window, tab, and pane management. It includes the configured bindings and relevant WezTerm defaults that remain active.

## sessionizer/window

| Binding | Action |
|---|---|
| `Alt+s` | Open the sessionizer. |
| `Alt+9` | Open the fuzzy workspace launcher. |
| `Ctrl+Shift+N` | Open a new window. |
| `Alt+Enter` | Toggle full screen. |
| `Ctrl+Shift+P` | Open the command palette. |
| `Ctrl+Shift+R` | Reload the WezTerm configuration. |
| `Ctrl+Shift+E` | Open the active pane's scrollback in Neovim. |

## tab

| Binding | Action |
|---|---|
| `Ctrl+Shift+T` | Open a new tab. |
| `Ctrl+Tab` | Activate the next tab. |
| `Ctrl+Shift+Tab` | Activate the previous tab. |
| `Ctrl+PageDown` | Activate the next tab. |
| `Ctrl+PageUp` | Activate the previous tab. |
| `Ctrl+Shift+PageDown` | Move the active tab right. |
| `Ctrl+Shift+PageUp` | Move the active tab left. |
| `Ctrl+Shift+1…8` | Activate tab 1…8. |
| `Ctrl+Shift+9` | Activate the last tab. |

`Ctrl+Shift+W` is intentionally assigned to pane close rather than tab close. Closing the last pane in a tab also closes that tab.

## pane

| Binding | Action |
|---|---|
| `Ctrl+Shift+S` | Split right, launching the configured shell. |
| `Ctrl+Shift+D` | Split down, launching the configured shell. |
| `Ctrl+Shift+Z` | Toggle zoom for the active pane. |
| `Ctrl+Shift+W` | Close the active pane after confirmation. |
| `Ctrl+Shift+O` | Open pane selection with pane IDs. |
| `Ctrl+Shift+h/j/k/l` | Activate the pane left/down/up/right. |
| `Ctrl+Shift+Left/Down/Up/Right` | Activate the pane in the arrow direction. |
| `Ctrl+Shift+Alt+h/j/k/l`, then `1…9` | Resize left/down/up/right by 10%…90% of the active pane's current width or height. |

The percentage resize prefix is active for two seconds. Horizontal directions use the pane's column count; vertical directions use its visible row count. An unrecognized follow-up key cancels the pending resize.

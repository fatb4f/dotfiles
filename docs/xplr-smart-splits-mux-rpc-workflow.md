# Xplr / WezTerm / Neovim / smart-splits RPC Workflow

Cheatsheet matrix for the project-tree workflow.

## Core invariant

```text
WezTerm owns project/session topology and validated routing.
WezTerm owns project-tree hide/reveal visibility.
Neovim hosts the socket-backed RPC executor.
smart-splits owns mux focus/resize mechanics.
xplr owns tree browsing and focused-path preview intent emission.
```

## Authority matrix

| Surface | Owns | Must not own | Primary files |
|---|---|---|---|
| WezTerm project registry | Project/session identity, roots, cwd, editor env, socket env | Editor buffer state, generic mux mechanics | `chezmoi/private_dot_config/wezterm/modules/workspaces/projects.lua` |
| WezTerm sessionizer | Workspace selection and `SwitchToWorkspace` | Neovim project picking | `chezmoi/private_dot_config/wezterm/modules/workspaces/sessionizer.lua` |
| WezTerm controller | Launch/focus project IDE, spawn socket-backed Neovim, spawn xplr pane | xplr file-open semantics, smart-splits internals | `chezmoi/private_dot_config/wezterm/modules/workspaces/controller.lua` |
| WezTerm runtime cache | Active project session cache, editor/explorer pane roles | Persistent authority, generated state authority | `chezmoi/private_dot_config/wezterm/modules/workspaces/runtime.lua` |
| WezTerm xplr RPC router | Validate xplr compatibility intents, resolve active project, validate socket/root/path, call Neovim RPC for open intents | Preview content rendering inside xplr, xplr-owned layout bindings, project-tree hide/reveal ownership | `chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua` |
| WezTerm project-tree visibility | Shift+H/Shift+R and palette Hide/Reveal, cached editor/explorer pane lookup, same-tab guard, pane zoom mutation | xplr open/preview intent, Neovim buffer rendering, N/W resize migration | `chezmoi/private_dot_config/wezterm/modules/workspaces/project_tree_visibility.lua` |
| WezTerm events/palette | Entry points for launch and project-tree visibility commands | Duplicate validation or mutation implementation | `events.lua`, `palette.lua` |
| Neovim mux RPC executor | Load `smart-splits.mux`, get backend, call `next_pane`, edit files, maintain the preview split | Project/session selection, project-tree hide/reveal/narrow/wide ownership | `chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua` |
| smart-splits backend | Mux navigation and resize execution | Project topology, xplr tree state | `require("smart-splits.mux").get()` |
| tree-view.xplr | xplr-local tree rendering dependency | WezTerm routing, Neovim RPC, smart-splits mechanics, project topology | `chezmoi/private_dot_config/xplr/plugins/tree-view/init.lua` |
| xplr | Tree UI, focused path selection, preview toggle state, local keybindings, bounded direct Neovim RPC emission for open/preview intent | Direct smart-splits dependency, direct project/session authority, file-content preview rendering, project-tree layout ownership | `chezmoi/private_dot_config/xplr/init.lua` |

## Request flow matrix

| User action | Emitted intent | WezTerm route | Neovim RPC | smart-splits action | Expected result |
|---|---|---|---|---|---|
| `Alt-s` sessionizer | Session selection | `sessionizer.lua` -> `SwitchToWorkspace` | none | none | Project workspace selected or spawned |
| Palette: `Launch project IDE` | `term-ide-launch` | `events.lua` -> `controller.launch(window)` | `nvim --listen $TERM_NVIM_SOCKET` during spawn | none | Neovim opens with xplr left pane |
| xplr `h` | xplr internal `Back` | none | none | none | xplr moves back to parent/history |
| xplr `j` | xplr internal `FocusNext` | none | none | none | xplr moves cursor down |
| xplr `k` | xplr internal `FocusPrevious` | none | none | none | xplr moves cursor up |
| xplr `l` / `enter` on directory | xplr internal `Enter` | none | none | none | xplr descends into directory |
| xplr `l` / `enter` on file | direct `nvim --server "$TERM_NVIM_SOCKET" --remote-expr` after shell root/socket checks | none | `v:lua.TermXplrMuxRpc("open", path)` | `next_pane("right")` after `edit` | File opens in project Neovim and focus moves right to editor |
| xplr `P` preview off -> on | direct `nvim --server "$TERM_NVIM_SOCKET" --remote-expr` after shell root/socket checks | none | `TermXplrMuxRpc("preview", path)` | `next_pane("left")` after preview update | Neovim opens/reuses a preview split and focus returns to xplr |
| xplr `P` preview on -> off | direct `nvim --server "$TERM_NVIM_SOCKET" --remote-expr` | none | `TermXplrMuxRpc("preview", "off")` | `next_pane("left")` after close | Neovim closes the preview split and focus returns to xplr |
| `Shift+H` | WezTerm key binding | `project_tree_visibility.dispatch("hide")` | none | activate editor, then `SetPaneZoomState(true)` through `window:perform_action` | Tree is hidden by zooming the editor pane |
| `Shift+R` | WezTerm key binding | `project_tree_visibility.dispatch("reveal")` | none | `SetPaneZoomState(false)` through `window:perform_action`, then activate explorer | Tree is revealed and explorer is focused |
| Palette: `Hide project tree` | `term-project-tree-hide` | `events.lua` -> `project_tree_visibility.dispatch("hide")` | none | same pane zoom path as hotkey path | Tree is hidden by zooming the editor pane |
| Palette: `Reveal project tree` | `term-project-tree-reveal` | `events.lua` -> `project_tree_visibility.dispatch("reveal")` | none | same pane unzoom path as hotkey path | Tree is revealed and explorer is focused |
| `<C-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits focus traversal | Move across Neovim splits and WezTerm panes |
| `<A-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits resize traversal | Resize active split/pane |

## Validation matrix

| Boundary | Accept | Reject | Where enforced |
|---|---|---|---|
| WezTerm user-var RPC payload shape | Compatibility/event payloads carrying base64 JSON for open intents | Empty payload, malformed JSON, unknown `op` | `xplr_rpc.decode_payload` |
| Visibility action | `hide`, `reveal` | Anything else, for example `narrow`, `wide`, or `fullscreen` | `project_tree_visibility.dispatch` |
| Visibility target panes | Cached project `editor` and `explorer` pane ids in the same tab where observable | Missing stale pane ids, non-project workspace, same-tab mismatch | `project_tree_visibility.project_panes` |
| Visibility diagnostics | Temporary toasts report dispatch, project lookup, cached pane lookup, same-tab check, and mutation result or failure boundaries | Dispatch toast as mutation proof, silent visibility no-op | `project_tree_visibility.dispatch` |
| Visibility mutation proof | Hide/reveal use `SetPaneZoomState` against the selected editor pane and activate the expected target pane | Resize-only hide/reveal, zero-width explorer, success without mutation evidence | `project_tree_visibility.dispatch` |
| Preview path | Existing absolute path inside project root, or `off` to close preview | Relative path, non-existing path, path outside root | `xplr/init.lua`, `workflow/mux_rpc.lua` |
| Open path | Existing absolute path inside project root | Relative path, non-existing path, path outside root | `xplr_rpc.validate_open` |
| Project contract | Active configured project session with canonical root | Non-project workspace, missing root | `xplr_rpc.contract_for` |
| Neovim socket | Existing socket at `TERM_NVIM_SOCKET` | Missing, empty, stale, not a socket | `xplr_rpc.contract_for` |
| Direct xplr file open | Canonical existing path inside `TERM_PROJECT_ROOT` and existing `TERM_NVIM_SOCKET` | Missing root/socket, non-existing path, path outside root | `xplr/init.lua` shell guard |
| Neovim RPC result | `1`, `true`, or `v:true` | Any failed command or false-like return | `xplr_rpc.nvim_accepted` |
| smart-splits backend | `smart-splits.mux.get()` returns active backend in session | Missing plugin, no mux session, failed `next_pane` / `resize_pane` | `workflow/mux_rpc.lua` |
| Preview output | Existing file buffers with filetype/syntax activation or bounded generated directory trees inside Neovim | Paths outside root, non-existing paths, unbounded recursive directory walks | `xplr/init.lua`, `workflow/mux_rpc.lua` |

## Validation Commands

Run repository-local syntax checks against materialized config.

```bash
stylua --check chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua chezmoi/private_dot_config/wezterm/modules/workspaces/runtime.lua
selene chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua
luacheck chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua
nvim --headless -u NONE +'set rtp+=chezmoi/private_dot_config/nvim' +'luafile chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua' +qa
tmp_home=$(mktemp -d); mkdir -p "$tmp_home/.config"; ln -s "$PWD/chezmoi/private_dot_config/xplr" "$tmp_home/.config/xplr"; TERM=xterm HOME="$tmp_home" TERM_PROJECT_ROOT="$PWD" timeout 1 xplr -c "$tmp_home/.config/xplr/init.lua" "$PWD"
```

## Neovim QoL Boundary Gate

Neovim quality-of-life additions may expose editor-local discovery for buffers, diagnostics, quickfix, symbols, commands, keymaps, and invocation-only commands that call back into the WezTerm/sessionizer workflow.

They must not select, rank, persist, or own project/session topology. Project launch, workspace identity, and workspace switching remain WezTerm responsibilities.

| Boundary | Accept | Reject |
|---|---|---|
| Neovim picker surface | Editor-local discovery, current-buffer actions, quickfix, diagnostics, symbols, commands, keymaps | Project/session selection, workspace ranking, workspace persistence |
| WezTerm/sessionizer bridge | Invocation-only command handoff | Neovim-owned project launch or topology model |
| xplr tree UI | Focused path selection and bounded open/preview intent | Direct pane mechanics integration or CustomParagraph file-content preview |
| Runtime and generated projections | Evidence for validation | Persistent decision source |

## File/change matrix

| File | Role in workflow | Change class |
|---|---|---|
| `chezmoi/private_dot_config/wezterm/wezterm.lua` | Loads scoped WezTerm modules and shifted project-tree visibility keys | UI entrypoint |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/project_tree_visibility.lua` | WezTerm-owned Shift+H/R project-tree visibility executor | runtime adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua` | Validated WezTerm -> Neovim RPC router for open compatibility commands | runtime adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua` | Registers launch/visibility/user-var events | event adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua` | Command palette entries for launch and visibility | UI entrypoint |
| `chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua` | Smart-splits backend RPC executor for open intents plus Neovim preview split lifecycle | editor-side adapter |
| `chezmoi/private_dot_config/xplr/init.lua` | Loads tree-view, declares `project_tree`, opens files, and previews focused paths through direct Neovim remote expr | tree UI adapter |
| `chezmoi/private_dot_config/xplr/plugins/tree-view/init.lua` | Vendored tree-view.xplr plugin | xplr-local runtime dependency |
| `chezmoi/private_dot_config/xplr/plugins/tree-view/LICENSE` | Upstream MIT license | vendored license evidence |

## Operational cheatsheet

| Task | Command/key | Path |
|---|---|---|
| Pick project workspace | `Alt-s` | WezTerm sessionizer |
| Launch project IDE | Command palette -> `Launch project IDE` | WezTerm controller |
| Move between tree/editor/panes | `<C-h/j/k/l>` | smart-splits |
| Resize active split/pane manually | `<A-h/j/k/l>` | smart-splits |
| Move inside xplr | `h` / `j` / `k` / `l` | xplr local navigation |
| Open focused file from xplr | `l` / `enter` / `right` | xplr -> direct Neovim remote expr -> edit -> smart-splits focus |
| Hide tree | `Shift+H` or command palette -> `Hide project tree` | WezTerm -> cached editor/explorer pane ids -> editor activation -> `SetPaneZoomState(true)` |
| Reveal tree | `Shift+R` or command palette -> `Reveal project tree` | WezTerm -> `SetPaneZoomState(false)` -> explorer activation |
| Toggle preview | xplr `P` | xplr asks the running Neovim socket to create/reuse or close the preview split |

## Forbidden attractors

| Do not do this | Reason |
|---|---|
| Add a Neovim project picker | Competes with WezTerm sessionizer authority |
| Let xplr call smart-splits directly | xplr is not the Neovim Lua host |
| Reimplement generic pane movement in WezTerm Lua | smart-splits already owns mux mechanics |
| Treat runtime cache as persistent authority | It is evidence/routing state only |
| Use generated artifacts as authority | Repo-local workflow and materialized configs are authority surfaces |
| Let tree-view own topology | It is only an xplr-local rendering dependency |
| Let repeated preview toggles resize WezTerm panes | Preview is an editor-local split in the running Neovim instance |
| Route xplr H/R through OSC 1337 user vars, direct Neovim socket RPC, or `xplr_rpc.lua` layout commands | Project-tree visibility is WezTerm-owned and must use `project_tree_visibility` |
| Materialize N/W resize migration in the H/R visibility slice | Resize migration is deferred |
| Report hide/reveal completion without observed dimension movement | Dispatch does not prove visible mutation |
| Use `preview-tabbed.xplr`, XEmbed, or `tabbed` as the default preview dependency | This Wayland-centered setup keeps previews terminal-native inside WezTerm |
| Treat `CustomParagraph` YAML metadata as preview completion | xplr should emit focused paths; Neovim renders preview content |
| Reintroduce OSC/FIFO preview lifecycle as the default | The direct Neovim socket path avoids the unreliable OSC 1337 preview handoff |
| Promote Neovim QoL discovery into project/session topology | Duplicates the WezTerm/sessionizer boundary |

## Runtime smoke sequence

```text
1. Alt-s -> select project.
2. Command palette -> Launch project IDE.
3. Confirm xplr appears left of socket-backed Neovim.
4. In xplr, confirm `h/j/k/l` move back/down/up/enter locally.
5. In xplr, press `l` or `enter` on a file.
6. Confirm file opens in Neovim and focus moves right.
7. Press `P` in xplr and confirm Neovim opens a preview split while focus returns to xplr.
8. Move focus in xplr and confirm the Neovim preview split updates to the focused path.
9. Press `P` again and confirm Neovim closes the preview split and focus returns to xplr.
10. Use Shift+H/R or palette Hide/Reveal and confirm WezTerm applies cached pane-id visibility.
11. Confirm xplr does not own project-tree visibility operations.
12. If a visibility action does not visibly mutate panes, confirm the toast identifies dispatch, project lookup, pane lookup, same-tab check, or mutation failure.
13. Use <C-h/j/k/l> and <A-h/j/k/l> from both xplr and Neovim.
14. For visibility actions, treat mutation toasts as success evidence only when they identify zoom/unzoom and the final focused pane.
```

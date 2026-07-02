# Xplr / WezTerm / Neovim / smart-splits RPC Workflow

Cheatsheet matrix for the project-tree workflow.

## Core invariant

```text
WezTerm owns project/session topology and validated routing.
WezTerm owns all project-tree pane layout operations.
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
| WezTerm xplr RPC router | Validate xplr/palette intents, resolve active project, validate socket/root/path, call Neovim RPC for open intents, apply project-tree layout by cached pane id | Preview content rendering inside xplr, xplr-owned layout bindings | `chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua` |
| WezTerm events/palette | Entry points for launch and explorer layout commands | Duplicate validation or layout implementation | `events.lua`, `palette.lua` |
| Neovim mux RPC executor | Load `smart-splits.mux`, get backend, call `next_pane`, edit files, maintain the preview split | Project/session selection, project-tree pane hide/reveal/narrow/wide ownership | `chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua` |
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
| `Shift+H` | WezTerm key binding | `xplr_rpc.dispatch_layout` | none | activate editor and toggle editor pane zoom on | Tree is hidden through tab zoom and editor remains visible |
| `Shift+R` | WezTerm key binding | `xplr_rpc.dispatch_layout` | none | toggle editor pane zoom off, then activate explorer | Tree is revealed through tab unzoom and explorer is focused |
| `Shift+N` | WezTerm key binding | `xplr_rpc.dispatch_layout` | none | adjust editor pane left by 8 cells | Tree narrows |
| `Shift+W` | WezTerm key binding | `xplr_rpc.dispatch_layout` | none | adjust editor pane right by 8 cells, then activate explorer | Tree widens |
| Palette: `Hide project tree` | `term-xplr-layout-hide` | `events.lua` -> `xplr_rpc.dispatch_layout` | none | activate editor and toggle editor pane zoom on | Tree is hidden through tab zoom and editor remains visible |
| Palette: `Reveal project tree` | `term-xplr-layout-reveal` | `events.lua` -> `xplr_rpc.dispatch_layout` | none | toggle editor pane zoom off, then activate explorer | Tree is revealed through tab unzoom and explorer is focused |
| Palette: `Narrow project tree` | `term-xplr-layout-narrow` | `events.lua` -> `xplr_rpc.dispatch_layout` | none | adjust editor pane left by 8 cells | Tree narrows |
| Palette: `Widen project tree` | `term-xplr-layout-wide` | `events.lua` -> `xplr_rpc.dispatch_layout` | none | adjust editor pane right by 8 cells, then activate explorer | Tree widens |
| `<C-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits focus traversal | Move across Neovim splits and WezTerm panes |
| `<A-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits resize traversal | Resize active split/pane |

## Validation matrix

| Boundary | Accept | Reject | Where enforced |
|---|---|---|---|
| WezTerm user-var RPC payload shape | Compatibility/event payloads carrying base64 JSON for open intents | Empty payload, malformed JSON, unknown `op` | `xplr_rpc.decode_payload` |
| Layout kind | `hide`, `reveal`, `narrow`, `wide` | Anything else, for example `fullscreen` | `xplr_rpc.validate_layout` |
| Layout target panes | Cached project `editor` and `explorer` pane ids in the same tab where observable | Missing stale pane ids, non-project workspace, same-tab mismatch | `xplr_rpc.apply_pane_layout` |
| Layout diagnostics | Temporary toasts report dispatch, cached pane lookup, same-tab check, and mutation failure boundaries | Silent layout no-op | `xplr_rpc.dispatch_layout`, `xplr_rpc.apply_pane_layout` |
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
stylua --check chezmoi/private_dot_config/xplr/init.lua chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua chezmoi/private_dot_config/wezterm/wezterm.lua chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua
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
| `chezmoi/private_dot_config/wezterm/wezterm.lua` | Loads scoped WezTerm modules and shifted project-tree layout keys | UI entrypoint |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua` | Validated WezTerm -> Neovim RPC router for open compatibility commands; pane-id layout command executor | runtime adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua` | Registers launch/layout/user-var events | event adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua` | Command palette entries for launch and layout | UI entrypoint |
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
| Hide tree | `Shift+H` or command palette -> `Hide project tree` | WezTerm -> cached editor/explorer pane ids -> editor zoom |
| Reveal tree | `Shift+R` or command palette -> `Reveal project tree` | WezTerm -> editor unzoom -> cached explorer activation |
| Narrow tree | `Shift+N` or command palette -> `Narrow project tree` | WezTerm -> cached editor/explorer pane ids |
| Widen tree | `Shift+W` or command palette -> `Widen project tree` | WezTerm -> cached editor/explorer pane ids |
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
| Route xplr H/R/N/W through OSC 1337 user vars or direct Neovim socket RPC | Project-tree layout is WezTerm-owned and must use `xplr_rpc.dispatch_layout` |
| Implement hide/reveal as only inverse fixed-width resizes | Zoom/unzoom gives WezTerm a recoverable hidden-tree topology |
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
10. Use Shift+H/R/N/W or palette Hide/Reveal/Narrow/Widen and confirm WezTerm applies cached pane-id layout.
11. Confirm xplr does not own project-tree layout operations.
12. If a layout action does not visibly mutate panes, confirm the toast identifies dispatch, contract lookup, pane lookup, same-tab check, or mutation failure.
13. Use <C-h/j/k/l> and <A-h/j/k/l> from both xplr and Neovim.
```

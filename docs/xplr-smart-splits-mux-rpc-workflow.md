# Xplr / WezTerm / Neovim / smart-splits RPC Workflow

Cheatsheet matrix for the project-tree workflow.

## Core invariant

```text
WezTerm owns project/session topology and validated routing.
Neovim hosts the socket-backed RPC executor.
smart-splits owns mux focus/resize mechanics.
xplr owns tree browsing and emits bounded intents.
```

## Authority matrix

| Surface | Owns | Must not own | Primary files |
|---|---|---|---|
| WezTerm project registry | Project/session identity, roots, cwd, editor env, socket env | Editor buffer state, generic mux mechanics | `chezmoi/private_dot_config/wezterm/modules/workspaces/projects.lua` |
| WezTerm sessionizer | Workspace selection and `SwitchToWorkspace` | Neovim project picking | `chezmoi/private_dot_config/wezterm/modules/workspaces/sessionizer.lua` |
| WezTerm controller | Launch/focus project IDE, spawn socket-backed Neovim, spawn xplr pane | xplr file-open semantics, smart-splits internals | `chezmoi/private_dot_config/wezterm/modules/workspaces/controller.lua` |
| WezTerm runtime cache | Active project session cache, editor/explorer pane roles | Persistent authority, generated state authority | `chezmoi/private_dot_config/wezterm/modules/workspaces/runtime.lua` |
| WezTerm xplr RPC router | Validate xplr/palette intents, resolve active project, validate socket/root/path, call Neovim RPC | Direct generic pane resize/focus when smart-splits can execute it | `chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua` |
| WezTerm events/palette | Entry points for launch and explorer layout commands | Duplicate validation or layout implementation | `events.lua`, `palette.lua` |
| Neovim mux RPC executor | Load `smart-splits.mux`, get backend, call `next_pane` / `resize_pane`, edit files | Project/session selection | `chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua` |
| smart-splits backend | Mux navigation and resize execution | Project topology, xplr tree state | `require("smart-splits.mux").get()` |
| tree-view.xplr | xplr-local tree rendering dependency | WezTerm routing, Neovim RPC, smart-splits mechanics, project topology | `chezmoi/private_dot_config/xplr/plugins/tree-view/init.lua` |
| xplr | Tree UI, focused path, preview toggle state, local keybindings, bounded intent emission | Direct smart-splits dependency, direct project/session authority | `chezmoi/private_dot_config/xplr/init.lua` |

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
| xplr `H` optional | `TERM_XPLR_RPC={op:"layout",kind:"hide"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "hide")` | `next_pane("right")`, then `resize_pane("left", 80)` | Tree is visually hidden by resizing |
| xplr `R` optional | `TERM_XPLR_RPC={op:"layout",kind:"reveal"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "reveal")` | `next_pane("left")` | Tree is revealed/focused by moving left |
| xplr `N` optional | `TERM_XPLR_RPC={op:"layout",kind:"narrow"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "narrow")` | `next_pane("right")`, then `resize_pane("left", 8)` | Tree narrows |
| xplr `W` optional | `TERM_XPLR_RPC={op:"layout",kind:"wide"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "wide")` | `next_pane("left")`, then `resize_pane("right", 8)` | Tree widens |
| xplr `P` preview off -> on | `SwitchLayoutCustom=project_tree_preview` and `TERM_XPLR_RPC={op:"layout",kind:"preview_on"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "preview_on")` | `next_pane("left")`, then `resize_pane("right", 64)` once | xplr shows tree plus preview and remains focused |
| xplr `P` preview on -> off | `SwitchLayoutCustom=project_tree` and `TERM_XPLR_RPC={op:"layout",kind:"preview_off"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "preview_off")` | `next_pane("right")`, `resize_pane("left", 64)` once, then `next_pane("left")` | xplr returns to tree-only layout and remains focused |
| Palette: `Hide project tree` | `term-xplr-layout-hide` | `events.lua` -> `xplr_rpc.dispatch_layout` | `TermXplrMuxRpc("layout", "hide")` | same as xplr `H` | Same behavior as xplr key |
| Palette: `Reveal project tree` | `term-xplr-layout-reveal` | `events.lua` -> `xplr_rpc.dispatch_layout` | `TermXplrMuxRpc("layout", "reveal")` | same as xplr `R` | Same behavior as xplr key |
| `<C-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits focus traversal | Move across Neovim splits and WezTerm panes |
| `<A-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits resize traversal | Resize active split/pane |

## Validation matrix

| Boundary | Accept | Reject | Where enforced |
|---|---|---|---|
| RPC payload shape | `{op:"open", path:string}` or `{op:"layout", kind:string}` | Empty payload, malformed JSON, unknown `op` | `xplr_rpc.decode_payload` |
| Layout kind | `hide`, `reveal`, `narrow`, `wide`, `preview_on`, `preview_off` | Anything else, for example `fullscreen` | `xplr_rpc.validate_layout` |
| Open path | Existing absolute path inside project root | Relative path, non-existing path, path outside root | `xplr_rpc.validate_open` |
| Project contract | Active configured project session with canonical root | Non-project workspace, missing root | `xplr_rpc.contract_for` |
| Neovim socket | Existing socket at `TERM_NVIM_SOCKET` | Missing, empty, stale, not a socket | `xplr_rpc.contract_for` |
| Direct xplr file open | Canonical existing path inside `TERM_PROJECT_ROOT` and existing `TERM_NVIM_SOCKET` | Missing root/socket, non-existing path, path outside root | `xplr/init.lua` shell guard |
| Neovim RPC result | `1`, `true`, or `v:true` | Any failed command or false-like return | `xplr_rpc.nvim_accepted` |
| smart-splits backend | `smart-splits.mux.get()` returns active backend in session | Missing plugin, no mux session, failed `next_pane` / `resize_pane` | `workflow/mux_rpc.lua` |
| Preview resize drift | First `preview_on` while inactive and first `preview_off` while active | Repeated on/off accumulating resize deltas | ephemeral `preview_active` guard in `workflow/mux_rpc.lua` |

## Validation Commands

Run repository-local syntax checks against materialized config.

```bash
stylua --check chezmoi/private_dot_config/xplr/init.lua chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua
tmp_home=$(mktemp -d); mkdir -p "$tmp_home/.config"; ln -s "$PWD/chezmoi/private_dot_config/xplr" "$tmp_home/.config/xplr"; TERM=xterm HOME="$tmp_home" TERM_PROJECT_ROOT="$PWD" timeout 1 xplr -c "$tmp_home/.config/xplr/init.lua" "$PWD"
```

## Neovim QoL Boundary Gate

Neovim quality-of-life additions may expose editor-local discovery for buffers, diagnostics, quickfix, symbols, commands, keymaps, and invocation-only commands that call back into the WezTerm/sessionizer workflow.

They must not select, rank, persist, or own project/session topology. Project launch, workspace identity, and workspace switching remain WezTerm responsibilities.

| Boundary | Accept | Reject |
|---|---|---|
| Neovim picker surface | Editor-local discovery, current-buffer actions, quickfix, diagnostics, symbols, commands, keymaps | Project/session selection, workspace ranking, workspace persistence |
| WezTerm/sessionizer bridge | Invocation-only command handoff | Neovim-owned project launch or topology model |
| xplr tree UI | Focused path selection and bounded open/layout intent | Direct pane mechanics integration |
| Runtime and generated projections | Evidence for validation | Persistent decision source |

## File/change matrix

| File | Role in workflow | Change class |
|---|---|---|
| `chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua` | Validated WezTerm -> Neovim RPC router | runtime adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua` | Registers launch/layout/user-var events | event adapter |
| `chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua` | Command palette entries for launch and layout | UI entrypoint |
| `chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua` | Smart-splits backend RPC executor | editor-side adapter |
| `chezmoi/private_dot_config/xplr/init.lua` | Loads tree-view, declares `project_tree` / `project_tree_preview`, opens files through direct Neovim remote expr, emits JSON `TERM_XPLR_RPC` layout intents | tree UI adapter |
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
| Hide tree, optional | xplr `H` or palette `Hide project tree` | xplr/WezTerm -> Neovim mux RPC |
| Reveal tree, optional | xplr `R` or palette `Reveal project tree` | xplr/WezTerm -> Neovim mux RPC |
| Narrow tree, optional | xplr `N` or palette `Narrow project tree` | xplr/WezTerm -> Neovim mux RPC |
| Widen tree, optional | xplr `W` or palette `Widen project tree` | xplr/WezTerm -> Neovim mux RPC |
| Toggle preview | xplr `P` | xplr switches local layout and emits guarded preview mux intent |

## Forbidden attractors

| Do not do this | Reason |
|---|---|
| Add a Neovim project picker | Competes with WezTerm sessionizer authority |
| Let xplr call smart-splits directly | xplr is not the Neovim Lua host |
| Reimplement generic pane movement in WezTerm Lua | smart-splits already owns mux mechanics |
| Treat runtime cache as persistent authority | It is evidence/routing state only |
| Use generated artifacts as authority | Repo-local workflow and materialized configs are authority surfaces |
| Let tree-view own topology | It is only an xplr-local rendering dependency |
| Let repeated preview toggles resize panes | Preview resize is guarded by Neovim-local ephemeral state |
| Promote Neovim QoL discovery into project/session topology | Duplicates the WezTerm/sessionizer boundary |

## Runtime smoke sequence

```text
1. Alt-s -> select project.
2. Command palette -> Launch project IDE.
3. Confirm xplr appears left of socket-backed Neovim.
4. In xplr, confirm `h/j/k/l` move back/down/up/enter locally.
5. In xplr, press `l` or `enter` on a file.
6. Confirm file opens in Neovim and focus moves right.
7. Press `P` in xplr and confirm `project_tree_preview` plus one preview-on resize.
8. Press `P` again and confirm `project_tree` plus one inverse preview-off resize.
9. Repeatedly dispatch preview on/off and confirm resize deltas do not accumulate.
10. Optionally press H/R/N/W in xplr and confirm layout changes.
11. Optionally use palette Hide/Reveal/Narrow/Widen and confirm same path.
12. Use <C-h/j/k/l> and <A-h/j/k/l> from both xplr and Neovim.
```

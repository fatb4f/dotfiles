# Xplr / WezTerm / Neovim / smart-splits RPC Workflow

Cheatsheet matrix for the project-tree workflow implemented by issue #43.

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
| xplr | Tree UI, focused path, local keybindings, bounded intent emission | Direct smart-splits dependency, direct project/session authority | `chezmoi/private_dot_config/xplr/init.lua` |

## Request flow matrix

| User action | Emitted intent | WezTerm route | Neovim RPC | smart-splits action | Expected result |
|---|---|---|---|---|---|
| `Alt-s` sessionizer | Session selection | `sessionizer.lua` -> `SwitchToWorkspace` | none | none | Project workspace selected or spawned |
| Palette: `Launch project IDE` | `term-ide-launch` | `events.lua` -> `controller.launch(window)` | `nvim --listen $TERM_NVIM_SOCKET` during spawn | none | Neovim opens with xplr left pane |
| xplr `h` | xplr internal `Back` | none | none | none | xplr moves back to parent/history |
| xplr `j` | xplr internal `FocusNext` | none | none | none | xplr moves cursor down |
| xplr `k` | xplr internal `FocusPrevious` | none | none | none | xplr moves cursor up |
| xplr `l` / `enter` on directory | xplr internal `Enter` | none | none | none | xplr descends into directory |
| xplr `l` / `enter` on file | `TERM_XPLR_RPC={op:"open",path}`, then xplr internal `Enter` no-op | `xplr_rpc.handle_user_var` -> validate active project/root/socket/path | `v:lua.TermXplrMuxRpc("open", path)` | `next_pane("right")` after `edit` | File opens in project Neovim and focus moves right to editor |
| xplr `H` optional | `TERM_XPLR_RPC={op:"layout",kind:"hide"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "hide")` | `next_pane("right")`, then `resize_pane("left", 80)` | Tree is visually hidden by resizing |
| xplr `R` optional | `TERM_XPLR_RPC={op:"layout",kind:"reveal"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "reveal")` | `next_pane("left")` | Tree is revealed/focused by moving left |
| xplr `N` optional | `TERM_XPLR_RPC={op:"layout",kind:"narrow"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "narrow")` | `next_pane("right")`, then `resize_pane("left", 8)` | Tree narrows |
| xplr `W` optional | `TERM_XPLR_RPC={op:"layout",kind:"wide"}` | validate layout kind + socket | `TermXplrMuxRpc("layout", "wide")` | `next_pane("left")`, then `resize_pane("right", 8)` | Tree widens |
| Palette: `Hide project tree` | `term-xplr-layout-hide` | `events.lua` -> `xplr_rpc.dispatch_layout` | `TermXplrMuxRpc("layout", "hide")` | same as xplr `H` | Same behavior as xplr key |
| Palette: `Reveal project tree` | `term-xplr-layout-reveal` | `events.lua` -> `xplr_rpc.dispatch_layout` | `TermXplrMuxRpc("layout", "reveal")` | same as xplr `R` | Same behavior as xplr key |
| `<C-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits focus traversal | Move across Neovim splits and WezTerm panes |
| `<A-h/j/k/l>` | direct keypress | WezTerm smart-splits adapter when outside Neovim | Neovim smart-splits mapping when inside Neovim | smart-splits resize traversal | Resize active split/pane |

## Validation matrix

| Boundary | Accept | Reject | Where enforced |
|---|---|---|---|
| RPC payload shape | `{op:"open", path:string}` or `{op:"layout", kind:string}` | Empty payload, malformed JSON, unknown `op` | `xplr_rpc.decode_payload` |
| Layout kind | `hide`, `reveal`, `narrow`, `wide` | Anything else, for example `fullscreen` | `xplr_rpc.validate_layout`; CUE check `unknown-layout-kind-rejected` |
| Open path | Existing absolute path inside project root | Relative path, non-existing path, path outside root | `xplr_rpc.validate_open`; CUE check `outside-project-root-rejected` |
| Project contract | Active configured project session with canonical root | Non-project workspace, missing root | `xplr_rpc.contract_for` |
| Neovim socket | Existing socket at `TERM_NVIM_SOCKET` | Missing, empty, stale, not a socket | `xplr_rpc.contract_for`; CUE check `missing-nvim-socket-rejected` |
| Neovim RPC result | `1`, `true`, or `v:true` | Any failed command or false-like return | `xplr_rpc.nvim_accepted` |
| smart-splits backend | `smart-splits.mux.get()` returns active backend in session | Missing plugin, no mux session, failed `next_pane` / `resize_pane` | `workflow/mux_rpc.lua` |

## CUE manifest checks

| Check | Intent | Expected result |
|---|---|---|
| `outside-project-root-rejected` | Open payload outside `/home/_404/src/dotfiles` must not validate | bottoms |
| `unknown-layout-kind-rejected` | Layout kind outside `hide | reveal | narrow | wide` must not validate | bottoms |
| `missing-nvim-socket-rejected` | Dispatch contract with empty socket must not validate | bottoms |

Validation commands:

```bash
cd .github && cue vet ./dotfiles-manifest-slice/contracts/issues/43
cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/43 -e normalizedDotfilesIssueManifest
cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/43 -e dotfilesValidationPlan
cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/43 -e dotfilesCompletionReportContract
cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/43/checks -e '_negativeBottomChecks.outside-project-root-rejected'
cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/43/checks -e '_negativeBottomChecks.unknown-layout-kind-rejected'
cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/43/checks -e '_negativeBottomChecks.missing-nvim-socket-rejected'
```

Issue #45 boundary gate validation:

```bash
cd .github && cue vet ./dotfiles-manifest-slice/contracts/issues/45
cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/45 -e normalizedDotfilesIssueManifest
cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/45 -e dotfilesValidationPlan
cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/45 -e dotfilesCompletionReportContract
cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/45/checks -e '_negativeBottomChecks.neovim-topology-owner-rejected'
cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/45/checks -e '_negativeBottomChecks.xplr-direct-pane-bridge-rejected'
cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/45/checks -e '_negativeBottomChecks.generated-decision-source-rejected'
cd .github && ! rg '[Nn]eovim project picker|[w]orkspace/session topology authority|x[p]lr.*smart-splits|[g]enerated.*authority' ./dotfiles-manifest-slice/contracts/issues/45
```

## Issue #45 Neovim QoL boundary gate

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
| `chezmoi/private_dot_config/xplr/init.lua` | Emits JSON `TERM_XPLR_RPC` intents | tree UI adapter |
| `.github/dotfiles-manifest-slice/contracts/issues/43/manifest.cue` | Issue-local manifest and validation plan | contract workflow |
| `.github/dotfiles-manifest-slice/contracts/issues/43/checks/bottom.cue` | Executable negative bottom checks | contract proof surface |

## Operational cheatsheet

| Task | Command/key | Path |
|---|---|---|
| Pick project workspace | `Alt-s` | WezTerm sessionizer |
| Launch project IDE | Command palette -> `Launch project IDE` | WezTerm controller |
| Move between tree/editor/panes | `<C-h/j/k/l>` | smart-splits |
| Resize active split/pane manually | `<A-h/j/k/l>` | smart-splits |
| Move inside xplr | `h` / `j` / `k` / `l` | xplr local navigation |
| Open focused file from xplr | `l` / `enter` / `right` | xplr -> WezTerm RPC -> Neovim edit -> smart-splits focus |
| Hide tree, optional | xplr `H` or palette `Hide project tree` | xplr/WezTerm -> Neovim mux RPC |
| Reveal tree, optional | xplr `R` or palette `Reveal project tree` | xplr/WezTerm -> Neovim mux RPC |
| Narrow tree, optional | xplr `N` or palette `Narrow project tree` | xplr/WezTerm -> Neovim mux RPC |
| Widen tree, optional | xplr `W` or palette `Widen project tree` | xplr/WezTerm -> Neovim mux RPC |

## Forbidden attractors

| Do not do this | Reason |
|---|---|
| Add a Neovim project picker | Competes with WezTerm sessionizer authority |
| Let xplr call smart-splits directly | xplr is not the Neovim Lua host |
| Reimplement generic pane movement in WezTerm Lua | smart-splits already owns mux mechanics |
| Treat runtime cache as persistent authority | It is evidence/routing state only |
| Encode CUE checks as string metadata | Checks must live in issue-local CUE check package |
| Use generated artifacts as authority | Repo-local workflow and materialized configs are authority surfaces |
| Promote Neovim QoL discovery into project/session topology | Duplicates the WezTerm/sessionizer boundary |

## Runtime smoke sequence

```text
1. Alt-s -> select project.
2. Command palette -> Launch project IDE.
3. Confirm xplr appears left of socket-backed Neovim.
4. In xplr, confirm `h/j/k/l` move back/down/up/enter locally.
5. In xplr, press `l` or `enter` on a file.
6. Confirm file opens in Neovim and focus moves right.
7. Optionally press H/R/N/W in xplr and confirm layout changes.
8. Optionally use palette Hide/Reveal/Narrow/Widen and confirm same path.
9. Use <C-h/j/k/l> and <A-h/j/k/l> from both xplr and Neovim.
```

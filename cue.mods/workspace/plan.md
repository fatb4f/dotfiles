 Recommended Structure

  1. Canonical primitive contract
     Keep this in CUE, likely extending cue.mods/workspace/workspaces.cue.

     Define stable concepts here:
      - workspace/project identity
      - root path
      - labels/tags
      - default shell intent
      - default editor intent
      - terminal/session behavior
      - discovery policy
      - managed vs scratch entries

  2. Tool projections
     Split each consumer into its own projection shape instead of embedding tool details directly into the primitive.

     Suggested CUE layout:

     cue.mods/workspace/
     ├── schema.cue          # #Workspace, #DevStack, #Discovery
     ├── manifest.cue        # concrete workspace declarations
     ├── wezterm.cue         # WezTerm/sessionizer projection
     ├── shell.cue           # shell/env projection
     ├── editor.cue          # nvim/editor projection
     └── output.cue          # exportable generated values

  3. Chezmoi template as materialization, not authority
     A chezmoi template can be the root primitive only operationally, but not semantically.

     Better:
      - CUE owns contract and data.
      - Chezmoi templates read/export generated CUE output.
      - Lua/shell/editor files consume generated values.

     This prevents drift where chezmoi/private_dot_config/wezterm/modules/workspaces.lua becomes the hidden source of truth.

  4. Separate managed workspaces from discovery
     Your draft already does this well:
      - manifest.workspaces for explicit managed primitives.
      - manifest.scratch for discovery inputs like fd, zoxide, history.

     Keep that boundary. Managed entries should be deterministic. Scratch discovery should be best-effort/runtime.

  5. Normalize paths at contract edge
     Decide whether CUE stores:
      - $HOME/src/dotfiles
      - ~/src/dotfiles
      - absolute paths
      - chezmoi-derived home paths

     Recommendation:
      - Store symbolic/user-relative paths in the CUE manifest.
      - Let projections expand for each target.
      - Do not duplicate path expansion logic across Lua, shell, and editor.

  6. Model capability intent, not implementation
     Instead of CUE saying “WezTerm key ALT+s invokes sessionizer”, model:

     session: {
       provider: "wezterm"
       selector: "sessionizer"
       key: {
         mods: "ALT"
         key: "s"
       }
     }

     Then the WezTerm projection maps that to plugin-specific Lua.

  7. Keep editor integration narrow
     The editor primitive should probably describe behavior such as:
      - opens in project root
      - terminal pane split defaults
      - preferred cwd
      - environment variables

     It should not try to fully own Neovim plugin config unless the workspace primitive truly drives that config.

     Current Neovim/WezTerm evidence:
      - `chezmoi/private_dot_config/nvim/lua/plugins/smart-splits.lua` configures `smart-splits.nvim` with `multiplexer_integration = "wezterm"` and emits the WezTerm pane user var `IS_NVIM`.
      - `chezmoi/private_dot_config/wezterm/modules/smart_splits.lua` reads `IS_NVIM` and routes `Ctrl+h/j/k/l` movement and `Alt+h/j/k/l` resizing across Neovim splits or WezTerm panes.
      - `chezmoi/private_dot_config/nvim/lua/config/wezterm-pane.lua` is separate Neovim-owned runtime glue that calls `wezterm cli` for `split-pane`, `activate-pane`, `send-text`, and `kill-pane`.
      - `chezmoi/private_dot_config/nvim/lua/config/keymaps.lua` exposes that pane lifecycle through `<leader>ot` and `<leader>ok`.
      - `chezmoi/private_dot_config/wezterm/modules/scrollback.lua` provides a WezTerm-side `Ctrl+Shift+E` action that opens scrollback in `$EDITOR` or `nvim`.

     Projection implication:
      - workspace CUE may describe terminal pane defaults, cwd inheritance, and workspace-aware editor commands.
      - Neovim plugin setup, `IS_NVIM` signaling, and `wezterm cli` pane lifecycle should stay Lua/runtime implementation glue unless workspace data directly drives a field.

  8. Add validation fixtures early
     Add small fixture exports for:
      - one managed workspace
      - scratch-only discovery
      - disabled discovery providers
      - invalid workspace id
      - missing root
      - duplicate projected workspace names if CUE can detect them

  9. Define export surfaces explicitly
     Good initial export targets:
      - weztermWorkspaces
      - weztermSessionizerConfig
      - shellWorkspaceEnv
      - editorWorkspaceDefaults

     This keeps consumers from importing the whole manifest and depending on internal shape.

  10. Avoid coupling this to Hookrail unless needed
     This looks like a general dev-stack/workspace primitive, not necessarily Hookrail. Keep it in cue.mods/workspace unless it needs Hookrail feed/projection semantics.

  Practical Next Step
  Start by renaming the current draft into a three-part CUE shape:

  schema.cue     # reusable contract
  manifest.cue   # concrete dotfiles workspace + scratch discovery
  wezterm.cue    # projection matching current WezTerm module needs

  Matrix View

  | Layer | Authority | Owns | Consumers | Output | Validation |
  |---|---|---|---|---|---|
  | Primitive contract | schema.cue | Workspace identity, root, labels, dev-stack intent, discovery policy | manifest.cue, projections | Reusable CUE definitions | cue vet/export schema fixtures |
  | Concrete manifest | manifest.cue | Managed workspaces, scratch discovery roots, excludes, enabled providers | wezterm.cue, shell.cue, editor.cue | Canonical workspace data | cue export manifest |
  | WezTerm projection | wezterm.cue | Sessionizer entries, workspace names, key/action intent, discovery adapters | workspaces.lua template/module | WezTerm-ready config data | cue export wezterm projection |
  | Shell projection | shell.cue | Environment variables, login shell behavior, project-root exports | shell templates, launcher wrappers | Shell-ready env/config data | shellcheck rendered scripts |
  | Editor projection | editor.cue | Editor cwd defaults, terminal pane defaults, workspace-aware commands | Neovim Lua/templates | Editor-ready config data | nvim/lua smoke checks |
  | Chezmoi materialization | chezmoi templates | Rendered files only; no semantic authority | local dotfiles | Lua/shell/config files | chezmoi diff/apply preview |

  Decision Rule

  | Question | Put It In |
  |---|---|
  | Is this a stable workspace/dev-stack concept? | schema.cue |
  | Is this a concrete personal workspace or discovery root? | manifest.cue |
  | Is this a tool-specific adaptation of the primitive? | wezterm.cue, shell.cue, or editor.cue |
  | Is this runtime implementation glue? | Lua/shell/editor source |
  | Is this only rendering generated config into place? | chezmoi template |

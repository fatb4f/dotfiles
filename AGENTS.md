# AGENTS.md

Root router only.

## RALPH Lifecycle Contract

The intended RALPH lifecycle is root-contract driven:

1. `AGENTS.cue` is the repository node contract when it exists.
2. `AGENTS.md` states protocol and routing only; use it as natural-language overlay, not as the authority over CUE.
3. File loads require CUE authorization evidence: selected node, selected pattern, explicit index, or root-declared fallback surface.
4. Adapters and MCP tools may emit evidence, but they must not create hidden authorization policy.
5. Record loaded files, denied loads, required MCP/tool use, and validation evidence before close-out.

## First-Contact Discovery Guard

When a task concerns cards, projections, or rediscovery-replacement records:

1. Start from `cue/patterns/domain/schema.cue` and `cue/patterns/projections/codex-slice.cue`.
2. Treat `cue/patterns/domain/*.cue` and `cue/patterns/projections/*.cue` as the authority for card and projection shape.
3. Load only the selected card(s) and the selected projection(s) needed for the task.
4. Treat nested `AGENTS.md` files as fallback landmarks, not mandatory discovery targets.
5. Do not recurse through `AGENTS.md` files or search nearby legacy modules for authority unless the selected card explicitly points there.

## Repo map

```text
dotfiles repo
├── dotfile lifecycle
│   └── chezmoi/
│
├── Codex runtime / Hookrail
│   ├── cue.mods/hookrail/      # contracts, feeds, projections
│   └── shell-wrap/src/hookrail/ # shell/Bashly execution adapters
│
└── shell adapter substrate
    └── shell-wrap/             # Bashly pattern mechanics
```

## Routing

Pick one row. Load one starting authority. Do not recurse.

| Task pattern                                  | Start here             | Skill task                                                                                                                   |
| --------------------------------------------- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| cards / projections / rediscovery records     | `cue/patterns/domain/schema.cue` and `cue/patterns/projections/codex-slice.cue` | domain-local                                                                                                                 |
| chezmoi dotfile lifecycle                     | `chezmoi/AGENTS.md`    | `chezmoi-workflow`                                                                                                           |
| Hookrail contracts / feeds / projections      | `cue.mods/AGENTS.md`   | domain-local                                                                                                                 |
| Bashly / shell wrappers / executable adapters | `shell-wrap/AGENTS.md` | domain-local                                                                                                                 |
| Git state discovery                           | root                   | `git-workflow: git.discovery`                                                                                                |
| repo close-out                                | root                   | `git-workflow: git.discovery` → selected-domain closeout → `git-workflow: git.closeout` |

## Limits

* Do not scan the repo broadly.
* Do not recursively read `AGENTS.md`.
* Do not inspect unrelated domains.
* Do not expand `authority/` unless explicitly requested.
* Do not compare against legacy frame systems.
* Skip `git.closeout` only when the user explicitly requests observation-only close-out or no commit.

## Fallback starts

Use only when the domain `AGENTS.md` file does not exist.

| Domain        | Fallback                                 |
| ------------- | ---------------------------------------- |
| `chezmoi/`    | nearest touched file in `chezmoi/`       |
| `cue.mods/`   | `cue.mods/hookrail/projection.cue`       |
| `shell-wrap/` | `shell-wrap/src/hookrail/src/bashly.yml` |

## Stop

Stop after the routed task or close-out report.

## Close-out

git-mcp-server.git_status
git-mcp-server.git_diff_unstaged
git-mcp-server.git_diff_staged
git-mcp-server.git_add
git-mcp-server.git_commit
git-mcp-server.git_status

chezmoi status
chezmoi diff
chezmoi apply

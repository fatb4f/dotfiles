# AGENTS.md

Root router only.

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

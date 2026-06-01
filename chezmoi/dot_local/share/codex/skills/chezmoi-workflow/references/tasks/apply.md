# Task: chezmoi.apply

Materialize chezmoi source changes to target files.

Use only when the user explicitly requests apply/materialization after source changes or after `chezmoi.apply-preview`.

## Commands

Required:

```sh
chezmoi status
chezmoi diff
chezmoi apply --no-tty <target-path>
chezmoi status
chezmoi diff
```

Optional:

```sh
chezmoi target-path <source-or-target-path>
chezmoi source-path <target-path>
```

## Procedure

1. Run `chezmoi status`.
2. Run `chezmoi diff` for the bounded target or task scope.
3. Confirm the diff is task-scoped.
4. Confirm there is no unrelated target drift.
5. Run `chezmoi apply --no-tty <target-path>`.
6. If chezmoi refuses because the target changed since last write, stop.
7. Run `chezmoi status`.
8. Run `chezmoi diff`.
9. Report materialized files and remaining drift.

## Rules

- Do not run unbounded `chezmoi apply` by default.
- Do not run `chezmoi apply` without a target path unless the user explicitly requests full apply.
- Do not use `--force` unless the user explicitly authorizes overwriting target-side changes.
- Never use `--force` to resolve chezmoi target drift unless the user explicitly says: "overwrite the target despite local target changes."
- Do not use an alternate `--persistent-state` for real materialization.
- Never redirect chezmoi persistent state for real materialization.
- Do not bypass chezmoi's last-written safety state.
- Do not edit rendered target files manually.
- Do not stage or commit.
- If chezmoi needs a TTY for conflict resolution, stop and report the conflict.
- If the real chezmoi state database is inaccessible, stop and report blocked materialization.

## Blockers

Block apply when:

- target file changed since chezmoi last wrote it
- chezmoi asks for interactive conflict resolution
- real persistent state is inaccessible
- diff includes unrelated paths
- target path is ambiguous
- user requested preview only

## Output

Report:

- target path applied
- source path, if known
- pre-apply diff summary
- post-apply status
- remaining drift
- blockers, if any

## Stop condition

Stop after successful bounded apply and post-apply status/diff, or after reporting the blocker.

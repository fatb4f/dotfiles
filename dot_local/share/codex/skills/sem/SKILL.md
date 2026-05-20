---
name: sem
description: Use sem for deterministic semantic repository intelligence before broad code inspection. Trigger for entity-level diffs, changed functions/classes/methods, symbol context, impact/blast-radius checks, blame, history, and focused code-context extraction.
---

# Sem Repository Intelligence Skill

## Contract

Use `sem` as the semantic code-intelligence adapter.

Prefer `sem` when the task asks:

- what changed semantically
- which functions/classes/methods were modified
- what depends on a symbol
- what a symbol depends on
- where a symbol changed over time
- entity-level blame/history
- focused context for a named entity
- blast radius of staged or working-tree changes

Do not use `sem` as a general-purpose crawler.

## Binary

Prefer the explicitly installed binary:

```sh
SEM_BIN="${SEM_BIN:-$HOME/.local/bin/sem}"
SEM_DIFF="${SEM_DIFF:-$HOME/.local/bin/sem-diff-wrapper}"
```

Fallback only when safe:

```sh
command -v "$SEM_BIN" >/dev/null 2>&1 || SEM_BIN="$(command -v sem 2>/dev/null || true)"
```

Before relying on `sem`, verify that it is the Ataraxy Labs `sem`, not GNU Parallel's `sem` shim:

```sh
"$SEM_BIN" --version
```

GNU Parallel can also provide a `sem` binary, so do not assume `sem` on PATH is the intended tool.

## Operating rules

1. Run only inside a specific Git repository.
2. Never run from `$HOME` as the repository root.
3. Prefer exact files, symbols, and ranges.
4. Prefer JSON output for machine-readable frames.
5. Write generated intelligence to `.codex/frames/`.
6. Do not run `sem setup` unless explicitly requested by the user.
7. Do not replace `git diff` globally as part of normal agent work.
8. Do not use `sem` to compensate for an underspecified task; ask for a narrower slice.
9. When used as commit evidence, stage the intended changeset first and feed only `git diff --cached` into `sem`.

## Command map

### Staged semantic diff

Use after staging an intended changeset.

```sh
git diff --cached | "$SEM_BIN" diff --patch --format json
git diff --cached | "$SEM_BIN" diff --patch --format markdown
```

### Commit-range semantic diff

Use when comparing accepted slices.

```sh
"$SEM_BIN" diff --from HEAD~5 --to HEAD --format json
```

### Entity listing

Use instead of broad source crawling when mapping code structure.

```sh
"$SEM_BIN" entities --json
```

For a specific file or subtree:

```sh
"$SEM_BIN" entities path/to/file_or_dir --json
```

### Entity context

Use when a symbol, function, class, method, module, or config entity is named.

```sh
"$SEM_BIN" context SYMBOL --budget 4000
"$SEM_BIN" context SYMBOL --budget 4000
```

### Impact / blast radius

Use before modifying a named symbol or after a semantic diff identifies changed entities.

```sh
"$SEM_BIN" impact SYMBOL --json
```

Direct dependencies only:

```sh
"$SEM_BIN" impact SYMBOL --deps --json
```

Direct dependents only:

```sh
"$SEM_BIN" impact SYMBOL --dependents --json
```

Tests only:

```sh
"$SEM_BIN" impact SYMBOL --tests --json
```

Disambiguate by file when needed:

```sh
"$SEM_BIN" impact SYMBOL --file path/to/file --json
```

### Entity blame

Use when the user asks who/what last changed a function, class, or method.

```sh
"$SEM_BIN" blame path/to/file --json
```

### Entity history

Use when the user asks how a symbol evolved.

```sh
"$SEM_BIN" log SYMBOL --limit 20 --json
```

Verbose history only when explicitly needed:

```sh
"$SEM_BIN" log SYMBOL --limit 20 -v
```

## Integration with repo-intel

When `repo-intel refresh` runs, use `sem` only if available and verified.

Recommended frame outputs:

```txt
.codex/frames/sem-diff.json
.codex/frames/sem-diff.md
.codex/frames/sem-entities.json
.codex/frames/sem-summary.md
```

Minimal summary generation:

```sh
mkdir -p .codex/frames

if [ -x "${SEM_BIN:-$HOME/.local/bin/sem}" ]; then
  SEM_BIN="${SEM_BIN:-$HOME/.local/bin/sem}"

  "$SEM_BIN" diff --format json > .codex/frames/sem-diff.json 2>/dev/null || true
  "$SEM_BIN" diff --format markdown > .codex/frames/sem-diff.md 2>/dev/null || true
  "$SEM_BIN" entities --json > .codex/frames/sem-entities.json 2>/dev/null || true

  {
    printf '# Sem frame

'
    printf '## Semantic diff

'
    sed -n '1,120p' .codex/frames/sem-diff.md 2>/dev/null || true
    printf '

'
    printf '## Entity index

'
    if command -v jq >/dev/null 2>&1 && [ -s .codex/frames/sem-entities.json ]; then
      jq -r '
        if type == "array" then .[] else . end
        | select(type == "object")
        | "- `" + ((.filePath // .path // "unknown")|tostring) + "` "
          + ((.entityType // .kind // "entity")|tostring)
          + " `" + ((.entityName // .name // "unknown")|tostring) + "`"
      ' .codex/frames/sem-entities.json 2>/dev/null | sed -n '1,120p'
    else
      printf -- '- sem entities captured; jq unavailable or JSON shape unknown
'
    fi
  } > .codex/frames/sem-summary.md
fi
```

## Guarded Commit Use

When a commit gate uses `sem`, treat the output as evidence only.

1. Stage the intended pathspecs explicitly.
2. Generate semantic evidence from `git diff --cached`.
3. Wrap the raw `sem` output in adapter-owned JSON.
4. Vet the wrapped envelope with CUE before commit or push is allowed.

## When to use this skill

Use this skill before broad source inspection when the task involves code structure.

Examples:

```txt
Review current changes semantically.
What functions changed in this slice?
Find the blast radius of update_profile_config.
Get focused context for render_domain.
```

# Git Grep Reference

Use this reference only after selecting the Git-state search lane.

`git grep` is for Git's repository view: tracked files in the working tree, blobs registered in the index, or blobs in named tree objects such as commits, branches, and tags. It is not the default live-filesystem search tool.

## Capability Gate

Use `git grep` only if Git exists and the current directory is inside a worktree:

```bash
command -v git >/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1
```

Failure contract:

- If `git` is missing, do not use this lane.
- If the directory is not a Git worktree, do not use this lane.
- If the requested evidence is live filesystem text, fall back to `rg`.
- If the requested evidence is staged/index/tree-specific, there is no equivalent fallback; report that the Git-state view could not be verified.

## Selection Contract

| Need | Command shape | Fallback |
|---|---|---|
| Search tracked files in the working tree | `git grep -n --no-color -e 'pattern' -- pathspec...` | `rg` only if tracked-only semantics are not required. |
| Search staged/index content | `git grep -n --no-color --cached -e 'pattern' -- pathspec...` | No equivalent without Git. |
| Search current commit/tree | `git grep -n --no-color -e 'pattern' HEAD -- pathspec...` | No equivalent without Git. |
| Search branch, tag, or commit | `git grep -n --no-color -e 'pattern' <tree> -- pathspec...` | No equivalent without Git. |
| Search with Git pathspec exclusions | `git grep -n --no-color -e 'pattern' -- ':(exclude)vendor' '*.sh'` | Approximate with `rg -g`, but pathspec semantics differ. |
| List matching tracked files | `git grep -l --no-color -e 'pattern' -- pathspec...` | `rg -l` only if live-filesystem semantics are acceptable. |
| Count matches per tracked file | `git grep -c --no-color -e 'pattern' -- pathspec...` | `rg -c` only if live-filesystem semantics are acceptable. |

Use `rg` instead when the target is the live filesystem and untracked files may matter.

## Safe Defaults

```bash
git grep -n --no-color -e 'pattern' -- src/ tests/
```

Default flags:

- `-n`: include line numbers.
- `--no-color`: keep output parseable in Codex context.
- `-e`: protect patterns that begin with `-` and make multiple patterns explicit.
- `--`: separate options/tree arguments from pathspecs.

## Worktree, Index, and Tree Semantics

### Tracked working-tree search

```bash
git grep -n --no-color -e 'SessionManager' -- src/ tests/
```

This searches tracked paths in the working tree. It sees unstaged edits to tracked files, but it does not normally include untracked scratch files.

Use when untracked local files should not influence the result.

### Staged/index search

```bash
git grep -n --no-color --cached -e 'SessionManager' -- src/
```

This searches the index. It answers “what is staged or registered in Git's index?”, not “what is on disk?”.

Use for review gates, pre-commit checks, or questions about staged content.

### Current commit/tree search

```bash
git grep -n --no-color -e 'SessionManager' HEAD -- src/
```

This searches the `HEAD` tree, ignoring unstaged and staged-but-uncommitted changes.

Use to compare current disk/index evidence against committed evidence.

### Branch, tag, or commit search

```bash
git grep -n --no-color -e 'SessionManager' main -- src/
git grep -n --no-color -e 'SessionManager' v1.2.0 -- src/
git grep -n --no-color -e 'SessionManager' abc1234 -- src/
```

Use for historical or alternate-tree questions.

## Pattern Recipes

### Multiple alternatives

```bash
git grep -n --no-color \
  -e 'SessionManager' \
  -e 'session_manager' \
  -e 'session-manager' \
  -- src/ tests/
```

Repeated `-e` patterns are ORed by default.

### Require all concepts in the same file

```bash
git grep -n --no-color --all-match \
  -e 'SessionManager' \
  -e 'shutdown' \
  -- src/
```

Use when looking for files that contain all concepts somewhere in the same file. This does not prove the concepts are in the same function or block; read candidate ranges to verify.

### Count before drilling down

```bash
git grep -c --no-color -e 'deprecatedApi' -- src/
```

If many files match, refine pathspecs or add more specific terms before reading files.

### List matching files only

```bash
git grep -l --no-color -e 'deprecatedApi' -- src/
```

Use to identify candidate files before targeted reads.

### Search with local context

```bash
git grep -n --no-color -C 2 -e 'deprecatedApi' -- src/
```

Use context only when surrounding code is needed to interpret matches.

### Show function context

```bash
git grep -n --no-color -W -e 'deprecatedApi' -- src/
```

Use `-W` when the whole surrounding function is more useful than isolated lines.

### Fixed string search

```bash
git grep -n --no-color -F -e 'literal.string.with[chars]' -- src/
```

Use `-F` when the query is not meant as a regex.

### Case-insensitive search

```bash
git grep -n --no-color -i -e 'sessionmanager' -- src/
```

Use only when casing is uncertain; otherwise keep exact matching.

### Word-boundary search

```bash
git grep -n --no-color -w -e 'Lock' -- src/
```

Use when short identifiers produce too many substring matches.

## Pathspec Patterns

Git pathspecs are not shell globs. Quote them so the shell does not expand them before Git sees them.

### Include by extension

```bash
git grep -n --no-color -e 'pattern' -- '*.sh' '*.bash'
```

### Exclude generated or vendor trees

```bash
git grep -n --no-color -e 'pattern' -- \
  ':(exclude)vendor' \
  ':(exclude)dist' \
  ':(exclude)node_modules' \
  '*.ts' '*.tsx'
```

### Search a subdirectory only

```bash
git grep -n --no-color -e 'pattern' -- src/ tests/
```

### Avoid ambiguous tree/path parsing

Always include `--` before pathspecs when a command includes options, tree-ish values, or path-like names:

```bash
git grep -n --no-color -e 'pattern' HEAD -- src/
```

## Submodules

Search active checked-out submodules only when submodule content is explicitly relevant:

```bash
git grep -n --no-color --recurse-submodules -e 'pattern' -- src/
```

Do not enable submodule recursion by default; it can expand scope and cost unexpectedly.

## Binary and Generated Files

`git grep` follows Git's tracked view, so generated files may appear if they are tracked. Scope pathspecs aggressively when generated tracked files are noisy.

If the target is ignored generated output that is not tracked, use `rg` with explicit ignore overrides instead of `git grep`.

## Interpreting No Results

No results from `git grep` means no matches in the selected Git projection, not necessarily no matches anywhere.

Examples:

- `git grep pattern -- src/`: no match in tracked working-tree files under `src/`.
- `git grep --cached pattern -- src/`: no match in the index under `src/`.
- `git grep pattern HEAD -- src/`: no match in the committed `HEAD` tree under `src/`.

If untracked files may matter, run an `rg` live-filesystem search separately.

## `rg` vs `git grep` Comparison

| Question | Use |
|---|---|
| “Where is this string in files as they exist right now?” | `rg` |
| “Where is this string in tracked files only?” | `git grep` |
| “Where is this string in staged content?” | `git grep --cached` |
| “Where was this string in `HEAD` or `main`?” | `git grep <tree>` |
| “Can ignored/untracked scratch files affect the answer?” | `rg` |
| “Do Git pathspec exclusions matter?” | `git grep` |

## Pitfalls

- Do not use `git grep` when untracked files are relevant; use `rg` first.
- Do not use `git grep --no-index` as the normal non-Git fallback; use `rg`.
- Do not omit `--` before pathspecs when patterns, tree-ish values, or pathspecs may be ambiguous.
- Do not treat `git grep --cached` as a staged-diff search; it searches index blobs, not only changed lines.
- Do not run state-changing Git commands from this skill.
- Avoid pagers and color output in Codex command output.

## Output Shape

Tracked working-tree search:

```text
path/to/file.ext:42:matching line text
```

Tree search may prefix results with the tree-ish:

```text
HEAD:path/to/file.ext:42:matching line text
```

Use these paths and line numbers to read only the relevant files or ranges.

## Router Summary

```text
Need tracked-only?       -> git grep
Need staged/index?       -> git grep --cached
Need historical tree?    -> git grep <tree>
Need Git pathspecs?      -> git grep -- <pathspec>
Need live untracked too? -> rg, unless explicitly choosing git grep --untracked
Git unavailable?         -> rg for live text only; no index/tree equivalent
```

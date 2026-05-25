# Optional Tool Fallbacks

Use this reference when a selected search lane depends on an optional binary that may not exist in the current Codex environment.

## Contract

- Do not install tools from this skill.
- Do not silently substitute a weaker tool while preserving the stronger claim.
- A fallback must say which evidence view was actually searched.
- If no safe equivalent exists, report the missing capability and continue with candidate discovery only when useful.

## Capability Probe Pattern

Use `command -v` before relying on an optional lane when availability is unknown:

```bash
command -v fd >/dev/null
command -v sg >/dev/null
command -v semgrep >/dev/null
command -v rga >/dev/null
command -v tokei >/dev/null
command -v scc >/dev/null
command -v git >/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1
```

Avoid verbose version probes unless the version itself matters.

## Fallback Matrix

| Missing tool | Intended evidence | Preferred fallback | Claim allowed |
|---|---|---|---|
| `git` / not a worktree | tracked/index/tree search | `rg` for live text only | “searched live files”; not “searched staged/tree”. |
| `fd` | path discovery | `rg --files`; then `find` if path semantics require it | “found candidate paths”. |
| `sg` | AST/syntax shape | `rg` candidate search + targeted reads | “textual candidates”; not “AST-confirmed”. |
| `semgrep` | rule/security/taint scan | `rg`/`sg` candidate search | “candidate evidence”; not “rule evaluated”. |
| `rga` | PDFs/docs/archives | `rg` plain-text search | “plain text searched”; not “PDF/archive searched”. |
| `tokei` | language LOC summary | `scc` if available; else rough `rg --files` counts | “rough counts” unless metrics tool ran. |
| `scc` | complexity/COCOMO metrics | `tokei` for LOC only | “line/language counts”; not “complexity/COCOMO”. |

## Fallback Recipes

### `fd` → `rg --files`

Original:

```bash
fd -g '*.test.ts'
```

Fallback:

```bash
rg --files -g '*.test.ts'
```

For regex-like path queries:

```bash
rg --files | rg '(^|/)config|settings'
```

Use `find` only when needed:

```bash
find . -path './.git' -prune -o -name '*_test.go' -print
```

### `sg` → `rg` candidates

Original:

```bash
sg --lang ts --pattern 'useEffect($$$)'
```

Fallback:

```bash
rg -n --no-heading 'useEffect\s*\(' -t ts -t tsx src/
```

Then read relevant ranges and manually verify the syntax structure.

### `semgrep` → candidate discovery

Original:

```bash
semgrep --config p/security-audit src/
```

Fallback approach:

```bash
rg -n --no-heading 'eval\(|exec\(|child_process|subprocess|pickle\.loads|yaml\.load' src/ tests/
```

This is not a rule-pack result. It only discovers suspicious candidates.

### `rga` → plain-text `rg`

Original:

```bash
rga 'interface Foo' artifacts/
```

Fallback:

```bash
rg -n --no-heading 'interface Foo' artifacts/
```

Boundary statement: this does not search inside PDFs, Office docs, ebooks, or compressed archives unless those contents are already extracted as text files.

### `tokei` / `scc` → rough counts

Original:

```bash
tokei --sort code
scc --wide
```

Fallback:

```bash
rg --files | wc -l
rg --files -g '*.go' | wc -l
rg --files -g '*.ts' -g '*.tsx' | wc -l
```

This is file counting, not LOC, language classification, complexity, or COCOMO evidence.

## Reporting Pattern

When a fallback changes evidence strength, include the boundary in the result:

```text
`semgrep` is unavailable, so I used `rg` to find candidate sink/source patterns. This is not a semantic taint scan.
```

```text
`git grep --cached` could not run because this is not a Git worktree. I searched live files with `rg`, but staged/index evidence is unavailable.
```

```text
`rga` is unavailable, so PDFs and archives were not searched; only plain text files under `docs/` were checked.
```

## Do Not Fallback Across These Boundaries

- Do not replace `git grep --cached` with `rg` and claim staged evidence.
- Do not replace `semgrep` with `rg` and claim security-rule coverage.
- Do not replace `sg` with `rg` and claim AST matching.
- Do not replace `rga` with `rg` and claim document/archive coverage.
- Do not replace `scc` with `tokei` and claim complexity or COCOMO metrics.

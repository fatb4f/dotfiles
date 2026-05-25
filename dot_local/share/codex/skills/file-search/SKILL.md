---
name: file-search
description: "Use for local repository search and context discovery in Codex: ripgrep text search, git grep tracked/index/tree search, fd path discovery, ast-grep structural search, semgrep rule search, ripgrep-all document/archive search, and code metrics. Trigger before broad file reads, manual grep/find loops, or context-gathering for debugging, review, refactors, and implementation planning."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires rg. Optional lanes: git, fd, ast-grep/sg, rga, tokei, scc, semgrep. Optional lanes must degrade cleanly when unavailable."
metadata:
  author: Netresearch DTT GmbH; refactored for OpenAI Codex routing
  version: "1.7.1-codex"
  repository: https://github.com/netresearch/file-search-skill
---

# File Search

Search local repositories with the narrowest tool that matches the requested evidence view.

This is a Codex skill. Keep it instruction-first, repo-local, and read-only. Do not use Claude-only metadata such as `allowed-tools`. Do not assume a wrapper, MCP server, or approval policy unless the active Codex environment already provides one.

## Contract

- Stay read-only: do not modify files, stage changes, commit, delete, or run formatters from this skill.
- Prefer targeted command output over broad file reads.
- Start narrow: exact terms, symbols, paths, file types, or directories before whole-repo scans.
- Select the tool by evidence view, not habit.
- Use `rg` as the default live-filesystem text search.
- Use `git grep` only when Git's repository view matters: tracked files, staged/index blobs, commits, branches, tags, trees, or Git pathspecs.
- Treat every non-`rg` tool as opportunistic unless availability has already been proven in the current environment.
- If an optional tool is missing, fall back to the closest read-only lane and explicitly preserve the evidence boundary: say what was searched and what could not be verified.
- Read detailed references only after selecting that lane.

## Capability Model

`rg` is the hard dependency. Everything else is an accelerator or a more precise evidence projection.

Before first use of an optional lane, either rely on prior evidence from the session or probe cheaply:

```bash
command -v git >/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1
command -v fd >/dev/null
command -v sg >/dev/null
command -v semgrep >/dev/null
command -v rga >/dev/null
command -v tokei >/dev/null
command -v scc >/dev/null
```

Do not run a long installation, package-manager command, or formatter from this skill.

## Tool Router

| Evidence needed | First tool | Fallback if missing | Boundary |
|---|---|---|---|
| Current filesystem text | `rg` | none; this skill requires `rg` | Live checkout content. |
| Git tracked/index/tree text | `git grep` | `rg` for live text only; no equivalent for index/tree if Git is missing or not a repo | Git's tracked, staged, or historical view. |
| File/path discovery | `fd` | `rg --files`, then `find` only if needed | Path inventory, not content proof. |
| Syntax-shaped code pattern | `sg` | `rg` approximation, then targeted reads | Candidate evidence only; AST shape is unverified. |
| Rule-pack/security/taint pattern | `semgrep` | `rg`/`sg` for candidate discovery; report that rule scan was not run | No equivalent for semantic/taint proof. |
| PDFs, Office docs, archives | `rga` | `rg` for plain text files only; report binary/document content unsearched | Extracted document/archive content. |
| Language or line-count summary | `tokei` | `scc`, else rough `rg --files`/shell counts | Metrics are approximate unless a metrics tool ran. |
| Complexity/COCOMO metrics | `scc` | `tokei` for basic counts only | Complexity/COCOMO unavailable without `scc`. |

Decision shape:

```text
Need Git's tracked/index/tree view? -> git grep if Git/repo available; otherwise no equivalent, use rg only for live text
Need live text in current files?     -> rg
Need filenames/paths?               -> fd if present, else rg --files
Need AST/syntax shape?              -> sg if present, else rg candidates
Need semantic rule/taint scan?      -> semgrep if present, else candidate search only
Need docs/archives/PDFs?            -> rga if present, else plain-text rg only
Need code metrics?                  -> tokei or scc if present, else rough counts only
```

Detailed fallback guidance: [references/tool-fallbacks.md](references/tool-fallbacks.md).

## Default Lane: `rg`

Use `rg` for ordinary source text search in the current checkout.

```bash
rg -n --no-heading 'def \w+\(' -t py src/
rg -n --no-heading -C 2 'TODO|FIXME' -t js
rg -c --no-heading 'deprecatedApi' src/ tests/
rg --json -n 'error boundary' packages/
```

Prefer `rg` when:

- the user asks what exists now in the working tree;
- untracked local files may matter;
- ignored/generated files should stay ignored by default;
- file types, globs, and directories are enough to scope the query.

Common escalation:

```bash
rg -n --no-heading 'symbolName' src/ tests/
rg -n --no-heading -F 'literal.string.with[chars]' src/
rg -n --no-heading -i 'case uncertain phrase' docs/ src/
rg -l --no-heading 'symbolName' src/
```

If `rg` itself is missing, do not silently degrade to a large recursive `grep`. State that the hard dependency is unavailable and use targeted reads/globs only if the task can still be completed safely.

## Git-State Lane: `git grep`

Use `git grep` when the question is about Git's view of the repository instead of the raw filesystem.

Capability gate:

```bash
command -v git >/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1
```

Common forms:

```bash
git grep -n --no-color -e 'pattern' -- src/ tests/
git grep -n --no-color --cached -e 'pattern' -- src/
git grep -n --no-color -e 'pattern' HEAD -- src/
git grep -n --no-color -e 'pattern' main -- ':(exclude)vendor' '*.sh'
```

Use this lane for:

- tracked-only searches that should ignore untracked scratch files;
- staged/index searches with `--cached`;
- historical or alternate-tree searches against `HEAD`, a branch, a tag, or a commit;
- Git pathspec semantics, including exclusions;
- questions like “is this staged?”, “where did this exist in HEAD?”, or “search only tracked files”.

Fallback rule:

- If Git is unavailable or the directory is not a Git worktree, use `rg` only for live filesystem text.
- If the requested evidence is staged/index/tree-specific, report that the Git-state view could not be verified because there is no equivalent `rg` fallback.
- Do not replace normal live checkout search with `git grep`.

Detailed recipes: [references/git-grep.md](references/git-grep.md).

## Path Discovery Lane: `fd`

Use `fd` when the target is a path or filename, not file content.

```bash
fd -g '*.test.ts'
fd -g '*_test.go'
fd -E node_modules -E dist 'config|settings'
fd -g '*.go' -X rg -n --no-heading 'func Test'
```

Fallbacks when `fd` is missing:

```bash
rg --files -g '*.test.ts'
rg --files | rg '(^|/)config|settings'
find . -path './.git' -prune -o -name '*_test.go' -print
```

Prefer `rg --files` before `find` because it respects ignore behavior closer to `rg` searches. Use `find` only when path semantics require it or `rg --files` is insufficient.

Notes:

- Use `fd -g` for compound suffixes such as `*.test.ts`.
- Quote globs so the shell does not expand them before `fd` sees them.
- Pipe or `-X` into `rg` only after path discovery is useful.

## Structural Lane: `sg`

Use `sg`/ast-grep when matching syntax shape rather than text.

```bash
sg --lang js --pattern 'console.log($$$)'
sg --lang ts --pattern 'useEffect($$$)'
sg --lang py --pattern 'except Exception as $E: $$$'
```

Escalate from `rg` to `sg` when textual results are noisy because of formatting, nesting, or language syntax.

Fallback when `sg` is missing:

- Use `rg` to find candidate symbols, calls, keywords, or imports.
- Read the smallest relevant ranges and manually verify syntax shape.
- Mark the result as “textual candidate search” rather than AST-confirmed evidence.

Example fallback:

```bash
rg -n --no-heading 'console\.log\(' -t js -t ts src/
```

## Rule Scan Lane: `semgrep`

Use `semgrep` for reusable rule packs, taint/security queries, or semantic linting.

```bash
semgrep --config auto src/
semgrep --config p/security-audit src/
```

Do not use `semgrep` as a default grep replacement. Use it when rule semantics are part of the requested evidence.

Fallback when `semgrep` is missing:

- Use `rg` or `sg` to find candidate APIs, sinks, sources, imports, or suspicious patterns.
- Do not claim a security or taint rule was evaluated.
- State that semantic rule evidence is unavailable without `semgrep`.

## Documents and Archives Lane: `rga`

Use `rga` when the target may be inside PDFs, Office docs, ebooks, compressed archives, or other extractable formats.

```bash
rga 'quarterly revenue' docs/
rga 'interface Foo' artifacts/
```

Fallback when `rga` is missing:

- Use `rg` for plain text files in the same directories.
- Do not claim PDFs, Office docs, archives, or binary document formats were searched.
- If the task depends on those formats, report the missing capability rather than pretending text search is equivalent.

```bash
rg -n --no-heading 'quarterly revenue' docs/
```

## Metrics Lane: `tokei` / `scc`

Use `tokei` for language and line-count summaries.

```bash
tokei --sort code
```

Use `scc` for complexity, estimate, or COCOMO-style metrics.

```bash
scc --wide
```

Fallbacks:

- If `tokei` is missing but `scc` exists, use `scc` for summary counts.
- If `scc` is missing but `tokei` exists, use `tokei` but do not claim complexity/COCOMO metrics.
- If both are missing, use rough file counts only, not language-aware metrics.

```bash
rg --files | wc -l
rg --files -g '*.go' | wc -l
rg --files -g '*.ts' -g '*.tsx' | wc -l
```

## Search Discipline

1. Identify the evidence view first: live filesystem, Git state, paths, AST, rules, documents, or metrics.
2. Check optional-tool availability before relying on optional lanes.
3. Scope by directory or extension before scanning the whole repository.
4. Use counts when result volume is unknown: `rg -c`, `git grep -c`, `fd | wc -l`, `rg --files | wc -l`.
5. Prefer repeated `-e` patterns over many sequential command invocations.
6. Keep output parseable: line numbers, no color, no pager.
7. Read only the files or line ranges supported by search results.
8. If local search produces no evidence and comments point outward, hand off to the appropriate remote-context tool.

## Remote Context Handoff

This skill is for local and repo-scoped search. If local evidence points to external context, use the appropriate remote tool outside this skill: GitHub/gh, issue tracker, docs, web, or project-specific search.

Signals for handoff:

- issue keys or PR numbers in comments;
- URLs in source or docs;
- generated code pointing to external schema/docs;
- references to packages or APIs not present in the checkout.

See [references/remote-handoff.md](references/remote-handoff.md).

## References

| Topic | File |
|---|---|
| Optional tool availability and fallback matrix | [references/tool-fallbacks.md](references/tool-fallbacks.md) |
| Git tracked/index/tree search | [references/git-grep.md](references/git-grep.md) |
| rg flags, patterns, recipes | [references/ripgrep-patterns.md](references/ripgrep-patterns.md) |
| ast-grep patterns by language | [references/ast-grep-patterns.md](references/ast-grep-patterns.md) |
| semgrep rules and taint mode | [references/semgrep-patterns.md](references/semgrep-patterns.md) |
| fd flags, usage, fd+rg combos | [references/fd-guide.md](references/fd-guide.md) |
| rga formats, usage, caching | [references/rga-guide.md](references/rga-guide.md) |
| tokei and scc usage | [references/code-metrics.md](references/code-metrics.md) |
| Search targeting strategies | [references/search-strategies.md](references/search-strategies.md) |
| Tool comparison and decision guide | [references/tool-comparison.md](references/tool-comparison.md) |
| Remote context handoff guide | [references/remote-handoff.md](references/remote-handoff.md) |

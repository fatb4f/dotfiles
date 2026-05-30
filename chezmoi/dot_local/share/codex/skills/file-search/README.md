# file-search Codex refactor overlay

This archive contains an OpenAI Codex-oriented refactor of the `file-search` skill.

Files included:

- `file-search/SKILL.md`
- `file-search/references/git-grep.md`
- `file-search/references/tool-fallbacks.md`

It is intended as an overlay for an existing skill directory that already contains the other referenced files.

## Install

```bash
cp -a file-search/SKILL.md ~/.local/share/codex/skills/file-search/SKILL.md
mkdir -p ~/.local/share/codex/skills/file-search/references
cp -a file-search/references/git-grep.md ~/.local/share/codex/skills/file-search/references/git-grep.md
cp -a file-search/references/tool-fallbacks.md ~/.local/share/codex/skills/file-search/references/tool-fallbacks.md
```

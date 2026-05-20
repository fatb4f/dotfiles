# Global Codex working agreements

## Skill discovery contract

Discover agent-sdk skills through the `agent-sdk-mcp` MCP server. Prefer its
model-facing tools for listing and reading projected skills and references
before inspecting the projected skill tree directly.

## Repository inspection contract

Before broad repository inspection, recursive grep, file-by-file crawling, or speculative edits, prefer the available repo-search skill/tooling when the task involves:

- finding relevant files
- understanding repository structure
- locating implementation surfaces
- tracing tests, schemas, generated files, or adapters
- producing a patch from incomplete context

Use direct shell inspection only after repo-search has established the likely surfaces, or when the user explicitly asks for raw shell inspection.

If a repo-search skill is available, invoke it before falling back to ad hoc traversal.



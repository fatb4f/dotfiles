# Immutable committed-snapshot hydrator

`context-git-hydrator` is a read-only go-git adapter for Issue #68. It resolves one revision to an exact commit and emits a deterministic structural observation of that commit's root tree.

## Contract

```text
repository + revision request
          ↓ go-git
closed committed-tree observation
          ↓ CUE
candidate repository-context graph snapshot
```

The adapter does not inspect the index or worktree, fetch network data, follow symlinks, recurse into gitlinks, embed blob contents, infer language semantics, or promote evidence authority.

## CLI

```bash
context-git-hydrator committed --request request.json
```

Example request:

```json
{"schema":"kernel.git-committed-snapshot-request.v0","repositoryID":"repo.dotfiles","path":".","revision":"HEAD"}
```

`repositoryID` is explicit. The emitted observation contains no checkout path, timestamp, remote URL, random identifier, or environment-derived field.

## Identity

- `contentIdentity`: Git object format and object ID.
- `pathIdentity`: repository plus normalized path; stable for an unchanged path across revisions.
- `occurrenceIdentity`: repository plus resolved revision plus path; bound to one exact committed snapshot.

A rename therefore preserves blob content identity while changing path and occurrence identity. A new commit changes snapshot-bound occurrence identity even when the path is unaffected; cross-revision preservation properties use `pathIdentity` plus content identity.

## Qualification

From this module:

```bash
go test ./...
```

From the repository root:

```bash
bash .github/scripts/context-git-hydrator-test.sh
```

The qualification script creates commits A-F programmatically, executes the CLI for each commit, validates every observation and graph projection with CUE, runs structural rejection fixtures, checks deterministic JSON, and proves declared/generated/executed/reported property-set equality.

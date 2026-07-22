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
- `occurrenceIdentity`: repository plus normalized path; stable while that repository path is preserved across revisions.
- `snapshotOccurrenceIdentity`: repository plus resolved revision plus normalized path; bound to one exact committed snapshot.

A rename preserves content identity while changing both occurrence identities. A content edit, unrelated addition, or mode-only change preserves the stable occurrence identity for unaffected paths while changing the revision-bound snapshot occurrence identity. Graph member keys and containment endpoints use the stable occurrence identity; source and provenance fields retain the exact resolved revision.

## Qualification

From this module:

```bash
go test ./...
```

To preserve the executable property report as a CI artifact:

```bash
CONTEXT_GIT_HYDRATOR_PROPERTY_REPORT="$PWD/property-report.json" \
  go test ./internal/hydrator -run TestDeclaredGeneratedExecutedReportedPropertySetEquality
```

From the repository root:

```bash
bash .github/scripts/context-git-hydrator-test.sh
```

The qualification script creates commits A-F programmatically, executes the CLI for each commit, validates every observation and graph projection with CUE, runs structural rejection fixtures, checks deterministic JSON, and proves declared/generated/executed/reported property-set equality.

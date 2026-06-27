# Validation reference

Run these commands in `fatb4f/factory` when validating the source materializer contract.

## Positive checks

```bash
cue vet ./contracts/issues/44
cue export ./contracts/issues/44 -e publicContract
cue export ./contracts/issues/44 -e validationPlan
cue export ./contracts/issues/44 -e completionReportContract
cue vet ./contracts/agent-context-resolver
cue export ./contracts/agent-context-resolver -e implementationSliceIssueBaseline
cue export ./contracts/agent-context-resolver -e implementationSliceMaterializationReport
cue export ./contracts/agent-context-resolver -e implementationSliceEvalPlan
cue export ./contracts/agent-context-resolver -e implementationSliceRunnerPlan
```

## Negative bottom checks

```bash
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.routeOnlyPacket'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.missingContractPath'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.staticEvalPlan'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.missingNegativeCheckExpression'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.anyNonzeroAsPass'
```

## Packaging gates

The plugin-bundle packaging surface requires:

- `.codex-plugin/plugin.json`
- at least one effective capability, initially a skill
- root-contained relative paths
- no parent-directory or absolute path escapes
- no symlinks or hardlinks in the archive
- no unsupported archive entries
- repo-local marketplace entry at `.agents/plugins/marketplace.json`
- hooks, MCP servers, and apps remain optional/gated

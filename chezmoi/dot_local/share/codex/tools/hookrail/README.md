# hookrail

Hookrail is superseded by Frame. Keep this tree only for rollback and
compatibility.

Active runtime:

```text
$CODEX_HOME/tools/frame/bin/frame
```

Legacy hookrail install path:

```text
$CODEX_HOME/tools/hookrail/bin/hookrail
```

The old tree still exists as a temporary rollback line. Do not treat it as the
active Codex hook authority.

## What remains

- CUE hook contracts and projections
- temporary rollback artifacts
- the legacy install helper
- the four-hook scope: `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Stop`

## Smoke test

```sh
$CODEX_HOME/tools/frame/bin/frame doctor
```

```sh
$CODEX_HOME/tools/frame/bin/frame hook run < fixtures/hooks/user-prompt-submit-large.json
```

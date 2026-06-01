# Token ergonomics model

## Turn boundary

Classify prompt payloads before continuing a session.

```text
small      < 50k chars
large      >= 50k chars
oversized  >= 100k chars
```

Large prompts emit bounded advisory context. Oversized prompts still continue in
this stripped implementation, but the manifest makes the pressure visible.

## Tool-output boundary

`PostToolUse.tool_response` is unbounded. Large output is persisted out-of-band
when `HOOKRAIL_STATE` is available and only a bounded summary is returned as
live context.

## Session boundary

`Stop` writes a compact closeout signal. A later implementation can turn this
into a generated handoff file.

## Window boundary

This stripped tree does not claim server quota authority. It only records local
hook evidence that can support a later window-budget approximation.

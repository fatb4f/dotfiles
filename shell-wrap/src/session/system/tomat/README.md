# Tomat lockout producer contract

These files document the commands a break producer should run. They do not
enable live lockout by themselves.

Break start:

Use `tomat-break-begin`. It requires `TOMAT_REMAINING_SECONDS`, computes
`until_epoch` at the transition edge, runs
`sudo /usr/local/bin/session lockout set "$until_epoch"`, and locks the session.

Break end or skip:

Use `tomat-break-end`. It clears the lockout deadline and marks post-break
resume pending.

Unlock edge:

Use `session-post-unlock` from the real unlock event. It consumes the pending
resume marker and runs `tomat resume` exactly once when the marker existed.

The producer computes or forwards the deadline at the transition edge. It should
not query live daemon state from the auth path. Clearing the deadline is an early
release optimization; expiry of the root-owned deadline remains authoritative.

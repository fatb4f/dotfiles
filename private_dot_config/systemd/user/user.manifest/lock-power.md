# Lock and power runtime units

These units are runtime-triggered only. They should not be enabled directly.

## Units

- `locked-session-halt.timer`: abandoned locked-session deadline.
- `locked-session-halt.service`: powers off when the timer elapses.

## Contract

```text
loginctl lock-session
→ logind Lock signal
→ hypridle lock_cmd
→ cli.session locker
→ locked-session-halt.timer
→ locked-session-halt.service
```

Unlock or session cleanup should stop/cancel the halt timer.

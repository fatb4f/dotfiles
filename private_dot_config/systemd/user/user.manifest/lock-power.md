# Lock and power runtime units

These units are runtime-triggered only. They should not be enabled directly.

## Units

- `session-lock.service`: foreground graphical locker.
- `locked-session-halt.timer`: abandoned locked-session deadline.
- `locked-session-halt.service`: powers off when the timer elapses.

## Contract

```text
loginctl lock-session
→ logind Lock signal
→ logind-lock-listener.service
→ session-lock.service
→ locked-session-halt.timer
→ locked-session-halt.service
```

Unlock or session cleanup should stop/cancel the halt timer.

# Session companions

Session companions are long-lived user services that are part of the authenticated Wayland session but are not owned by the compositor process.

## Target wiring

Started by:

```text
wayland-session@niri.desktop.target.wants/
```

## Units

- `noctalia-shell.service`: Quickshell/Noctalia shell UI.
- `stasis.service`: idle monitor and lock/retire producer.
- `logind-lock-listener.service`: listens for logind lock/unlock edges and starts runtime lock/power units.

## Contract

```text
wayland-session@niri.desktop.target
→ session companion services
→ no compositor-owned shell/idle/lock children
```

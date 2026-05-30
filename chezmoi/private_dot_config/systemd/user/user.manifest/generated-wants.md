# Generated wants directories

These directories contain symlinks that wire units into targets. Treat them as generated or explicitly policy-owned wiring.

## Current directories

- `default.target.wants/`
- `sockets.target.wants/`
- `wayland-session@niri.desktop.target.wants/`

## Policy

- Do not place runtime-triggered units here.
- Do not place app launch templates here.
- Session companions may be linked from `wayland-session@niri.desktop.target.wants/`.

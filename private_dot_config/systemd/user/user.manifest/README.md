# User systemd unit manifest

This directory documents the ownership and enablement policy for `~/.config/systemd/user`.

The unit namespace itself stays mostly flat because systemd discovers user units by filename directly under `~/.config/systemd/user`. Classification is expressed through unit names, header comments, generated `.wants/` links, and this manifest.

## Ownership classes

| Class | Meaning | Enablement |
|---|---|---|
| `session-companion` | Long-lived services that belong to the Wayland session | Enabled through `wayland-session@niri.desktop.target.wants/` |
| `runtime-triggered` | Lock/power units started by scripts or listeners | Never enabled directly |
| `transient app session` | App launch units started by launch adapters | Never enabled directly |
| `mask` | User-level opt-out for unwanted autostart services | Symlink to `/dev/null` |
| `generated wiring` | `.wants/` symlink directories | Managed by `systemctl --user enable` or explicit symlink policy |

## Current owned units

### Session companions

- `noctalia-shell.service`
- `stasis.service`
- `logind-lock-listener.service`

### Runtime lock/power units

- `session-lock.service`
- `locked-session-halt.timer`
- `locked-session-halt.service`

### App launch units

- `app-nvim@.service`

### Masks

- `at-spi-dbus-bus.service`
- `gvfs-afc-volume-monitor.service`
- `gvfs-daemon.service`
- `gvfs-goa-volume-monitor.service`
- `gvfs-gphoto2-volume-monitor.service`
- `gvfs-mtp-volume-monitor.service`
- `gvfs-udisks2-volume-monitor.service`
- `xdg-desktop-portal-gnome.service`
- `xdg-desktop-portal-wlr.service`

## Verification

```sh
systemctl --user daemon-reload
systemctl --user list-unit-files \
  noctalia-shell.service \
  stasis.service \
  logind-lock-listener.service \
  session-lock.service \
  locked-session-halt.service \
  locked-session-halt.timer \
  'app-nvim@.service'

systemctl --user is-enabled \
  session-lock.service \
  locked-session-halt.service \
  locked-session-halt.timer \
  'app-nvim@.service'
```

Expected policy:

- Session companions are wanted by `wayland-session@niri.desktop.target`.
- Lock/power runtime units are not enabled directly.
- `app-nvim@.service` is not enabled directly.

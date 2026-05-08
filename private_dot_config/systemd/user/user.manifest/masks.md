# User-level masks

Masks are intentional symlinks to `/dev/null` that prevent unwanted user services from being activated.

## Current masks

- `at-spi-dbus-bus.service`
- `gvfs-afc-volume-monitor.service`
- `gvfs-daemon.service`
- `gvfs-goa-volume-monitor.service`
- `gvfs-gphoto2-volume-monitor.service`
- `gvfs-mtp-volume-monitor.service`
- `gvfs-udisks2-volume-monitor.service`
- `xdg-desktop-portal-gnome.service`
- `xdg-desktop-portal-wlr.service`

## Contract

```text
unwanted autostart/systemd user unit
→ user-level mask
→ activation blocked
```

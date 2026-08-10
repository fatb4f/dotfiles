# Hyprshade Eye-Load Profiles

Hyprshade 5.0.0 applies four composite profiles that lower luminance,
saturation, and blue contribution together. `eye-day`, `eye-evening`, and
`eye-night` follow a schedule; `eye-rescue` is manual.

## Compatibility gate

Install or update Hyprshade and require version 5.0.0:

```bash
paru -S hyprshade
hyprshade --version
```

From a live Hyprland session, verify the option interface Hyprshade 5 queries:

```bash
hyprctl -j getoption decoration.screen_shader
```

Proceed only when that command returns JSON. If it reports `no such option`,
check whether the session exposes only the legacy spelling:

```bash
hyprctl -j getoption decoration:screen_shader
```

If only the colon form works, stop before installing or enabling the schedule.
Hyprshade 5.0.0 queries the dot form and is not compatible with that session.

## Apply and inspect

Preview and apply the managed Hyprland configuration:

```bash
chezmoi diff -- ~/.config/hypr
chezmoi apply -- ~/.config/hypr
```

Confirm that Hyprshade discovers the managed profiles:

```bash
hyprshade ls
```

Exercise each profile manually, restoring the unfiltered screen afterward:

```bash
hyprshade on eye-day
hyprshade on eye-evening
hyprshade on eye-night
hyprshade on eye-rescue
hyprshade off
```

For immediate eye strain, start with `hyprshade on eye-rescue`. Return to
`hyprshade on eye-day` when the stronger profile is no longer needed.

## Install the schedule

Hyprshade generates its systemd user service and timer from
`~/.config/hypr/hyprshade.toml`:

```bash
hyprshade install
systemctl --user enable --now hyprshade.timer
hyprshade auto
```

Verify the timer and active profile:

```bash
systemctl --user status hyprshade.timer
hyprshade current
```

Hyprland startup imports `HYPRLAND_INSTANCE_SIGNATURE` into the systemd user
environment before future timer activations and applies the profile appropriate
for the current time. Confirm the import from a live session with:

```bash
systemctl --user show-environment | grep HYPRLAND_INSTANCE_SIGNATURE
```

Use `hyprshade off` as the emergency escape hatch.

## Capture behavior

Hyprland screen shaders appear in screenshots and recordings. For ordinary
color-temperature or gamma adjustment outside the captured rendering path,
Hyprland recommends `hyprsunset`. A future split can use Hyprsunset for
luminance and temperature while retaining Hyprshade for desaturation and the
manual rescue profile.

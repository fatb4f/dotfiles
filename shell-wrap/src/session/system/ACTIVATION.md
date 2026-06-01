# Session lockout activation

This runbook moves the lockout contracts from repository artifacts to live
machine enforcement. Do the steps manually and in order.

## Preflight

- Keep an unlocked root shell open, or keep a TTY available.
- Do not test PAM first with a long deadline.
- Do not close the current root shell until unlock behavior is verified.
- Do not wire tomat hooks before the manual PAM smoke test passes.
- Review the rollback section before editing PAM.

## Install the root-owned command

From the repository:

```sh
sudo shell-wrap/src/session/system/install-session-lockout
```

Verify the installed command:

```sh
stat -c '%U:%G %a %n' /usr/local/bin/session
/usr/local/bin/session --help
/usr/local/bin/session lockout check
```

Expected ownership and mode:

```text
root:root 755 /usr/local/bin/session
```

With no deadline file present, `/usr/local/bin/session lockout check` should
return success.

## Install sudoers

Validate the fragment before installing it:

```sh
sudo visudo -cf shell-wrap/src/session/system/sudoers/session-lockout
```

Install it manually:

```sh
sudo install -o root -g root -m 0440 \
  shell-wrap/src/session/system/sudoers/session-lockout \
  /etc/sudoers.d/session-lockout
```

Validate the installed file:

```sh
sudo visudo -cf /etc/sudoers.d/session-lockout
```

Test set and clear with a short deadline:

```sh
until_epoch="$(($(date +%s) + 15))"
sudo /usr/local/bin/session lockout set "$until_epoch"
/usr/local/bin/session lockout check
sudo /usr/local/bin/session lockout clear
/usr/local/bin/session lockout check
```

The first check after `set` should fail until cleared or expired. The check
after `clear` should return success.

## Add the PAM gate

Edit `/etc/pam.d/hyprlock` manually and add the marked block before the normal
password auth stack:

```pam
# session-lockout begin
auth requisite pam_exec.so quiet /usr/local/libexec/pam-pomodoro-gate
# session-lockout end
```

Keep the block easy to remove. Keep the root shell or TTY available while
testing.

## Smoke test PAM

Use a short deadline:

```sh
until_epoch="$(($(date +%s) + 15))"
sudo /usr/local/bin/session lockout set "$until_epoch"
/usr/local/bin/session lockout check
```

During the deadline, unlock should be denied. After the deadline expires,
`/usr/local/bin/session lockout check` should return success and hyprlock
unlock should use the normal password path again.

Clear explicitly after testing:

```sh
sudo /usr/local/bin/session lockout clear
```

## Wire tomat hooks

Only after the PAM smoke test passes, wire tomat break events to the producer
contract:

```sh
sudo /usr/local/bin/session lockout set "$until_epoch"
sudo /usr/local/bin/session lockout clear
```

If tomat provides an end timestamp, forward that timestamp. If tomat provides a
duration, compute `until_epoch` once at the break transition edge.

## Rollback

Remove or comment the PAM block:

```pam
# session-lockout begin
auth requisite pam_exec.so quiet /usr/local/libexec/pam-pomodoro-gate
# session-lockout end
```

Then remove the sudoers fragment and runtime state:

```sh
sudo rm -f /etc/sudoers.d/session-lockout
sudo rm -f /run/session-lockout/until_epoch
```

Optionally remove the root-owned command after PAM no longer references it:

```sh
sudo rm -f /usr/local/bin/session
```

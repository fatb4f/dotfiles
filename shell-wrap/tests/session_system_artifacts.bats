#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  system_dir="$BATS_TEST_DIRNAME/../src/session/system"
  pam_file="$system_dir/pam/hyprlock.lockout.example"
  sudoers_file="$system_dir/sudoers/session-lockout"
  install_script="$system_dir/install-session-lockout"
  activation_doc="$system_dir/ACTIVATION.md"
  tomat_dir="$system_dir/tomat"
  tomat_break_start="$tomat_dir/break-start.example"
  tomat_break_end="$tomat_dir/break-end.example"
}

@test "PAM fragment calls root-owned session lockout check" {
  run grep -Fx "auth requisite pam_exec.so quiet /usr/local/bin/session lockout check" "$pam_file"

  [ "$status" -eq 0 ]
}

@test "PAM fragment does not call the user session projection" {
  run grep -F "$HOME/.local/bin/session" "$pam_file"

  [ "$status" -eq 1 ]

  run grep -F ".local/bin/session" "$pam_file"

  [ "$status" -eq 1 ]
}

@test "sudoers allows lockout set and clear only" {
  run grep -Fx "Cmnd_Alias SESSION_LOCKOUT_SET = /usr/local/bin/session lockout set *" "$sudoers_file"

  [ "$status" -eq 0 ]

  run grep -Fx "Cmnd_Alias SESSION_LOCKOUT_CLEAR = /usr/local/bin/session lockout clear" "$sudoers_file"

  [ "$status" -eq 0 ]

  run grep -E '^Cmnd_Alias .*lockout check' "$sudoers_file"

  [ "$status" -eq 1 ]
}

@test "integration artifacts do not call session-state or compositor tools" {
  run grep -REn "tomat status|dbus|systemctl --user|hyprctl|notify-send" "$system_dir"

  [ "$status" -eq 1 ]
}

@test "install script installs root-owned executable projection" {
  run grep -Fx "install -o root -g root -m 0755 \"\$session_src\" /usr/local/bin/session" "$install_script"

  [ "$status" -eq 0 ]

  run grep -Fx 'install -d -o root -g root -m 0755 /run/session-lockout' "$install_script"

  [ "$status" -eq 0 ]
}

@test "tomat break-start example computes a deadline and sets lockout" {
  run grep -F "until_epoch=\"\$((\$(date +%s) + break_seconds))\"" "$tomat_break_start"

  [ "$status" -eq 0 ]

  run grep -Fx "sudo /usr/local/bin/session lockout set \"\$until_epoch\"" "$tomat_break_start"

  [ "$status" -eq 0 ]
}

@test "tomat break-end example clears lockout" {
  run grep -Fx "sudo /usr/local/bin/session lockout clear" "$tomat_break_end"

  [ "$status" -eq 0 ]
}

@test "tomat artifacts do not call user session projection or live-state tools" {
  run grep -REn "/home/|\\.local/bin/session|tomat status|dbus|systemctl --user|hyprctl|notify-send" "$tomat_dir"

  [ "$status" -eq 1 ]
}

@test "activation runbook documents safe manual lockout activation" {
  run grep -F "/usr/local/bin/session lockout check" "$activation_doc"

  [ "$status" -eq 0 ]

  run grep -F "visudo -cf" "$activation_doc"

  [ "$status" -eq 0 ]

  run grep -F '+ 15' "$activation_doc"

  [ "$status" -eq 0 ]
}

@test "activation runbook keeps PAM activation recoverable" {
  run grep -F "Keep an unlocked root shell open, or keep a TTY available." "$activation_doc"

  [ "$status" -eq 0 ]

  run grep -F "# session-lockout begin" "$activation_doc"

  [ "$status" -eq 0 ]

  run grep -F "# session-lockout end" "$activation_doc"

  [ "$status" -eq 0 ]
}

@test "activation runbook avoids mutable user projection and live-state tools" {
  run grep -REn "\\.local/bin/session|tomat status|dbus|systemctl --user|hyprctl|notify-send" "$activation_doc"

  [ "$status" -eq 1 ]
}

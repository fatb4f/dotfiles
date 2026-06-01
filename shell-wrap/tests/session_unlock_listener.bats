#!/usr/bin/env bats

# shellcheck shell=bats

setup() {
  hypridle_conf="$BATS_TEST_DIRNAME/../../chezmoi/private_dot_config/hypr/hypridle.conf"
}

@test "hypridle unlock edge calls installed session post-unlock hook" {
  run grep -Fx "    on_unlock_cmd = /usr/local/libexec/session-post-unlock" "$hypridle_conf"

  [ "$status" -eq 0 ]
}

@test "hypridle unlock edge does not call lockout or privileged paths" {
  unlock_line="$(grep -F "on_unlock_cmd" "$hypridle_conf")"

  [[ "$unlock_line" != *"sudo"* ]]
  [[ "$unlock_line" != *"pam"* ]]
  [[ "$unlock_line" != *"lockout check"* ]]
  [[ "$unlock_line" != *"lockout set"* ]]
  [[ "$unlock_line" != *"lockout clear"* ]]
}

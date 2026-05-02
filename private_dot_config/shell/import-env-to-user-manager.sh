#!/bin/sh
set -eu

systemctl --user import-environment \
  BASH_ENV \
  SHELL_ENV_LOADER \
  XDG_CONFIG_HOME \
  XDG_DATA_HOME \
  XDG_STATE_HOME \
  XDG_CACHE_HOME \
  XDG_DATA_BIN \
  TOOL_PATH_HOME \
  PATH \
  EDITOR \
  VISUAL \
  GOPATH \
  GOBIN \
  CARGO_HOME \
  RUSTUP_HOME

dbus-update-activation-environment --systemd \
  BASH_ENV \
  SHELL_ENV_LOADER \
  XDG_CONFIG_HOME \
  XDG_DATA_HOME \
  XDG_STATE_HOME \
  XDG_CACHE_HOME \
  XDG_DATA_BIN \
  TOOL_PATH_HOME \
  PATH \
  EDITOR \
  VISUAL

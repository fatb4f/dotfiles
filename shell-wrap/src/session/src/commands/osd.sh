# shellcheck shell=bash
session_osd_command_impl() {
  # shellcheck disable=SC2154
  session_osd_dispatch "${args[action]}"
}

session_osd_command_impl

# Adapter config for ~/.local/bin/waylock-session.
# Note: waylock itself does not have a native config file parser;
# it is configured through command-line options.

WAYLOCK_BIN=/usr/bin/waylock

WAYLOCK_ARGS=(
  -ignore-empty-password
  -init-color 0x000000
  -input-color 0x222222
  -input-alt-color 0x333333
  -fail-color 0x550000
)

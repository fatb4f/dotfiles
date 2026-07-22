#!/usr/bin/env python3
"""Compatibility shim for the packaged Codex profiler."""

from __future__ import annotations

import sys
from pathlib import Path


PACKAGE_SRC = Path(__file__).resolve().parents[1] / ".codex/codex-profile/src"
if str(PACKAGE_SRC) not in sys.path:
    sys.path.insert(0, str(PACKAGE_SRC))

from codex_profile.reporting import *  # noqa: F403
from codex_profile.reporting import main


if __name__ == "__main__":
    raise SystemExit(main())

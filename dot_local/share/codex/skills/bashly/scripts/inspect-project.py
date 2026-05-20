#!/usr/bin/env python3
"""Inspect a Bashly project and print a compact JSON boundary summary."""
from __future__ import annotations

import json
import sys
from pathlib import Path


def first_existing(root: Path, names: list[str]) -> Path | None:
    for name in names:
        candidate = root / name
        if candidate.exists():
            return candidate
    return None


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    settings = first_existing(root, ["bashly-settings.yml", "settings.yml"])
    config = first_existing(root, ["bashly.yml", "src/bashly.yml"])

    source_dir = None
    if config:
        source_dir = config.parent
    elif (root / "src").is_dir():
        source_dir = root / "src"

    target_candidates = [root / "bin", root / "dist", root]
    generated_outputs = []
    for candidate in target_candidates:
        if candidate.exists():
            generated_outputs.append(str(candidate.relative_to(root)))

    test_dirs = [str(p.relative_to(root)) for p in [root / "test", root / "tests", root / "spec"] if p.exists()]

    summary = {
        "project_root": str(root),
        "settings_file": str(settings.relative_to(root)) if settings else None,
        "source_dir": str(source_dir.relative_to(root)) if source_dir else None,
        "config_path": str(config.relative_to(root)) if config else None,
        "target_dir": None,
        "generated_outputs": generated_outputs,
        "test_dirs": test_dirs,
    }
    print(json.dumps(summary, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

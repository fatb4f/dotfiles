#!/usr/bin/env python3
"""Validate the repo-local Bats skill layout."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = ["skill.md", "references", "scripts", "assets"]


def fail(message: str) -> int:
    print(f"error: {message}", file=sys.stderr)
    return 1


def main() -> int:
    for name in REQUIRED:
        path = ROOT / name
        if name.endswith(".md"):
            if not path.is_file():
                return fail(f"missing {name}")
        elif not path.is_dir():
            return fail(f"missing {name}/")

    text = (ROOT / "skill.md").read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return fail("skill.md must start with YAML frontmatter")
    if "\nname: bats-core\n" not in text:
        return fail("skill.md frontmatter must declare name: bats-core")
    legacy_name = "SKILL" + ".md"
    if legacy_name in text:
        return fail("skill.md must not reference legacy uppercase naming")

    for directory in ["references", "scripts", "assets"]:
        if not any((ROOT / directory).iterdir()):
            return fail(f"{directory}/ must not be empty")

    print("ok: bats-core skill layout is spec-compliant")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

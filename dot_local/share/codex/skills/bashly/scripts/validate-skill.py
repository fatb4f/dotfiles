#!/usr/bin/env python3
"""Small local sanity checker for the Bashly skill layout."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "SKILL.md"

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def fail(msg: str) -> int:
    print(f"error: {msg}", file=sys.stderr)
    return 1


def main() -> int:
    if not SKILL.exists():
        return fail("missing SKILL.md")

    text = SKILL.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return fail("SKILL.md must start with YAML frontmatter")
    parts = text.split("---\n", 2)
    if len(parts) < 3:
        return fail("SKILL.md frontmatter is not closed")

    frontmatter = parts[1]
    body = parts[2]
    fields: dict[str, str] = {}
    for line in frontmatter.splitlines():
        if ":" in line and not line.startswith(" "):
            key, value = line.split(":", 1)
            fields[key.strip()] = value.strip().strip('"')

    name = fields.get("name")
    description = fields.get("description")
    if not name:
        return fail("missing name")
    if name != ROOT.name:
        return fail(f"name {name!r} must match directory {ROOT.name!r}")
    if not NAME_RE.fullmatch(name):
        return fail("name must be lowercase alphanumeric with single hyphens")
    if not description:
        return fail("missing description")
    if len(description) > 1024:
        return fail("description exceeds 1024 characters")
    if len(text.splitlines()) > 500:
        return fail("SKILL.md exceeds 500 lines")
    if len(body.split()) > 5000:
        return fail("SKILL.md body exceeds recommended 5000 words/tokens proxy")

    for dirname in ["references", "assets", "scripts"]:
        if not (ROOT / dirname).is_dir():
            return fail(f"missing {dirname}/ directory")

    print("ok: bashly skill layout looks valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

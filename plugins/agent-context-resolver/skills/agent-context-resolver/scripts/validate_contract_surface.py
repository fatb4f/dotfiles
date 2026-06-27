#!/usr/bin/env python3
"""Validate the resolver plugin-bundle contract surface shape.

This script is intentionally local and structural. It does not execute CUE,
GitHub API calls, MCP servers, hooks, or external providers.
"""

from __future__ import annotations

import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
PLUGIN_ROOT = ROOT / "plugins" / "agent-context-resolver"
MARKETPLACE = ROOT / ".agents" / "plugins" / "marketplace.json"
MANIFEST = PLUGIN_ROOT / ".codex-plugin" / "plugin.json"
SKILL = PLUGIN_ROOT / "skills" / "agent-context-resolver" / "SKILL.md"


def fail(message: str) -> None:
    print(f"validate_contract_surface: {message}", file=sys.stderr)
    raise SystemExit(1)


def assert_relative_inside(path: str) -> None:
    if path.startswith("/"):
        fail(f"absolute path rejected: {path}")
    if ".." in Path(path).parts:
        fail(f"parent escape rejected: {path}")


def main() -> int:
    for required in (MARKETPLACE, MANIFEST, SKILL):
        if not required.exists():
            fail(f"missing required file: {required.relative_to(ROOT)}")

    marketplace = json.loads(MARKETPLACE.read_text())
    plugins = marketplace.get("plugins")
    if not isinstance(plugins, list) or not plugins:
        fail("marketplace.plugins must be a non-empty list")

    entry = next((item for item in plugins if item.get("name") == "agent-context-resolver"), None)
    if entry is None:
        fail("marketplace missing agent-context-resolver entry")

    source = entry.get("source", {})
    if source.get("source") != "local":
        fail("agent-context-resolver marketplace source must be local")
    if source.get("path") != "./plugins/agent-context-resolver":
        fail("agent-context-resolver marketplace path must target ./plugins/agent-context-resolver")

    manifest = json.loads(MANIFEST.read_text())
    if manifest.get("name") != "agent-context-resolver":
        fail("plugin manifest name mismatch")
    if ".codex-plugin/plugin.json" not in str(MANIFEST.relative_to(PLUGIN_ROOT)):
        fail("plugin manifest must live under .codex-plugin/plugin.json")

    skills = manifest.get("skills")
    if not isinstance(skills, str) or not skills:
        fail("plugin manifest must declare skills path")
    assert_relative_inside(skills)

    skill_text = SKILL.read_text()
    required_markers = [
        "Implementation-slice issue materializer",
        "contracts/issues/44/manifest.cue",
        "_negativeBottomChecks.routeOnlyPacket",
        "GitHub issue bodies are transport only",
    ]
    for marker in required_markers:
        if marker not in skill_text:
            fail(f"skill missing marker: {marker}")

    print("validate_contract_surface: pass")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

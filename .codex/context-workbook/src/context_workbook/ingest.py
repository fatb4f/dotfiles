"""Bounded repository and code-intel materialization."""

from __future__ import annotations

import fnmatch
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .models import (
    AuthorityBinding,
    ContextInventory,
    Evidence,
    SourceObservation,
    digest_value,
)


class IngestError(RuntimeError):
    pass


@dataclass(frozen=True)
class MaterializedInputs:
    inventory: ContextInventory
    observations: dict[str, SourceObservation]
    evidence: dict[str, Evidence]
    code_intel: dict[str, Any]
    node_digests: dict[str, str]


_CODE_INTEL_FILES = (
    ".codex/plugins/code-intel/reference/lsp/provider-routing.json",
    ".codex/plugins/code-intel/reference/mcp/tool-registry.json",
    ".codex/plugins/code-intel/reference/workflows/lua-first/workflow.json",
)


def _read_json(root: Path, relative: str) -> object:
    path = (root / relative).resolve(strict=True)
    try:
        path.relative_to(root.resolve(strict=True))
    except ValueError as error:
        raise IngestError(f"path escapes repository: {relative}") from error
    return json.loads(path.read_text(encoding="utf-8"))


def load_inventory(root: Path, cue_binary: str = "cue") -> ContextInventory:
    """Export the authoritative inventory from CUE through the pinned CLI."""
    import subprocess

    model_root = root / ".codex/context-model"
    process = subprocess.run(
        [cue_binary, "export", ".", "-e", "rootSeed.inventory", "--out", "json"],
        cwd=model_root,
        check=False,
        capture_output=True,
        text=True,
        timeout=30,
    )
    if process.returncode != 0:
        raise IngestError(process.stderr.strip() or "CUE inventory export failed")
    value = json.loads(process.stdout)
    return ContextInventory.model_validate(value)


def load_code_intel(root: Path) -> dict[str, Any]:
    """Load only the declared read-only code-intel files."""
    return {path: _read_json(root, path) for path in _CODE_INTEL_FILES}


def match_code_intel_paths(code_intel: dict[str, Any], paths: list[str]) -> dict[str, list[str]]:
    routing = code_intel[_CODE_INTEL_FILES[0]]
    matches: dict[str, list[str]] = {}
    for route in routing.get("routes", []):
        route_matches = [
            path for path in paths if any(fnmatch.fnmatch(path, glob) for glob in route.get("globs", []))
        ]
        if route_matches:
            matches[route["id"]] = sorted(route_matches)
    return matches


def materialize_inputs(
    *,
    root: Path,
    prompt: str,
    revision: str,
    inventory: ContextInventory,
    selected_paths: list[str],
) -> MaterializedInputs:
    code_intel = load_code_intel(root)
    path_matches = match_code_intel_paths(code_intel, selected_paths)

    observations: dict[str, SourceObservation] = {
        "prompt.current": SourceObservation.model_validate(
            {
                "kind": "prompt",
                "subject": "user-prompt",
                "facts": {"text": prompt, "digest": digest_value(prompt)},
                "diagnostics": [],
                "provenance": {
                    "semanticRole": "evidence",
                    "artifactClass": "runtime_observation",
                    "claimAuthority": "none",
                },
            }
        ),
        "repository.current": SourceObservation.model_validate(
            {
                "kind": "repository",
                "subject": "fatb4f/dotfiles",
                "facts": {
                    "revision": revision,
                    "selectedPaths": selected_paths,
                    "selectedPathDigest": digest_value(selected_paths),
                },
                "diagnostics": [],
                "provenance": {
                    "semanticRole": "evidence",
                    "artifactClass": "runtime_observation",
                    "claimAuthority": "none",
                },
            }
        ),
        "provider.registry": SourceObservation.model_validate(
            {
                "kind": "provider",
                "subject": "code-intel",
                "facts": {
                    "declaredFiles": list(_CODE_INTEL_FILES),
                    "digest": digest_value(code_intel),
                    "pathMatches": path_matches,
                },
                "diagnostics": [],
                "provenance": {
                    "semanticRole": "evidence",
                    "artifactClass": "runtime_observation",
                    "claimAuthority": "none",
                },
            }
        ),
    }
    evidence = {
        "evidence.prompt": Evidence.model_validate(
            {
                "summary": "The current user prompt is available as bounded runtime evidence.",
                "observationIDs": ["prompt.current"],
                "provenance": {
                    "semanticRole": "evidence",
                    "artifactClass": "runtime_observation",
                    "claimAuthority": "candidate",
                },
            }
        ),
        "evidence.repository": Evidence.model_validate(
            {
                "summary": "Repository revision and explicitly selected paths are materialized.",
                "observationIDs": ["repository.current"],
                "provenance": {
                    "semanticRole": "evidence",
                    "artifactClass": "runtime_observation",
                    "claimAuthority": "candidate",
                },
            }
        ),
        "evidence.code-intel": Evidence.model_validate(
            {
                "summary": "Declared code-intel registries were loaded as read-only evidence.",
                "observationIDs": ["provider.registry"],
                "provenance": {
                    "semanticRole": "evidence",
                    "artifactClass": "runtime_observation",
                    "claimAuthority": "candidate",
                },
            }
        ),
    }
    node_digests = {
        "inventory": digest_value(inventory.model_dump(by_alias=True)),
        "prompt": digest_value(prompt),
        "repository": digest_value({"revision": revision, "paths": selected_paths}),
        "code-intel": digest_value(code_intel),
        "materialized-evidence": digest_value(
            {
                "observations": {
                    key: value.model_dump(by_alias=True) for key, value in observations.items()
                },
                "evidence": {key: value.model_dump(by_alias=True) for key, value in evidence.items()},
            }
        ),
    }
    return MaterializedInputs(
        inventory=inventory,
        observations=observations,
        evidence=evidence,
        code_intel=code_intel,
        node_digests=node_digests,
    )

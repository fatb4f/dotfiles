"""Revision-bound orchestration for the authoritative context graph service."""

from __future__ import annotations

import hashlib
import argparse
import json
import os
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Literal

from .repository import RepositoryError, RepositorySnapshot


GIT_HYDRATOR_SOURCES = (
    ".codex/context-hydrators/git/cmd/context-git-hydrator/main.go",
    ".codex/context-hydrators/git/go.mod",
    ".codex/context-hydrators/git/go.sum",
    ".codex/context-hydrators/git/internal/hydrator/hydrator.go",
    ".codex/context-hydrators/git/internal/hydrator/json.go",
    ".codex/context-hydrators/git/internal/hydrator/observation.go",
    ".codex/context-hydrators/git/internal/hydrator/overlay.go",
    ".codex/context-hydrators/git/internal/hydrator/overlay_observation.go",
    ".codex/context-hydrators/git/internal/hydrator/overlay_properties.go",
    ".codex/context-hydrators/git/internal/hydrator/overlay_request.go",
    ".codex/context-hydrators/git/internal/hydrator/overlay_types.go",
    ".codex/context-hydrators/git/internal/hydrator/properties.go",
    ".codex/context-hydrators/git/internal/hydrator/request.go",
    ".codex/context-hydrators/git/internal/hydrator/types.go",
    ".codex/context-hydrators/git/internal/identity/identity.go",
)


class GraphServiceError(RuntimeError):
    """An internal failure which must be translated at the transport boundary."""

    def __init__(self, stage: str, code: str, message: str) -> None:
        super().__init__(message)
        self.stage = stage
        self.code = code


@dataclass(frozen=True)
class RevisionBinding:
    snapshot: RepositorySnapshot
    overlay_enabled: bool


def bind_revision(
    root: Path,
    revision: str,
    overlay_mode: Literal["disabled", "required", "auto"],
) -> RevisionBinding:
    """Resolve the commit first, then decide whether overlay observation is legal."""

    try:
        snapshot = RepositorySnapshot.resolve(root, revision)
        head = RepositorySnapshot.resolve(root, "HEAD").resolved_revision
    except RepositoryError as error:
        raise GraphServiceError("revision", "revision.unresolved", str(error)) from error

    if overlay_mode == "disabled":
        return RevisionBinding(snapshot=snapshot, overlay_enabled=False)
    if overlay_mode == "required" and snapshot.resolved_revision != head:
        raise GraphServiceError(
            "revision",
            "overlay.historical-revision",
            "required overlay hydration is valid only for the checkout HEAD",
        )
    if overlay_mode not in {"required", "auto"}:
        raise GraphServiceError("revision", "overlay.mode-unknown", "unknown overlay mode")
    return RevisionBinding(
        snapshot=snapshot,
        overlay_enabled=snapshot.resolved_revision == head,
    )


def source_manifest_digest(
    snapshot: RepositorySnapshot,
    version: str,
    paths: Iterable[str],
) -> str:
    """Hash ``version NUL path NUL bytes NUL ...`` at the bound revision."""

    ordered = list(paths)
    if ordered != sorted(ordered) or len(ordered) != len(set(ordered)):
        raise GraphServiceError(
            "manifest", "manifest.paths-not-canonical", "manifest paths must be sorted and unique"
        )
    digest = hashlib.sha256()
    digest.update(version.encode())
    digest.update(b"\0")
    for path in ordered:
        digest.update(path.encode())
        digest.update(b"\0")
        try:
            digest.update(snapshot.read_bytes(path))
        except (RepositoryError, UnicodeError) as error:
            raise GraphServiceError("manifest", "manifest.source-unavailable", str(error)) from error
        digest.update(b"\0")
    return f"sha256:{digest.hexdigest()}"


def qualified_hydrator(
    *,
    snapshot: RepositorySnapshot,
    source_paths: Iterable[str],
    cache_root: Path,
) -> tuple[Path, str]:
    """Build the exact revision's hydrator and atomically cache it by source digest."""

    digest = source_manifest_digest(snapshot, "git-hydrator-sources.v1", source_paths)
    target = cache_root / digest.removeprefix("sha256:") / "context-git-hydrator"
    if target.is_file() and os.access(target, os.X_OK):
        return target, digest

    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="context-git-hydrator-") as temporary:
        checkout = Path(temporary) / "source"
        for relative in source_paths:
            content = snapshot.read_bytes(relative)
            destination = checkout / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(content)
        built = Path(temporary) / "context-git-hydrator"
        process = subprocess.run(
            [
                "go",
                "build",
                "-trimpath",
                "-ldflags",
                (
                    "-X github.com/fatb4f/dotfiles/.codex/context-hydrators/git/"
                    f"internal/hydrator.BuildHydratorDigest={digest}"
                ),
                "-o",
                str(built),
                "./cmd/context-git-hydrator",
            ],
            cwd=checkout / ".codex/context-hydrators/git",
            capture_output=True,
            check=False,
            timeout=120,
        )
        if process.returncode:
            raise GraphServiceError(
                "hydration",
                "hydrator.build-failed",
                process.stderr.decode(errors="replace").strip() or "hydrator build failed",
            )
        os.chmod(built, 0o755)
        os.replace(built, target)
    return target, digest


def _canonical(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()


def _hydrate(hydrator: Path, command: str, request: dict[str, object]) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix="context-graph-hydration-") as temporary:
        request_path = Path(temporary) / "request.json"
        request_path.write_bytes(_canonical(request))
        process = subprocess.run(
            [str(hydrator), command, "--request", str(request_path)],
            capture_output=True,
            check=False,
            timeout=120,
        )
    if process.returncode:
        raise GraphServiceError(
            "hydration",
            f"hydrator.{command}-failed",
            process.stderr.decode(errors="replace").strip() or f"{command} hydration failed",
        )
    try:
        payload = json.loads(process.stdout)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise GraphServiceError(
            "hydration", "hydrator.output-invalid", "hydrator returned invalid JSON"
        ) from error
    if not isinstance(payload, dict):
        raise GraphServiceError(
            "hydration", "hydrator.output-invalid", "hydrator returned a non-object"
        )
    return payload


def hydrate_revision(
    *,
    binding: RevisionBinding,
    repository_id: str,
    hydrator: Path,
) -> tuple[dict[str, object], dict[str, object] | None]:
    committed = _hydrate(
        hydrator,
        "committed",
        {
            "schema": "kernel.git-committed-snapshot-request.v0",
            "repositoryID": repository_id,
            "path": str(binding.snapshot.root),
            "revision": binding.snapshot.resolved_revision,
        },
    )
    overlay = None
    if binding.overlay_enabled:
        overlay = _hydrate(
            hydrator,
            "overlay",
            {
                "schema": "kernel.git-overlay-request.v0",
                "repositoryID": repository_id,
                "path": str(binding.snapshot.root),
                "baseRevision": {
                    "format": "sha1",
                    "hex": binding.snapshot.resolved_revision,
                },
            },
        )
    return committed, overlay


def _failure(request_id: str, error: GraphServiceError) -> dict[str, object]:
    return {
        "schema": "dotfiles.context-graph-service-result.v0",
        "status": "failure",
        "failure": {
            "schema": "dotfiles.context-graph-failure.v0",
            "requestID": request_id,
            "stage": error.stage,
            "code": error.code,
            "message": str(error),
            "details": {},
        },
    }


def main(arguments: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--request-file", type=Path, required=True)
    parser.add_argument("--proposal-file", type=Path)
    args = parser.parse_args(arguments)
    request_id = "request.unknown"
    try:
        request = json.loads(args.request_file.read_text(encoding="utf-8"))
        if not isinstance(request, dict):
            raise GraphServiceError("proposal", "request.invalid", "request must be an object")
        request_id = request.get("requestID", request_id)
        if not isinstance(request_id, str):
            request_id = "request.unknown"
        binding = bind_revision(
            args.repo_root,
            str(request.get("revision", "")),
            str(request.get("overlayMode", "")),  # type: ignore[arg-type]
        )
        cache_root = Path(
            os.environ.get(
                "CONTEXT_GRAPH_CACHE",
                str(
                    Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
                    / "dotfiles-context-graph"
                ),
            )
        )
        hydrator, _ = qualified_hydrator(
            snapshot=binding.snapshot,
            source_paths=GIT_HYDRATOR_SOURCES,
            cache_root=cache_root,
        )
        hydrate_revision(
            binding=binding,
            repository_id=str(request.get("repository", "")),
            hydrator=hydrator,
        )
        raise GraphServiceError(
            "selection",
            "selection.cue-evaluation-required",
            "hydration succeeded but no concrete CUE selection evaluation was produced",
        )
    except (OSError, json.JSONDecodeError) as error:
        result = _failure(
            request_id,
            GraphServiceError("proposal", "request.invalid", str(error)),
        )
    except GraphServiceError as error:
        result = _failure(request_id, error)
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))
    return 0 if result["status"] == "success" else 2


if __name__ == "__main__":
    sys.exit(main())

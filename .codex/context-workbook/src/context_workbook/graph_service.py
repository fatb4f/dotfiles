"""Revision-bound orchestration for the authoritative context graph service."""

from __future__ import annotations

import hashlib
import os
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Literal

from .repository import RepositoryError, RepositorySnapshot


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

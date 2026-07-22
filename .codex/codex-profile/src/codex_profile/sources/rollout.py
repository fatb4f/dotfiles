from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterator


@dataclass(frozen=True)
class RolloutRecord:
    path: Path
    source_id: str
    source_generation: int
    source_offset: int
    raw: bytes
    obj: Any | None
    json_error: str | None

    @property
    def raw_byte_count(self) -> int:
        return len(self.raw)

    @property
    def payload_digest(self) -> str:
        return "sha256:" + hashlib.sha256(self.raw).hexdigest()

    @property
    def next_offset(self) -> int:
        return self.source_offset + self.raw_byte_count + 1


@dataclass(frozen=True)
class SourceIncarnation:
    identity: str
    size: int


def stable_source_id(path: Path) -> str:
    resolved = str(path.expanduser().resolve(strict=False))
    return "sha256:" + hashlib.sha256(f"rollout:{resolved}".encode("utf-8")).hexdigest()


def source_incarnation(path: Path) -> SourceIncarnation:
    stat = path.stat()
    identity = f"dev:{stat.st_dev}:ino:{stat.st_ino}"
    return SourceIncarnation(identity=identity, size=stat.st_size)


def source_generation(path: Path) -> int:
    return 0


def iter_complete_records(
    path: Path,
    *,
    start_offset: int = 0,
    source_id: str | None = None,
    generation: int | None = None,
) -> Iterator[RolloutRecord]:
    resolved_source_id = stable_source_id(path) if source_id is None else source_id
    resolved_generation = source_generation(path) if generation is None else generation
    with path.open("rb") as handle:
        handle.seek(start_offset)
        offset = start_offset
        while True:
            line = handle.readline()
            if not line:
                return
            if not line.endswith(b"\n"):
                return
            raw = line[:-1]
            if line.endswith(b"\r\n"):
                raw = line[:-2]
            if not raw:
                offset += len(line)
                continue
            obj: Any | None
            error: str | None = None
            try:
                obj = json.loads(raw.decode("utf-8"))
            except (UnicodeDecodeError, json.JSONDecodeError) as exc:
                obj = None
                error = str(exc)
            yield RolloutRecord(
                path=path,
                source_id=resolved_source_id,
                source_generation=resolved_generation,
                source_offset=offset,
                raw=raw,
                obj=obj,
                json_error=error,
            )
            offset += len(line)


def candidate_rollout_files(root: Path) -> list[Path]:
    if root.is_file():
        return [root] if root.suffix == ".jsonl" else []
    sessions = root / "sessions"
    base = sessions if sessions.exists() else root
    return sorted(path for path in base.rglob("*.jsonl") if path.is_file())

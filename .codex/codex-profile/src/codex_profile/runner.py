from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path

from codex_profile.contracts import CommandManifest, CommandResult, canonical_bytes

RESULT_LIMIT = 4096
LINE_LIMIT = 512
TERMS = ("error", "fail", "fatal", "panic", "traceback", "expected", "got")


def _digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def _projection_lines(paths: tuple[Path, Path]) -> tuple[list[str], bool]:
    entries: list[tuple[int, str, bool]] = []
    truncated = False
    def admit(raw: bytes, shortened: bool) -> None:
        nonlocal truncated
        try:
            line = raw.decode("utf-8", "strict")
        except UnicodeDecodeError:
            line = raw.decode("utf-8", "replace"); truncated = True
        if not line.strip():
            return
        if shortened or len(line.encode()) > LINE_LIMIT:
            line = line.encode()[:LINE_LIMIT].decode("utf-8", "ignore") + "…"; truncated = True
        entries.append((len(entries), line, any(term in line.lower() for term in TERMS)))
    for path in paths:
        pending = bytearray()
        shortened = False
        with path.open("rb") as handle:
            for block in iter(lambda: handle.read(64 * 1024), b""):
                for byte in block:
                    if byte == 10:
                        admit(bytes(pending), shortened)
                        pending.clear(); shortened = False
                    elif len(pending) < LINE_LIMIT * 2:
                        pending.append(byte)
                    else:
                        shortened = True
        if pending or shortened:
            admit(bytes(pending), shortened)
    failures = [entry for entry in entries if entry[2]][-20:]
    chosen = {entry[0]: entry for entry in failures}
    for entry in reversed(entries):
        if len(chosen) >= 20: break
        chosen.setdefault(entry[0], entry)
    if len(chosen) < len(entries):
        truncated = True
    return [chosen[index][1] for index in sorted(chosen)], truncated


def run_projected(argv: list[str], *, state_root: Path | None = None) -> tuple[CommandResult, int]:
    if not argv:
        raise ValueError("no command follows --")
    started = datetime.now(timezone.utc)
    parent = state_root or Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "codex-profile/command-results"
    parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    ident = started.strftime("%Y%m%dT%H%M%S%fZ") + f"-{os.getpid()}"
    final = parent / ident
    temp = Path(tempfile.mkdtemp(prefix=f".{ident}.", dir=parent)); os.chmod(temp, 0o700)
    stdout_path, stderr_path = temp / "stdout.bin", temp / "stderr.bin"
    began = time.monotonic()
    try:
        with stdout_path.open("wb") as stdout, stderr_path.open("wb") as stderr:
            os.chmod(stdout_path, 0o600); os.chmod(stderr_path, 0o600)
            try:
                process = subprocess.Popen(argv, stdin=subprocess.DEVNULL, stdout=stdout, stderr=stderr, shell=False)
                raw_exit = process.wait()
                signal = -raw_exit if raw_exit < 0 else None
                exit_code = 128 + signal if signal else raw_exit
            except FileNotFoundError:
                stderr.write(f"{argv[0]}: command not found\n".encode()); signal, exit_code = None, 127
            except PermissionError:
                stderr.write(f"{argv[0]}: permission denied\n".encode()); signal, exit_code = None, 126
            stdout.flush(); os.fsync(stdout.fileno()); stderr.flush(); os.fsync(stderr.fileno())
        manifest = CommandManifest.model_validate({
            "schema": "codex.command-artifact.v0", "argv": argv,
            "workingDirectory": str(Path.cwd().resolve()), "startedAt": started,
            "durationSeconds": time.monotonic() - began, "exitCode": exit_code, "signal": signal,
            "stdoutBytes": stdout_path.stat().st_size, "stderrBytes": stderr_path.stat().st_size,
            "stdoutSha256": _digest(stdout_path), "stderrSha256": _digest(stderr_path),
        })
        manifest_data = canonical_bytes(manifest)
        manifest_path = temp / "manifest.json"
        manifest_path.write_bytes(manifest_data); os.chmod(manifest_path, 0o600)
        os.rename(temp, final)
        lines, truncated = _projection_lines((final / "stdout.bin", final / "stderr.bin"))
        digest = hashlib.sha256(manifest_data).hexdigest()
        while True:
            result = CommandResult.model_validate({
                "schema": "codex.command-result.v0", "exitCode": exit_code, "signal": signal,
                "truncated": truncated, "relevantLines": lines,
                "artifact": str(final / "manifest.json"), "sha256": digest,
            })
            if len(canonical_bytes(result)) <= RESULT_LIMIT:
                return result, exit_code
            if not lines:
                raise RuntimeError("command result metadata exceeds 4 KiB")
            lines.pop(0); truncated = True
    except BaseException:
        shutil.rmtree(temp, ignore_errors=True)
        raise

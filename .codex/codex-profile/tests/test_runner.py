from __future__ import annotations

import hashlib
import json
import os
import signal
import sys
from pathlib import Path

from codex_profile.contracts import canonical_bytes
from codex_profile.runner import run_projected


def test_separate_binary_streams_and_hashes(tmp_path: Path) -> None:
    code = "import os,sys;os.write(1,b'good\\x00\\xff\\n');os.write(2,b'ERROR bad\\n');sys.exit(7)"
    result, status = run_projected([sys.executable, "-c", code], state_root=tmp_path)
    assert status == result.exit_code == 7
    assert result.truncated
    assert "ERROR bad" in result.relevant_lines
    artifact = Path(result.artifact)
    manifest = json.loads(artifact.read_text())
    assert (artifact.parent / "stdout.bin").read_bytes() == b"good\x00\xff\n"
    assert (artifact.parent / "stderr.bin").read_bytes() == b"ERROR bad\n"
    assert result.sha256 == hashlib.sha256(artifact.read_bytes()).hexdigest()
    assert manifest["stdoutBytes"] == 7
    assert len(canonical_bytes(result)) <= 4096


def test_command_not_found_is_retained(tmp_path: Path) -> None:
    result, status = run_projected(["codex-profile-no-such-command"], state_root=tmp_path)
    assert status == result.exit_code == 127
    assert Path(result.artifact).exists()


def test_signal_normalization(tmp_path: Path) -> None:
    result, status = run_projected(
        [sys.executable, "-c", "import os,signal;os.kill(os.getpid(), signal.SIGTERM)"],
        state_root=tmp_path,
    )
    assert result.signal == signal.SIGTERM
    assert status == 128 + signal.SIGTERM


def test_large_output_and_twenty_line_bound(tmp_path: Path) -> None:
    code = "import sys\nfor i in range(10000): print(f'line {i}')\nprint('fatal final', file=sys.stderr)"
    result, _ = run_projected([sys.executable, "-c", code], state_root=tmp_path)
    assert result.truncated
    assert len(result.relevant_lines) <= 20
    assert "fatal final" in result.relevant_lines
    assert Path(result.artifact).parent.joinpath("stdout.bin").stat().st_size > 80000

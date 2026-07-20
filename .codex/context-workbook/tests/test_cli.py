from __future__ import annotations

import json
import os
import subprocess
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
WORKBOOK_ROOT = REPO_ROOT / ".codex/context-workbook"
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "sufficient-decision.json"


class CliTests(unittest.TestCase):
    def test_browserless_adapter_runs_canonical_workbook(self) -> None:
        environment = dict(os.environ)
        environment["CONTEXT_WORKBOOK_TEST_MODE"] = "1"
        environment["PYTHONPATH"] = str(WORKBOOK_ROOT / "src")
        process = subprocess.run(
            [
                sys.executable,
                str(WORKBOOK_ROOT / "workbook_cli.py"),
                "--repo-root",
                str(REPO_ROOT),
                "--prompt",
                "Implement Issue 54",
                "--revision",
                "main",
                "--recorded-decision",
                str(FIXTURE),
                "--output",
                "all",
            ],
            capture_output=True,
            text=True,
            env=environment,
            check=False,
            timeout=60,
        )
        self.assertEqual(process.returncode, 0, process.stderr)
        result = json.loads(process.stdout)
        self.assertEqual(result["schema"], "dotfiles.context-workbook-result.v0")
        self.assertEqual(result["state"]["sufficiency"]["state"], "sufficient")


if __name__ == "__main__":
    unittest.main()

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path

import pytest
from pydantic import ValidationError

from codex_profile.contracts import (
    CommandManifest,
    CommandResult,
    ContractViolation,
    Handoff,
)
from codex_profile.qualification import qualify

ROOT = Path(__file__).resolve().parents[1]


def test_executable_property_equality_gate(tmp_path: Path) -> None:
    report = qualify(tmp_path / "property-report.json")
    expected = set(report["declaredIDs"])
    assert expected == set(report["generatedIDs"])
    assert expected == set(report["executedIDs"])
    assert expected == set(report["reportedIDs"])
    assert expected == {entry["id"] for entry in report["cases"]}
    assert all(entry["mutationAttempted"] and entry["status"] == "passed" for entry in report["cases"])


def test_generated_catalog_is_complete_document() -> None:
    document = json.loads(
        (ROOT / "contracts/generated/handoff-properties.json").read_text(encoding="utf-8")
    )
    assert document["schema"] == "codex-profile-executable-properties.v0"
    assert all(
        {"baseline", "mutation", "adapterOperation", "expectedResult", "rejectionCode"}
        <= set(case)
        for case in document["cases"].values()
    )


@pytest.mark.parametrize(
    ("model", "field", "value"),
    [
        (CommandManifest, "durationSeconds", -1),
        (CommandManifest, "signal", -1),
        (CommandManifest, "stdoutBytes", -1),
        (CommandManifest, "stderrBytes", -1),
        (CommandResult, "signal", -1),
    ],
)
def test_negative_runtime_numbers_rejected(model, field: str, value: int) -> None:
    manifest = {
        "schema": "codex.command-artifact.v0",
        "argv": ["tool"],
        "workingDirectory": "/tmp",
        "startedAt": datetime.now(timezone.utc),
        "durationSeconds": 0,
        "exitCode": 0,
        "signal": None,
        "stdoutBytes": 0,
        "stderrBytes": 0,
        "stdoutSha256": "0" * 64,
        "stderrSha256": "0" * 64,
    }
    result = {
        "schema": "codex.command-result.v0",
        "exitCode": 0,
        "signal": None,
        "truncated": False,
        "relevantLines": [],
        "artifact": "/tmp/manifest",
        "sha256": "0" * 64,
    }
    candidate = manifest if model is CommandManifest else result
    candidate[field] = value
    with pytest.raises(ValidationError):
        model.model_validate(candidate)


def test_timezone_root_and_argv_parity() -> None:
    value = {
        "schema": "codex.command-artifact.v0",
        "argv": ["tool", "", "--"],
        "workingDirectory": "/tmp",
        "startedAt": datetime(2026, 7, 23),
        "durationSeconds": 0,
        "exitCode": 0,
        "signal": None,
        "stdoutBytes": 0,
        "stderrBytes": 0,
        "stdoutSha256": "0" * 64,
        "stderrSha256": "0" * 64,
    }
    with pytest.raises(ValidationError):
        CommandManifest.model_validate(value)
    value["startedAt"] = datetime(2026, 7, 23, tzinfo=timezone.utc)
    assert CommandManifest.model_validate(value).argv == ["tool", "", "--"]
    value["argv"] = ["", "argument"]
    with pytest.raises(ValidationError):
        CommandManifest.model_validate(value)


def test_cue_unavailable_fails_closed(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("CODEX_PROFILE_CUE", str(tmp_path / "missing-cue"))
    with pytest.raises(ContractViolation, match="contract.unavailable"):
        qualify(tmp_path / "report.json")

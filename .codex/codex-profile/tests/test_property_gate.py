from __future__ import annotations

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from codex_profile.contracts import CommandManifest, CommandResult, Handoff, canonical_bytes
from codex_profile.handoff import HANDOFF_LIMIT, markdown
from codex_profile.runner import RESULT_LIMIT

ROOT = Path(__file__).resolve().parents[1]
PREFIXES = ("handoff.", "command.")


def sample_handoff() -> Handoff:
    return Handoff.model_validate({
        "schema": "codex.handoff.v0", "createdAt": datetime(2026, 7, 23, 12, 34, 56, 123456, timezone.utc),
        "objective": "objective", "invariants": [], "decisions": [],
        "repository": {"root": "/tmp/repo", "revision": "a" * 40, "branch": None,
                       "dirtyPaths": [], "stagedPaths": []},
        "validation": {"passing": [], "failing": [], "notRun": []},
        "currentOperation": "current", "nextOperation": "next",
        "completionCriteria": ["done"], "evidencePointers": [], "openQuestions": [],
    })


def test_handoff_property_equality_gate(tmp_path: Path) -> None:
    catalog = json.loads(subprocess.check_output(
        ["cue", "export", "-e", "assertionCatalog"], cwd=ROOT / "contracts", text=True
    ))
    declared = {key for key in catalog["properties"] if key.startswith(PREFIXES)}
    generated_doc = json.loads((ROOT / "contracts/generated/handoff-properties.json").read_text())
    generated = set(generated_doc["propertyIds"])
    packet = sample_handoff()
    runners = {
        "handoff.readiness-required": lambda: bool(packet.objective and packet.current_operation and packet.next_operation and packet.completion_criteria),
        "handoff.repository-identity": lambda: len(packet.repository.revision) in (40, 64) and Path(packet.repository.root).is_absolute(),
        "handoff.size-bounded": lambda: len(canonical_bytes(packet)) <= HANDOFF_LIMIT and len(markdown(packet).encode()) <= HANDOFF_LIMIT,
        "handoff.projection-deterministic": lambda: canonical_bytes(packet) == canonical_bytes(packet) and markdown(packet) == markdown(packet),
        "command.artifact-complete": lambda: {"stdout_bytes", "stderr_bytes", "stdout_sha256", "stderr_sha256"} <= set(CommandManifest.model_fields),
        "command.projection-bounded": lambda: RESULT_LIMIT == 4096 and CommandResult.model_fields["relevant_lines"].metadata[0].max_length == 20,
    }
    executed = {property_id for property_id, runner in runners.items() if runner()}
    report_path = tmp_path / "property-report.json"
    report_path.write_text(json.dumps({"schema": "codex-profile-property-report.v0", "passed": sorted(executed)}, sort_keys=True))
    reported_doc = json.loads(report_path.read_text())
    assert set(reported_doc) == {"schema", "passed"}
    reported = set(reported_doc["passed"])
    assert declared == generated == executed == reported

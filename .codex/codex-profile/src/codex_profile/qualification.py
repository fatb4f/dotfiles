from __future__ import annotations

import hashlib
import json
import os
from copy import deepcopy
from datetime import datetime, timezone
from pathlib import Path
import subprocess

from codex_profile.contracts import (
    ContractViolation,
    Repository,
    admit_command_artifact,
    admit_command_result,
    admit_handoff,
    canonical_bytes,
)
from codex_profile.handoff import HANDOFF_LIMIT, markdown


def _handoff_value() -> dict:
    return {
        "schema": "codex.handoff.v0",
        "createdAt": datetime(2026, 7, 23, 12, 34, 56, 123456, timezone.utc),
        "objective": "objective",
        "invariants": ["a", "b"],
        "decisions": ["one", "two"],
        "repository": {
            "root": "/tmp/repo",
            "revision": "a" * 40,
            "branch": None,
            "dirtyPaths": ["a", "b"],
            "stagedPaths": [],
        },
        "validation": {"passing": [], "failing": [], "notRun": []},
        "currentOperation": "current",
        "nextOperation": "next",
        "completionCriteria": ["done"],
        "evidencePointers": [],
        "openQuestions": [],
    }


def _authority(value: dict) -> Repository:
    return Repository.model_validate(value["repository"])


def _remove_readiness(value: dict, _: Path) -> dict:
    value.pop("nextOperation")
    return value


def _change_repository(value: dict, _: Path) -> dict:
    value["repository"]["revision"] = "b" * 40
    return value


def _exceed_handoff(value: dict, _: Path) -> dict:
    value["objective"] = "x" * (HANDOFF_LIMIT + 1)
    return value


def _reorder_handoff(value: dict, _: Path) -> dict:
    return dict(reversed(list(value.items())))


def _command_artifact(root: Path) -> tuple[dict, Path]:
    directory = root / "artifact"
    directory.mkdir()
    (directory / "stdout.bin").write_bytes(b"ok\n")
    (directory / "stderr.bin").write_bytes(b"")
    return {
        "schema": "codex.command-artifact.v0",
        "argv": ["tool", "", "--"],
        "workingDirectory": "/tmp",
        "startedAt": datetime(2026, 7, 23, tzinfo=timezone.utc),
        "durationSeconds": 0,
        "exitCode": 0,
        "signal": None,
        "stdoutBytes": 3,
        "stderrBytes": 0,
        "stdoutSha256": hashlib.sha256(b"ok\n").hexdigest(),
        "stderrSha256": hashlib.sha256(b"").hexdigest(),
    }, directory


def _remove_output(value: dict, root: Path) -> dict:
    (root / "artifact" / "stdout.bin").unlink()
    return value


def _oversized_result(root: Path) -> tuple[dict, Path]:
    manifest = root / "manifest.json"
    manifest.write_bytes(b"{}\n")
    return {
        "schema": "codex.command-result.v0",
        "exitCode": 0,
        "signal": None,
        "truncated": True,
        "relevantLines": ["x" * 500 for _ in range(20)],
        "artifact": str(manifest),
        "sha256": hashlib.sha256(manifest.read_bytes()).hexdigest(),
    }, manifest


MUTATIONS = {
    "handoff.remove-readiness": _remove_readiness,
    "handoff.change-repository": _change_repository,
    "handoff.exceed-projection": _exceed_handoff,
    "handoff.reorder-input": _reorder_handoff,
    "command.remove-output": _remove_output,
    "command.exceed-projection": lambda value, root: value,
}


def _operate_admit_handoff(value: dict, context: dict, _: dict) -> None:
    admit_handoff(value, repository_authority=context["authority"])


def _operate_project_handoff(value: dict, context: dict, case: dict) -> None:
    packet = admit_handoff(value, repository_authority=context["authority"])
    json_data, md_data = canonical_bytes(packet), markdown(packet).encode()
    if len(json_data) > HANDOFF_LIMIT or len(md_data) > HANDOFF_LIMIT:
        raise ContractViolation("handoff.size-exceeded", "projection too large")
    expected = case.get("expectedProjectionDigests")
    if expected and {
        "json": "sha256:" + hashlib.sha256(json_data).hexdigest(),
        "markdown": "sha256:" + hashlib.sha256(md_data).hexdigest(),
    } != expected:
        raise ContractViolation(
            "handoff.projection-nondeterministic", "projection digest mismatch"
        )


def _operate_admit_artifact(value: dict, context: dict, _: dict) -> None:
    admit_command_artifact(value, artifact_directory=context["directory"])


def _operate_admit_result(value: dict, context: dict, _: dict) -> None:
    admit_command_result(value, artifact_path=context["manifest"])


OPERATIONS = {
    "admit-handoff": _operate_admit_handoff,
    "project-handoff": _operate_project_handoff,
    "admit-command-artifact": _operate_admit_artifact,
    "admit-command-result": _operate_admit_result,
}


def _load_catalog(contract_root: Path) -> tuple[dict, set[str]]:
    cue = os.environ.get("CODEX_PROFILE_CUE", "cue")
    try:
        executable = subprocess.check_output(
            [cue, "export", "-e", "handoffExecutableCatalog"],
            cwd=contract_root,
            text=True,
        )
        assertions = subprocess.check_output(
            [cue, "export", "-e", "assertionCatalog"],
            cwd=contract_root,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        raise ContractViolation("contract.unavailable", str(error)) from error
    generated = json.loads(
        (contract_root / "generated/handoff-properties.json").read_text(encoding="utf-8")
    )
    exported = json.loads(executable)
    if generated != exported:
        raise ContractViolation("qualification.generated-stale", "generated property catalog is stale")
    declared = {
        key
        for key in json.loads(assertions)["properties"]
        if key.startswith(("handoff.", "command."))
    }
    return generated, declared


def qualify(report_path: Path, *, contract_root: Path | None = None) -> dict:
    root = contract_root or Path(__file__).resolve().parents[2] / "contracts"
    catalog, declared = _load_catalog(root)
    generated = set(catalog["cases"])
    if set(MUTATIONS) != {case["mutation"] for case in catalog["cases"].values()}:
        raise ContractViolation("qualification.coverage-mismatch", "mutation registry is not exact")
    if set(OPERATIONS) != {
        case["adapterOperation"] for case in catalog["cases"].values()
    }:
        raise ContractViolation("qualification.coverage-mismatch", "operation registry is not exact")
    records = []
    executed: set[str] = set()
    work = report_path.parent / ".qualification-work"
    work.mkdir(parents=True, exist_ok=True)
    for property_id, case in catalog["cases"].items():
        case_root = work / property_id
        case_root.mkdir(parents=True, exist_ok=True)
        rejection_code = None
        actual = "accept"
        if case["baseline"] == "handoff.valid":
            baseline = _handoff_value()
            context = {"authority": _authority(baseline)}
            mutated = MUTATIONS[case["mutation"]](deepcopy(baseline), case_root)
        elif case["baseline"] == "command.artifact-valid":
            baseline, directory = _command_artifact(case_root)
            context = {"directory": directory}
            mutated = MUTATIONS[case["mutation"]](deepcopy(baseline), case_root)
        else:
            baseline, manifest = _oversized_result(case_root)
            context = {"manifest": manifest}
            mutated = MUTATIONS[case["mutation"]](deepcopy(baseline), case_root)
        try:
            OPERATIONS[case["adapterOperation"]](mutated, context, case)
        except ContractViolation as error:
            actual, rejection_code = "reject", error.code
        if actual != case["expectedResult"] or rejection_code != case["rejectionCode"]:
            raise ContractViolation(
                "qualification.case-failed",
                f"{property_id}: got {actual}/{rejection_code}",
            )
        executed.add(property_id)
        records.append(
            {
                "id": property_id,
                "mutationAttempted": True,
                "actualResult": actual,
                "rejectionCode": rejection_code,
                "status": "passed",
            }
        )
    ids = sorted(executed)
    if declared != generated or generated != executed:
        raise ContractViolation("qualification.coverage-mismatch", "declared/generated/executed differ")
    report = {
        "schema": "codex-profile-property-report.v0",
        "declaredIDs": sorted(declared),
        "generatedIDs": sorted(generated),
        "executedIDs": ids,
        "reportedIDs": ids,
        "cases": records,
    }
    report_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    persisted = json.loads(report_path.read_text(encoding="utf-8"))
    if set(persisted["reportedIDs"]) != executed:
        raise ContractViolation("qualification.coverage-mismatch", "persisted report differs")
    cue = os.environ.get("CODEX_PROFILE_CUE", "cue")
    result = subprocess.run(
        [cue, "vet", ".", str(report_path), "-d", "#QualificationReport"],
        cwd=root,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode:
        raise ContractViolation(
            "qualification.report-invalid",
            result.stderr.decode("utf-8", "replace").strip(),
        )
    return persisted

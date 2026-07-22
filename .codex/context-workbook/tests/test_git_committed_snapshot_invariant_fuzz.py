from __future__ import annotations

import copy
import hashlib
import json
import os
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any, Literal

from hypothesis import HealthCheck, given, settings, strategies as st

DocumentKind = Literal["observation", "projection"]

MUTATION_IDS = {
    "unknown-field-rejected",
    "duplicate-path-rejected",
    "unsorted-path-rejected",
    "incompatible-mode-rejected",
    "non-normalized-path-rejected",
    "noncanonical-revision-rejected",
    "malformed-object-id-rejected",
    "malformed-digest-rejected",
    "opaque-symlink-descendant-rejected",
    "opaque-submodule-descendant-rejected",
    "elevated-authority-rejected",
}


@dataclass(frozen=True)
class MutationCase:
    property_id: str
    definition: str
    document_kind: DocumentKind
    document: dict[str, Any]


def _repo_root() -> Path:
    configured = os.environ.get("CONTEXT_GRAPH_REPO_ROOT")
    if configured:
        return Path(configured).resolve()
    return Path(__file__).resolve().parents[3]


@lru_cache(maxsize=1)
def _isolated_model_root() -> Path:
    source = _repo_root() / ".codex" / "context-model"
    temporary = Path(tempfile.mkdtemp(prefix="git-snapshot-fuzz-model-"))
    target = temporary / "context-model"
    shutil.copytree(source, target)
    module_file = target / "cue.mod" / "module.cue"
    if not module_file.exists():
        module_file.parent.mkdir()
        module_file.write_text(
            'module: "example.com/contextmodel@v0"\n'
            'language: {version: "v0.18.0"}\n',
            encoding="utf-8",
        )
    return target


def _run_cue(*arguments: str) -> subprocess.CompletedProcess[str]:
    model_root = _isolated_model_root()
    return subprocess.run(
        [os.environ.get("CONTEXT_GRAPH_CUE", "cue"), *arguments],
        cwd=model_root,
        env={
            **os.environ,
            "CUE_CACHE_DIR": str(model_root.parent / "cache"),
        },
        check=False,
        capture_output=True,
        text=True,
    )


def _cue_accepts(definition: str, document: dict[str, Any]) -> tuple[bool, str]:
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".json", encoding="utf-8", delete=False
    ) as handle:
        json.dump(document, handle, separators=(",", ":"), sort_keys=True)
        handle.write("\n")
        document_path = Path(handle.name)
    try:
        completed = _run_cue("vet", ".:contextmodel", str(document_path), "-d", definition)
    finally:
        document_path.unlink(missing_ok=True)
    return completed.returncode == 0, completed.stderr.strip()


def _canonical_json(document: dict[str, Any]) -> str:
    return json.dumps(document, separators=(",", ":"), sort_keys=True)


def _write_assertion_candidate(case: MutationCase) -> Path:
    document_json = _canonical_json(case.document)
    document_digest = "sha256:" + hashlib.sha256(document_json.encode()).hexdigest()
    candidate = {
        "schema": "kernel.git-committed-snapshot-assertion-candidate.v0",
        "propertyID": case.property_id,
        "mutationID": case.property_id,
        "documentKind": case.document_kind,
        "expected": "reject",
        "observed": "accept",
        "documentJSON": document_json,
        "documentDigest": document_digest,
    }
    output_root = Path(
        os.environ.get(
            "CONTEXT_GIT_ASSERTION_CANDIDATE_DIR",
            str(Path(tempfile.gettempdir()) / "context-git-assertion-candidates"),
        )
    )
    output_root.mkdir(parents=True, exist_ok=True)
    digest_path = output_root / f"{case.property_id}-{document_digest.removeprefix('sha256:')}.json"
    latest_path = output_root / f"{case.property_id}.latest.json"
    payload = json.dumps(candidate, indent=2, sort_keys=True) + "\n"
    digest_path.write_text(payload, encoding="utf-8")
    latest_path.write_text(payload, encoding="utf-8")

    accepted, diagnostics = _cue_accepts("#GitCommittedSnapshotAssertionCandidate", candidate)
    if not accepted:
        raise AssertionError(f"assertion candidate envelope rejected: {diagnostics}")
    return latest_path


_identifier = st.from_regex(r"[a-z][a-z0-9]{0,7}", fullmatch=True)
_hex40 = st.binary(min_size=20, max_size=20).map(bytes.hex)


@st.composite
def valid_observations(draw: st.DrawFn) -> dict[str, Any]:
    directory = draw(_identifier)
    filename = draw(_identifier) + ".txt"
    commit = draw(_hex40)
    root_tree = draw(_hex40)
    directory_tree = draw(_hex40)
    blob = draw(_hex40)
    return {
        "schema": "kernel.git-committed-snapshot-observation.v0",
        "repositoryID": "repo." + draw(_identifier),
        "requestedRevision": commit,
        "resolvedRevision": {"format": "sha1", "hex": commit},
        "rootTree": {"format": "sha1", "hex": root_tree},
        "occurrences": [
            {
                "path": directory,
                "mode": "040000",
                "kind": "tree",
                "objectID": {"format": "sha1", "hex": directory_tree},
            },
            {
                "path": f"{directory}/{filename}",
                "mode": "100644",
                "kind": "blob",
                "objectID": {"format": "sha1", "hex": blob},
                "size": 1,
            },
        ],
        "hydrator": {
            "identity": "context-git-hydrator",
            "digest": "sha256:" + "1a" * 32,
        },
    }


@lru_cache(maxsize=1)
def _valid_projection() -> dict[str, Any]:
    observation = {
        "schema": "kernel.git-committed-snapshot-observation.v0",
        "repositoryID": "repo.fixture",
        "requestedRevision": "a" * 40,
        "resolvedRevision": {"format": "sha1", "hex": "a" * 40},
        "rootTree": {"format": "sha1", "hex": "b" * 40},
        "occurrences": [
            {
                "path": "file.txt",
                "mode": "100644",
                "kind": "blob",
                "objectID": {"format": "sha1", "hex": "c" * 40},
                "size": 1,
            }
        ],
        "hydrator": {
            "identity": "context-git-hydrator",
            "digest": "sha256:" + "12" * 32,
        },
    }
    fixture_path = _isolated_model_root() / "fuzz_projection_fixture.cue"
    fixture_path.write_text(
        "package contextmodel\n"
        "fuzzProjection: #GitCommittedSnapshotProjection & {\n"
        f"observation: {json.dumps(observation, separators=(',', ':'))}\n"
        f"schemaDigest: \"sha256:{'2a' * 32}\"\n"
        f"policyDigest: \"sha256:{'3b' * 32}\"\n"
        "}\n",
        encoding="utf-8",
    )
    completed = _run_cue(
        "export", ".:contextmodel", "-e", "fuzzProjection", "--out", "json"
    )
    fixture_path.unlink(missing_ok=True)
    if completed.returncode != 0:
        raise RuntimeError(f"CUE projection export failed: {completed.stderr.strip()}")
    return json.loads(completed.stdout)


@st.composite
def invalid_snapshot_mutations(draw: st.DrawFn) -> MutationCase:
    property_id = draw(st.sampled_from(sorted(MUTATION_IDS)))
    if property_id == "elevated-authority-rejected":
        document = copy.deepcopy(_valid_projection())
        document["collected"]["state"]["effectiveAuthority"] = "controller"
        return MutationCase(property_id, "#GitCommittedSnapshotProjection", "projection", document)

    document = draw(valid_observations())
    occurrences = document["occurrences"]
    if property_id == "unknown-field-rejected":
        document["unknown"] = True
    elif property_id == "duplicate-path-rejected":
        occurrences.append(copy.deepcopy(occurrences[-1]))
        occurrences.sort(key=lambda item: item["path"])
    elif property_id == "unsorted-path-rejected":
        occurrences.reverse()
    elif property_id == "incompatible-mode-rejected":
        occurrences[-1]["mode"] = "160000"
    elif property_id == "non-normalized-path-rejected":
        occurrences[-1]["path"] = occurrences[0]["path"] + "/../escape"
    elif property_id == "noncanonical-revision-rejected":
        document["requestedRevision"] = "main"
    elif property_id == "malformed-object-id-rejected":
        occurrences[-1]["objectID"]["hex"] = "not-hex"
    elif property_id == "malformed-digest-rejected":
        document["hydrator"]["digest"] = "sha256:short"
    elif property_id == "opaque-symlink-descendant-rejected":
        occurrences[:] = [
            {
                "path": "link",
                "mode": "120000",
                "kind": "symlink",
                "objectID": {"format": "sha1", "hex": "d" * 40},
                "size": 8,
            },
            {
                "path": "link/child",
                "mode": "100644",
                "kind": "blob",
                "objectID": {"format": "sha1", "hex": "e" * 40},
                "size": 1,
            },
        ]
    elif property_id == "opaque-submodule-descendant-rejected":
        occurrences[:] = [
            {
                "path": "vendor",
                "mode": "160000",
                "kind": "submodule",
                "objectID": {"format": "sha1", "hex": "d" * 40},
            },
            {
                "path": "vendor/child",
                "mode": "100644",
                "kind": "blob",
                "objectID": {"format": "sha1", "hex": "e" * 40},
                "size": 1,
            },
        ]
    else:  # pragma: no cover
        raise AssertionError(property_id)
    return MutationCase(property_id, "#GitCommittedSnapshotObservation", "observation", document)


def test_fuzz_property_manifest_matches_mutation_schema() -> None:
    completed = _run_cue(
        "export",
        ".:contextmodel",
        "-e",
        "gitCommittedSnapshotFuzzProperties",
        "--out",
        "json",
    )
    assert completed.returncode == 0, completed.stderr
    assert set(json.loads(completed.stdout)) == MUTATION_IDS


@settings(max_examples=24, deadline=None, derandomize=True)
@given(observation=valid_observations())
def test_generated_valid_observations_are_admitted(observation: dict[str, Any]) -> None:
    accepted, diagnostics = _cue_accepts("#GitCommittedSnapshotObservation", observation)
    assert accepted, diagnostics


@settings(
    max_examples=96,
    deadline=None,
    derandomize=True,
    suppress_health_check=[HealthCheck.filter_too_much],
)
@given(case=invalid_snapshot_mutations())
def test_backward_fuzzer_rejects_invariant_mutations(case: MutationCase) -> None:
    accepted, diagnostics = _cue_accepts(case.definition, case.document)
    if accepted:
        candidate_path = _write_assertion_candidate(case)
        raise AssertionError(
            f"CUE accepted {case.property_id}; minimized assertion candidate: {candidate_path}"
        )
    assert diagnostics

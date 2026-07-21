from __future__ import annotations

import copy

from hypothesis import HealthCheck, given, settings, strategies as st

from context_workbook.context_graph_admission import (
    ADMISSION_SCENARIOS,
    AUTHORITY_LEVELS,
    CollectedEvidenceEnvelope,
    EvidenceAdmissionBundle,
    EvidenceAdmissionTransition,
    EvidenceAuthorityProjection,
    EvidenceNoAdmissionTransition,
    build_admission_transition,
    build_authority_state,
    cue_accepts_admission,
    execute_admission_matrix,
    load_evidence_admission_matrix,
)
from context_workbook.context_graph_properties import cue_vet

MATRIX = load_evidence_admission_matrix()


def test_admission_matrix_is_complete_and_executable() -> None:
    report = execute_admission_matrix(MATRIX)
    expected = {
        f"admission.{from_authority}.{to_authority}.{scenario}"
        for from_authority in AUTHORITY_LEVELS
        for to_authority in AUTHORITY_LEVELS
        for scenario in ADMISSION_SCENARIOS
    }
    assert set(report["expectedCaseIDs"]) == expected
    assert set(report["generatedCaseIDs"]) == expected
    assert set(report["executedCaseIDs"]) == expected
    assert set(report["reportedCaseIDs"]) == expected


@settings(
    max_examples=16,
    deadline=None,
    derandomize=True,
    suppress_health_check=[HealthCheck.too_slow],
)
@given(authority=st.sampled_from(AUTHORITY_LEVELS))
def test_no_admission_and_replay_are_deterministic(authority: str) -> None:
    preserved = build_admission_transition(authority, authority, "no-admission")
    assert cue_accepts_admission(preserved, "no-admission")
    EvidenceNoAdmissionTransition.model_validate(preserved)

    replay = build_admission_transition(authority, authority, "valid-admission")
    assert cue_accepts_admission(replay, "valid-admission")
    EvidenceAdmissionTransition.model_validate(replay)


@settings(
    max_examples=12,
    deadline=None,
    derandomize=True,
    suppress_health_check=[HealthCheck.too_slow],
)
@given(
    scenario=st.sampled_from(
        [
            "wrong-evidence-id",
            "wrong-evidence-digest",
            "wrong-snapshot",
            "wrong-policy-digest",
        ]
    )
)
def test_admission_is_bound_to_exact_evidence_and_provenance(scenario: str) -> None:
    value = build_admission_transition("candidate", "controller", scenario)
    assert not cue_accepts_admission(value, scenario)
    try:
        EvidenceAdmissionTransition.model_validate(value)
    except ValueError:
        pass
    else:
        raise AssertionError(f"Pydantic accepted malformed admission: {scenario}")


def test_collection_and_projection_cannot_widen_authority() -> None:
    state = build_authority_state("candidate")
    collection = {
        "schema": "kernel.context-evidence-collection.v0",
        "state": state,
        "admission": None,
    }
    assert cue_vet("#ContextCollectedEvidenceEnvelope", collection).accepted
    CollectedEvidenceEnvelope.model_validate(collection)

    widened = copy.deepcopy(collection)
    widened["state"]["effectiveAuthority"] = "controller"
    assert not cue_vet("#ContextCollectedEvidenceEnvelope", widened).accepted
    try:
        CollectedEvidenceEnvelope.model_validate(widened)
    except ValueError:
        pass
    else:
        raise AssertionError("collection widened effective authority")

    projection = {
        "schema": "kernel.context-evidence-authority-projection.v0",
        "projectionKind": "duckdb-materialization",
        "source": state,
        "projected": copy.deepcopy(state),
    }
    assert cue_vet("#ContextEvidenceAuthorityProjection", projection).accepted
    EvidenceAuthorityProjection.model_validate(projection)
    projection["projected"]["effectiveAuthority"] = "root"
    assert not cue_vet("#ContextEvidenceAuthorityProjection", projection).accepted


def test_unrelated_valid_evidence_extension_preserves_admission() -> None:
    transition = build_admission_transition("candidate", "controller", "valid-admission")
    bundle = {
        "schema": "kernel.context-evidence-admission-bundle.v0",
        "states": {"evidence.context-admission": transition["after"]},
        "admissions": {"admission.context-evidence": transition},
    }
    assert cue_vet("#ContextEvidenceAdmissionBundle", bundle).accepted
    EvidenceAdmissionBundle.model_validate(bundle)

    extended = copy.deepcopy(bundle)
    unrelated = build_authority_state("none")
    unrelated["evidenceID"] = "evidence.unrelated"
    unrelated["evidence"]["payloadDigest"] = "sha256:" + "8" * 64
    extended["states"]["evidence.unrelated"] = unrelated
    assert cue_vet("#ContextEvidenceAdmissionBundle", extended).accepted
    EvidenceAdmissionBundle.model_validate(extended)

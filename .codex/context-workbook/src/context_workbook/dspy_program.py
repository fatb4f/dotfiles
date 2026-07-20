"""DSPy context-establishment program and explicit test-only recorded adapter."""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Protocol

from .models import ContextDecision, ContextInventory, ContextRequest, Evidence, SourceObservation


class ContextReasoner(Protocol):
    def establish(
        self,
        *,
        request: ContextRequest,
        inventory: ContextInventory,
        observations: dict[str, SourceObservation],
        evidence: dict[str, Evidence],
        code_intel: dict[str, object],
    ) -> ContextDecision: ...


class DspyUnavailable(RuntimeError):
    pass


def _dspy_module():
    try:
        import dspy  # type: ignore
    except ImportError as error:
        raise DspyUnavailable(
            "DSPy is required for production context establishment; install the locked workbook project"
        ) from error
    return dspy


class DspyContextProgram:
    """LM-backed DSPy program. It produces typed inference deltas only."""

    def __init__(self, *, model: str | None = None) -> None:
        dspy = _dspy_module()

        class EstablishContext(dspy.Signature):
            """Establish bounded high-fidelity context from typed evidence.

            Never invent source facts. Select only IDs and paths present in the inputs.
            Report every unresolved gap and conflict. Context sufficiency is not task success.
            """

            request_json = dspy.InputField(desc="Closed context request JSON")
            inventory_json = dspy.InputField(desc="Available fragments, providers, and workflows")
            observations_json = dspy.InputField(desc="Bounded source observations")
            evidence_json = dspy.InputField(desc="Evidence derived from observations")
            code_intel_json = dspy.InputField(desc="Read-only code-intel declarations")
            decision_json = dspy.OutputField(desc="One JSON object matching ContextDecision")

        if model:
            dspy.configure(lm=dspy.LM(model))
        self._predict = dspy.ChainOfThought(EstablishContext)

    def establish(
        self,
        *,
        request: ContextRequest,
        inventory: ContextInventory,
        observations: dict[str, SourceObservation],
        evidence: dict[str, Evidence],
        code_intel: dict[str, object],
    ) -> ContextDecision:
        result = self._predict(
            request_json=request.model_dump_json(by_alias=True),
            inventory_json=inventory.model_dump_json(by_alias=True),
            observations_json=json.dumps(
                {key: value.model_dump(by_alias=True) for key, value in observations.items()},
                sort_keys=True,
            ),
            evidence_json=json.dumps(
                {key: value.model_dump(by_alias=True) for key, value in evidence.items()},
                sort_keys=True,
            ),
            code_intel_json=json.dumps(code_intel, sort_keys=True),
        )
        raw = getattr(result, "decision_json", None)
        if not isinstance(raw, str):
            raise DspyUnavailable("DSPy did not return decision_json")
        return ContextDecision.model_validate_json(raw)


class RecordedContextProgram:
    """Test-only deterministic adapter; never selected implicitly in production."""

    def __init__(self, decision: ContextDecision) -> None:
        self._decision = decision

    @classmethod
    def from_path(cls, path: Path) -> "RecordedContextProgram":
        if os.environ.get("CONTEXT_WORKBOOK_TEST_MODE") != "1":
            raise DspyUnavailable("recorded predictions are restricted to explicit test mode")
        return cls(ContextDecision.model_validate_json(path.read_text(encoding="utf-8")))

    def establish(self, **_: object) -> ContextDecision:
        return self._decision


def production_reasoner() -> DspyContextProgram:
    model = os.environ.get("CONTEXT_WORKBOOK_DSPY_MODEL")
    if not model:
        raise DspyUnavailable("CONTEXT_WORKBOOK_DSPY_MODEL is required; lexical fallback is forbidden")
    return DspyContextProgram(model=model)

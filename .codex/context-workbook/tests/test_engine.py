from __future__ import annotations

import json
import os
import unittest
from pathlib import Path
from unittest.mock import patch

from context_workbook.dspy_program import RecordedContextProgram
from context_workbook.engine import (
    ContextEngine,
    EngineError,
    build_request,
    load_workbook_config,
    production_reasoner_or_fail_closed,
)
from context_workbook.models import ContextDecision, ContextRequest


REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "sufficient-decision.json"


class EngineTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        os.environ["CONTEXT_WORKBOOK_TEST_MODE"] = "1"
        cls.config = load_workbook_config(REPO_ROOT)
        cls.decision = ContextDecision.model_validate_json(FIXTURE.read_text(encoding="utf-8"))

    def request(self, prompt: str = "Implement Issue 54"):
        return build_request(prompt=prompt, revision="HEAD", config=self.config)

    def test_establishes_cue_valid_context_and_packet(self) -> None:
        result = ContextEngine(root=REPO_ROOT).run(
            request=self.request(), reasoner=RecordedContextProgram(self.decision)
        )
        self.assertEqual(result.state.sufficiency.state, "sufficient")
        self.assertIsNotNone(result.state.projection)
        assert result.state.projection is not None
        self.assertIn("resolver.context-workbook", result.state.projection.selected.fragment_ids)
        self.assertEqual(result.code_intel_projection["authority"], False)
        self.assertEqual(
            json.loads(result.hook_projection["hookSpecificOutput"]["additionalContext"])["schema"],
            "agent.resolver-prompt-surface.v2",
        )

    def test_prompt_change_invalidates_dependent_nodes_only(self) -> None:
        first = ContextEngine(root=REPO_ROOT).run(
            request=self.request("Implement Issue 54"), reasoner=RecordedContextProgram(self.decision)
        )
        second = ContextEngine(root=REPO_ROOT).run(
            request=self.request("Inspect Issue 54"), reasoner=RecordedContextProgram(self.decision)
        )
        self.assertEqual(first.trace["inventory"], second.trace["inventory"])
        self.assertEqual(first.trace["code-intel"], second.trace["code-intel"])
        self.assertNotEqual(first.trace["prompt"], second.trace["prompt"])
        self.assertNotEqual(first.trace["projection"], second.trace["projection"])

    def test_unknown_provider_fails_closed(self) -> None:
        value = self.decision.model_dump(by_alias=True)
        value["providers"]["ids"] = ["unknown-provider"]
        decision = ContextDecision.model_validate(value)
        with self.assertRaises(EngineError):
            ContextEngine(root=REPO_ROOT).run(
                request=self.request(), reasoner=RecordedContextProgram(decision)
            )

    def test_outside_file_fails_closed(self) -> None:
        value = self.decision.model_dump(by_alias=True)
        value["files"]["ids"] = [".github/workflows/cue-contracts.yml"]
        decision = ContextDecision.model_validate(value)
        with self.assertRaises(EngineError):
            ContextEngine(root=REPO_ROOT).run(
                request=self.request(), reasoner=RecordedContextProgram(decision)
            )

    def test_request_file_cannot_widen_configured_paths(self) -> None:
        payload = self.request().model_dump(by_alias=True)
        payload["allowedPaths"] = ["."]
        request = ContextRequest.model_validate(payload)
        with self.assertRaisesRegex(EngineError, "widens configured path boundary"):
            ContextEngine(root=REPO_ROOT).run(
                request=request, reasoner=RecordedContextProgram(self.decision)
            )

    def test_requested_revision_controls_inventory_materialization(self) -> None:
        request = build_request(
            prompt="Inspect the base revision",
            revision="37427466cdf45c38b2d61c6e4152bf13d4699a1f",
            config=self.config,
        )
        with self.assertRaisesRegex(EngineError, "unknown fragments"):
            ContextEngine(root=REPO_ROOT).run(
                request=request, reasoner=RecordedContextProgram(self.decision)
            )

    def test_repository_observation_records_resolved_commit(self) -> None:
        result = ContextEngine(root=REPO_ROOT).run(
            request=self.request(), reasoner=RecordedContextProgram(self.decision)
        )
        facts = result.state.observations["repository.current"].facts
        self.assertEqual(facts["requestedRevision"], "HEAD")
        self.assertRegex(facts["resolvedRevision"], r"^[0-9a-f]{40}$")

    def test_missing_model_uses_shared_fail_closed_program(self) -> None:
        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("CONTEXT_WORKBOOK_DSPY_MODEL", None)
            reasoner = production_reasoner_or_fail_closed()
        decision = reasoner.establish()
        self.assertIn("gap.dspy-unavailable", decision.gaps)
        self.assertEqual(decision.sufficiency_state, "insufficient")

    def test_complete_gap_map_overrides_sufficiency_claim(self) -> None:
        value = self.decision.model_dump(by_alias=True)
        value["gaps"] = {
            "gap.missing-input": {
                "kind": "missing-input",
                "description": "A required input is absent.",
                "blocksSufficiency": True,
                "requiredEvidenceIDs": [],
            }
        }
        decision = ContextDecision.model_validate(value)
        result = ContextEngine(root=REPO_ROOT).run(
            request=self.request(), reasoner=RecordedContextProgram(decision)
        )
        self.assertEqual(result.state.sufficiency.state, "insufficient")
        self.assertIsNone(result.state.projection)
        self.assertEqual(result.state.sufficiency.blocking_gap_ids, ["gap.missing-input"])


if __name__ == "__main__":
    unittest.main()

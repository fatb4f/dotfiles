from __future__ import annotations

import json
import os
import unittest
from pathlib import Path

from context_workbook.dspy_program import RecordedContextProgram
from context_workbook.engine import ContextEngine, EngineError, build_request, load_workbook_config
from context_workbook.models import ContextDecision


REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE = Path(__file__).resolve().parent / "fixtures" / "sufficient-decision.json"


class EngineTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        os.environ["CONTEXT_WORKBOOK_TEST_MODE"] = "1"
        cls.config = load_workbook_config(REPO_ROOT)
        cls.decision = ContextDecision.model_validate_json(FIXTURE.read_text(encoding="utf-8"))

    def request(self, prompt: str = "Implement Issue 54"):
        return build_request(prompt=prompt, revision="main", config=self.config)

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

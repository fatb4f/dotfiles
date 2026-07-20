from __future__ import annotations

import unittest

from context_workbook.models import ContextRequest, SourceObservation


class ModelTests(unittest.TestCase):
    def test_request_rejects_path_escape(self) -> None:
        with self.assertRaises(ValueError):
            ContextRequest.model_validate(
                {
                    "schema": "dotfiles.context-request.v0",
                    "requestID": "request-test",
                    "prompt": "test",
                    "repository": {"repository": "fatb4f/dotfiles", "root": ".", "revision": "HEAD"},
                    "allowedPaths": ["../outside"],
                    "requestedProjectionIDs": ["agent-context-resolver"],
                }
            )

    def test_observation_rejects_nested_claimant_field(self) -> None:
        with self.assertRaises(ValueError):
            SourceObservation.model_validate(
                {
                    "kind": "tool",
                    "subject": "cue",
                    "facts": {"nested": {"passed": True}},
                    "diagnostics": [],
                    "provenance": {
                        "semanticRole": "evidence",
                        "artifactClass": "runtime_observation",
                        "claimAuthority": "none",
                    },
                }
            )


if __name__ == "__main__":
    unittest.main()

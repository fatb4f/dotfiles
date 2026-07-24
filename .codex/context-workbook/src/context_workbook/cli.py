"""Browserless adapter for the canonical Marimo reactive DAG."""

from __future__ import annotations

import argparse
import json
import os
import runpy
import sys
from pathlib import Path
from typing import Any

from .dspy_program import RecordedContextProgram
from .engine import build_request, load_workbook_config, production_reasoner_or_fail_closed


def _run_workbook(app: Any, definitions: dict[str, Any]) -> dict[str, Any]:
    _outputs, resolved = app.run(defs=definitions)
    result = resolved.get("workbook_result")
    if not isinstance(result, dict):
        raise RuntimeError("workbook did not produce workbook_result")
    return result


def _reasoner_from_args(recorded_decision: Path | None):
    if recorded_decision is None and os.environ.get("CONTEXT_WORKBOOK_RECORDED_DECISION"):
        recorded_decision = Path(os.environ["CONTEXT_WORKBOOK_RECORDED_DECISION"])
    if recorded_decision is not None:
        return RecordedContextProgram.from_path(recorded_decision)
    return production_reasoner_or_fail_closed()


def _dispatch(app: Any) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--prompt")
    parser.add_argument("--revision", default="HEAD")
    parser.add_argument("--request-file", type=Path)
    parser.add_argument("--recorded-decision", type=Path)
    parser.add_argument("--hook", action="store_true")
    parser.add_argument(
        "--output",
        choices=("all", "state", "packet", "hook", "code-intel", "trace"),
        default="all",
    )
    args, marimo_args = parser.parse_known_args()

    root = args.repo_root.resolve(strict=True)
    prompt = args.prompt
    if args.hook:
        envelope = json.load(sys.stdin)
        if envelope.get("hook_event_name") != "UserPromptSubmit":
            return 0
        prompt = envelope.get("prompt")
    if args.request_file:
        request_payload = json.loads(args.request_file.read_text(encoding="utf-8"))
    else:
        if not isinstance(prompt, str) or not prompt:
            parser.error("--prompt, --request-file, or --hook is required")
        config, snapshot = load_workbook_config(
            root,
            os.environ.get("CONTEXT_WORKBOOK_CUE", "cue"),
            revision=args.revision,
        )
        request_payload = build_request(
            prompt=prompt,
            config=config,
            snapshot=snapshot,
        ).model_dump(by_alias=True)

    reasoner = _reasoner_from_args(args.recorded_decision)
    result = _run_workbook(
        app,
        {
            "execution_mode": "browserless",
            "repo_root": str(root),
            "request_payload": request_payload,
            "context_reasoner": reasoner,
            "cue_binary": os.environ.get("CONTEXT_WORKBOOK_CUE", "cue"),
        },
    )
    if args.hook:
        if "hook" not in result:
            raise RuntimeError("agent-context-resolver projection was not requested")
        print(json.dumps(result["hook"], sort_keys=True, separators=(",", ":")))
        return 0
    requested_output = {
        "hook": ("hook", "agent-context-resolver"),
        "code-intel": ("codeIntel", "code-intel"),
    }.get(args.output)
    if requested_output is not None and requested_output[0] not in result:
        raise RuntimeError(f"{requested_output[1]} projection was not requested")
    selection = {
        "all": result,
        "state": result["state"],
        "packet": result["state"].get("projection") or {},
        "hook": result.get("hook"),
        "code-intel": result.get("codeIntel"),
        "trace": result["trace"],
    }[args.output]
    print(json.dumps(selection, sort_keys=True, indent=2))
    return 0


def run(app: Any) -> int:
    try:
        return _dispatch(app)
    except Exception as error:
        message = f"{type(error).__name__}: {error}"
        failure = {
            "schema": "dotfiles.context-graph-failure.v0",
            "requestID": "request.unknown",
            "stage": "selection",
            "code": "graph-service.failed",
            "message": message,
            "details": {},
        }
        if "--hook" in sys.argv:
            context = {
                "schema": "agent.resolver-prompt-surface.v2",
                "requestID": None,
                "sufficiency": {
                    "state": "insufficient",
                    "reasons": ["The canonical context graph service failed closed."],
                    "blockingGapIDs": ["gap.context-graph-service-failed"],
                    "unresolvedConflictIDs": [],
                },
                "context": None,
                "diagnostics": [],
                "execution": {
                    "mode": "prompt-only",
                    "routeExecution": False,
                    "sourceAuthority": False,
                    "rawTranscriptForwarding": False,
                },
            }
            print(
                json.dumps(
                    {
                        "hookSpecificOutput": {
                            "hookEventName": "UserPromptSubmit",
                            "additionalContext": json.dumps(
                                context, sort_keys=True, separators=(",", ":")
                            ),
                        }
                    },
                    sort_keys=True,
                    separators=(",", ":"),
                )
            )
            return 0
        print(json.dumps(failure, sort_keys=True), file=sys.stderr)
        return 2


def main() -> int:
    workbook = Path(__file__).parents[2] / "context-workbook.py"
    namespace = runpy.run_path(str(workbook))
    return run(namespace["app"])


if __name__ == "__main__":
    raise SystemExit(main())

"""Browserless adapter for the canonical Marimo reactive DAG."""

from __future__ import annotations

import argparse
import json
import os
import runpy
import sys
from pathlib import Path
from typing import Any

from .dspy_program import DspyUnavailable, RecordedContextProgram, production_reasoner
from .engine import build_request, fail_closed_decision, load_workbook_config
from .models import ContextDecision


class _FailClosedProgram:
    def __init__(self, message: str) -> None:
        self._decision = fail_closed_decision(message)

    def establish(self, **_: object) -> ContextDecision:
        return self._decision


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
        os.environ["CONTEXT_WORKBOOK_TEST_MODE"] = "1"
        return RecordedContextProgram.from_path(recorded_decision)
    try:
        return production_reasoner()
    except DspyUnavailable as error:
        return _FailClosedProgram(str(error))


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
        config = load_workbook_config(root)
        request_payload = build_request(
            prompt=prompt,
            revision=args.revision,
            config=config,
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
        print(json.dumps(result["hook"], sort_keys=True, separators=(",", ":")))
        return 0
    selection = {
        "all": result,
        "state": result["state"],
        "packet": result["state"].get("projection") or {},
        "hook": result["hook"],
        "code-intel": result["codeIntel"],
        "trace": result["trace"],
    }[args.output]
    print(json.dumps(selection, sort_keys=True, indent=2))
    return 0


def run(app: Any) -> int:
    try:
        return _dispatch(app)
    except Exception as error:
        print(
            json.dumps(
                {"schema": "dotfiles.context-workbook-error.v0", "error": f"{type(error).__name__}: {error}"},
                sort_keys=True,
            ),
            file=sys.stderr,
        )
        return 2


def main() -> int:
    workbook = Path(__file__).parents[2] / "context-workbook.py"
    namespace = runpy.run_path(str(workbook))
    return run(namespace["app"])


if __name__ == "__main__":
    raise SystemExit(main())

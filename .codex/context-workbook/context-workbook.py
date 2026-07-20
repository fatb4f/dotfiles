import marimo

__generated_with = "0.23.14"
app = marimo.App(width="full")


@app.cell
def _():
    import json
    from pathlib import Path

    import marimo as mo

    from context_workbook.engine import ContextEngine
    from context_workbook.models import ContextRequest

    return ContextEngine, ContextRequest, Path, json, mo


@app.cell
def _(Path):
    execution_mode = "interactive"
    repo_root = str(Path.cwd())
    request_payload = None
    context_reasoner = None
    cue_binary = "cue"
    return context_reasoner, cue_binary, execution_mode, repo_root, request_payload


@app.cell
def _(mo):
    prompt_input = mo.ui.text_area(label="Context request", rows=6)
    revision_input = mo.ui.text(label="Repository revision", value="HEAD")
    run_context = mo.ui.run_button(label="Establish context")
    mo.vstack(
        [
            mo.md("# Dotfiles context-establishment workbook"),
            mo.md(
                "The CUE root supplies the data contract; DSPy establishes context; "
                "Marimo exposes the reactive dependency graph."
            ),
            prompt_input,
            revision_input,
            run_context,
        ]
    )
    return prompt_input, revision_input, run_context


@app.cell
def _(
    ContextEngine,
    ContextRequest,
    Path,
    context_reasoner,
    cue_binary,
    execution_mode,
    prompt_input,
    repo_root,
    request_payload,
    revision_input,
    run_context,
):
    from context_workbook.engine import (
        build_request,
        load_workbook_config,
        production_reasoner_or_fail_closed,
    )

    root = Path(repo_root).resolve(strict=True)
    should_run = execution_mode == "browserless" or run_context.value
    if request_payload is None and should_run:
        config = load_workbook_config(
            root, cue_binary, revision=revision_input.value
        )
        request = build_request(
            prompt=prompt_input.value,
            revision=revision_input.value,
            config=config,
        )
    elif request_payload is not None:
        request = ContextRequest.model_validate(request_payload)
    else:
        request = None
    reasoner = context_reasoner or (
        production_reasoner_or_fail_closed() if should_run else None
    )
    engine = ContextEngine(root=root, cue_binary=cue_binary)
    return engine, reasoner, request, should_run


@app.cell
def _(engine, reasoner, request, should_run):
    if should_run and request is not None and reasoner is not None:
        engine_result = engine.run(request=request, reasoner=reasoner)
        workbook_result = {
            "schema": "dotfiles.context-workbook-result.v0",
            "state": engine_result.state.model_dump(by_alias=True, exclude_none=True),
            "trace": engine_result.trace,
        }
        if engine_result.hook_projection is not None:
            workbook_result["hook"] = engine_result.hook_projection
        if engine_result.code_intel_projection is not None:
            workbook_result["codeIntel"] = engine_result.code_intel_projection
    else:
        workbook_result = {
            "schema": "dotfiles.context-workbook-result.v0",
            "state": None,
            "trace": {},
            "hook": None,
            "codeIntel": None,
        }
    return (workbook_result,)


@app.cell
def _(mo, workbook_result):
    mo.vstack(
        [
            mo.md("## Reactive context state"),
            mo.json(workbook_result),
        ]
    )
    return


if __name__ == "__main__":
    app.run()

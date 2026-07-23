from __future__ import annotations

from datetime import datetime
import json
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StrictInt, StrictStr

NonEmpty = Annotated[StrictStr, Field(min_length=1)]
StringList = Annotated[list[NonEmpty], Field(max_length=256)]


class ContractModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=lambda value: value.split("_")[0]
        + "".join(part.title() for part in value.split("_")[1:]),
        populate_by_name=False,
        extra="forbid",
        strict=True,
    )


class Repository(ContractModel):
    root: NonEmpty
    revision: Annotated[StrictStr, Field(pattern=r"^[0-9a-f]{40}([0-9a-f]{24})?$")]
    branch: NonEmpty | None
    dirty_paths: StringList
    staged_paths: StringList


class Validation(ContractModel):
    passing: StringList
    failing: StringList
    not_run: StringList


class Handoff(ContractModel):
    schema_: Literal["codex.handoff.v0"] = Field(alias="schema")
    created_at: datetime
    objective: NonEmpty
    invariants: StringList
    decisions: StringList
    repository: Repository
    validation: Validation
    current_operation: NonEmpty
    next_operation: NonEmpty
    completion_criteria: Annotated[list[NonEmpty], Field(min_length=1, max_length=256)]
    evidence_pointers: StringList
    open_questions: StringList


class CommandResult(ContractModel):
    schema_: Literal["codex.command-result.v0"] = Field(alias="schema")
    exit_code: StrictInt
    signal: StrictInt | None
    truncated: bool
    relevant_lines: Annotated[list[StrictStr], Field(max_length=20)]
    artifact: NonEmpty
    sha256: Annotated[StrictStr, Field(pattern=r"^[0-9a-f]{64}$")]


class CommandManifest(ContractModel):
    schema_: Literal["codex.command-artifact.v0"] = Field(alias="schema")
    argv: Annotated[list[NonEmpty], Field(min_length=1, max_length=4096)]
    working_directory: NonEmpty
    started_at: datetime
    duration_seconds: float
    exit_code: StrictInt
    signal: StrictInt | None
    stdout_bytes: StrictInt
    stderr_bytes: StrictInt
    stdout_sha256: Annotated[StrictStr, Field(pattern=r"^[0-9a-f]{64}$")]
    stderr_sha256: Annotated[StrictStr, Field(pattern=r"^[0-9a-f]{64}$")]


def canonical_bytes(model: BaseModel) -> bytes:
    value = model.model_dump(mode="json", by_alias=True, exclude_none=False)
    return (json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n").encode()

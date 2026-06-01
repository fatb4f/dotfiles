# CUE Flow as a Codex Skill Router

## Executive summary

CUE is a **good fit for the policy, schema, routing, planning, and evidence-normalization layer** of a local Codex skill system, but it is only a **qualified fit** for the full orchestration substrate if you separate the problem into two layers. The strongest MVP shape is: **Codex discovers a small number of broad skills via `SKILL.md`; a plain CUE router owns typed objectives, capability matching, unison validation, candidate scoring, and plan generation; and only the selected leaf flow executes through `_tool.cue` commands using `tool/exec` as an adapter.** That design matches both Codex’s discovery model and CUE’s split between hermetic configuration and non-hermetic tooling. citeturn3view4turn6view0turn12view0turn12view1

The best architecture is therefore **a hybrid of a central CUE router and nested candidate-node registry**, with **leaf execution flows kept separate**. In other words: use Pattern 6 seriously, but implement it as a **main plain-CUE router entrypoint with nested node definitions**, not as a single giant executable `_tool.cue` task tree. Pattern 4 is also valuable as a **build-time support pattern**: generate or project `SKILL.md` files from CUE metadata so Codex discovery stays in sync with CUE routing policy. citeturn3view4turn12view1turn33search17

For the MVP, **`cue cmd` is enough** when your leaf flows are relatively flat, use standard `tool/*` tasks, and normalize evidence by parsing adapter-emitted JSON inside the workflow with `encoding/json.Unmarshal` or `encoding/json.Validate`. A **Go `cuelang.org/go/tools/flow` runner becomes worth it later** if you need custom task types, richer introspection, access to the final in-memory workflow value via `Controller.Value()`, hidden-task discovery, long-running services, or tighter control over failure and scheduling. citeturn12view0turn18view1turn36view0turn37view0turn14view0turn13view0

**Final verdict:** **adopt with constraints.** Use CUE as the authority for objective typing, routing, unison validation, plan generation, and evidence schemas; use `_tool.cue` only for selected executable leaves; and defer a custom Go `tools/flow` runner until concrete MVP pressure justifies it. citeturn6view0turn12view0turn19view0turn20view0

## What the substrate actually provides

### Codex discovery is broad, `SKILL.md`-first, and budget-constrained

OpenAI’s Codex documentation says skills are installed as directories containing a **required `SKILL.md`**, scanned under configured skill directories, and implicitly invoked based on the skill **`name` and `description`**. Codex first loads a **small initial list** of candidate skills whose total description budget is capped, and only loads the full `SKILL.md` for skills chosen from that initial shortlist. The docs also note that if descriptions are too long or too many skills are installed, some skills may be omitted from that first pass. That makes “one tiny Codex skill per executable flow” a discovery anti-pattern for your use case; it strongly favors a **smaller number of broader skills** that delegate detailed routing to CUE internally. citeturn3view4

That discovery boundary matters more than it first appears. Because Codex chooses skills from short descriptions before it sees the full instructions, your system should treat `SKILL.md` as a **coarse discovery surface**, not as the place where all fine-grained routing logic lives. CUE is well suited to become the second-stage router after Codex picks a broad skill family. citeturn3view4

### CUE already enforces a useful separation between hermetic routing data and non-hermetic execution

The `tool` package documentation states that tool definitions are visible **only in files ending in `_tool.cue` or `_tool_test.cue`**, and explicitly explains that regular CUE configuration remains **hermetic**, while tools are the mechanism for letting “outside influences” affect evaluation and for making configuration actionable. That built-in separation is almost exactly what your MVP wants: a **plain CUE router** that stays schema- and policy-centric, and a **small execution layer** where external effects are allowed. citeturn6view0

CUE workflow commands are defined in `_tool.cue` files under a top-level `command` field. The CLI docs say each command contains one or more tasks; tasks can depend on one another through references; `cue cmd` performs a **static dependency analysis**, starts only tasks that are fully specified, then reevaluates the instance after each completed task until the workflow finishes. That means CUE already gives you a declarative dependency engine for leaf execution flows. citeturn12view0turn12view1

The same docs also expose an important caveat: task discovery happens through **regular fields under `command`**, and **hidden fields and definitions are excluded** from that discovery. That is very useful for a router design, because it means you can safely keep a nested registry in **definitions and hidden fields** without accidentally turning the router’s metadata into executable tasks. It is also a warning sign against putting a dynamic nested executable registry under one giant `command` tree. citeturn12view1turn33search17

### `tool/exec` is viable as a shell adapter, but it should stay an adapter

`tool/exec.Run` is designed to execute a program with arguments, optionally in a specific directory, with an explicit environment, and with captured `stdout`, `stderr`, and `success` status. Its docs recommend list-form commands when arguments contain spaces, and note that string-form commands are merely split on whitespace; there is **no implicit shell language** beyond what you explicitly invoke. That matches your hard constraint well: shell can exist, but only as an explicit adapter behind `tool/exec`. citeturn18view1turn18view4turn18view3

Evidence normalization is also more feasible with `cue cmd` than it first appears. CUE’s workflow examples show that data fetched by a task can be converted inside the workflow using `encoding/json.Unmarshal`, and official docs show that `encoding/json.Validate` can enforce that JSON strings satisfy a schema. In practice, that means your shell adapters should prefer emitting **JSON** to stdout; then the selected `_tool.cue` leaf can capture that output as bytes, unmarshal it into CUE data, unify it with a declared evidence schema, and print or persist normalized JSON as the observation. citeturn37view0turn36view0turn36view1

### `tools/flow` is lower-level, more powerful, and not the best MVP default

The Go `cuelang.org/go/tools/flow` package describes itself as a **low-level workflow manager** over a CUE instance. It requires the caller to provide a `TaskFunc` that decides which CUE values are tasks and which `Runner` should execute them. The package exposes a `Controller`, `Run`, task graph accessors, and—crucially for typed observations—a `Controller.Value()` method that returns the managed value after the run completes. Its config surface also includes `Root`, `InferTasks`, `FindHiddenTasks`, `UpdateFunc`, and `RunInferredTasks`, and recent versions add a `Service` interface for long-running runtime dependencies. citeturn19view0turn14view0turn13view0turn5view4

That API is a strong escape hatch, but it is not a cheap one. You own task recognition, runner behavior, integration code, and part of the operational semantics. The docs also note that `Stats()` on the controller is experimental, and the package remains pre-v1 on pkg.go.dev. For an MVP with no MCP, hooks, or broader runtime ambitions, that is usually more substrate than you need on day one. citeturn13view0turn19view0turn11view0

## Architecture comparison

**Pattern 1: per-skill command or workflow files** is viable when the unit of discovery, routing, and execution truly is one-to-one. For your case, it is not the best default. Codex discovery is `SKILL.md`-based and initial skill loading is budget-constrained, so proliferating many narrow Codex skills increases the chance that the right one is not considered early. On the CUE side, the current `cue cmd` model also couples workflow declaration to package loading in ways the CUE project itself describes as constraining. citeturn3view4turn22view1turn20view0

**Pattern 2: a central router with thin skill leaves** is the strongest pure-MVP option. It aligns with Codex’s need for a smaller set of broad discovery entries, lets CUE own all typed routing policy in one place, and keeps `_tool.cue` work focused on execution rather than decision-making. Because the `tool` layer is restricted to `_tool.cue`, this structure also cleanly preserves hermetic routing logic outside the execution layer. citeturn3view4turn6view0

**Pattern 3: a hybrid with central command or router logic and per-skill leaf workflows** is better than Pattern 2 if different leaves genuinely need different task graphs or adapters. CUE’s own docs and analysis point toward keeping workflows and reusable abstractions layered on top of task primitives, while also acknowledging that all-in-one command overlays are awkward today. In practice, that means: centralize routing and type contracts, but let leaf flows own the steps that actually run. citeturn22view1turn20view0

**Pattern 4: generated Codex skill projections from CUE** is not the runtime architecture, but it is a very good support pattern. Because Codex discovery stays `SKILL.md`-based, generating `SKILL.md` descriptions from the same CUE metadata that drives the router keeps discovery text, declared capabilities, and execution references synchronized. That reduces drift and lets you choose Codex skill granularity for discovery reasons without duplicating the source of truth. citeturn3view4

**Pattern 5: a Go `tools/flow` runner** is meaningfully more powerful than `cue cmd`, but it should be treated as an escalation path, not as the MVP default. It becomes attractive when you need your own task recognition, access to the final unified value, hidden-task discovery, update callbacks, runtime services, or richer diagnostics than `cue cmd` provides. Until those needs are concrete, a custom runner adds code and operational surface area faster than it adds MVP value. citeturn14view0turn13view0turn39view0

**Pattern 6: a main CUE router entrypoint with nested candidate nodes** deserves a serious yes—but only in a specific form. It is an excellent idea if the nested nodes are **plain CUE definitions or hidden fields** used for matching, unison validation, scoring, and plan generation. It is a poor MVP idea if those nested nodes are all turned into a dynamic executable graph inside one `_tool.cue` command, because `cue cmd` task discovery depends on regular fields, excludes hidden fields and definitions, does not support tasks in lists, and has had edge cases around nested tasks with incomplete identifiers. citeturn12view1turn21view9turn9view0

Taken together, the best answer is not one candidate in isolation. It is **Pattern 6 as the router core, Pattern 3 for execution layout, and Pattern 4 as a support mechanism**. Pattern 5 should remain optional until you have proven need. citeturn3view4turn12view1turn20view0turn19view0

## Recommended architecture

The recommended architecture is:

```text
Codex SKILL.md discovery
→ broad skill selected by name/description
→ plain CUE router entrypoint
→ nested node registry
→ capability matching
→ unison validation
→ candidate scoring and selection
→ plan output
→ selected leaf flow execution
→ normalized evidence
```

That first half should be **plain CUE**, evaluated with `cue export` or the CUE API, not `cue cmd`. `cue export` evaluates configuration and emits concrete data, while `cue cmd` is specifically the side-effecting workflow executor. That makes plan-only mode straightforward: planning is just exporting the router’s `plan` expression; execution only happens in a second phase after a concrete flow has been selected. citeturn32search0turn32search3turn12view0

The nested node registry should live as **definitions and hidden intermediates** in the router package. Definitions are validation-oriented and are not emitted as data; hidden fields are excluded from task discovery in workflow commands. That gives you a strong way to keep the node catalog and candidate calculations inside CUE without accidentally making them executable. It also means Pattern 6 can be implemented safely without building a monolithic `_tool.cue` flow engine. citeturn33search17turn12view1

Executable flows should live as **leaf commands**, each one representing a concrete capability implementation or adapter pipeline. A leaf should be selected by reference from the router, not synthesized dynamically as a new task tree. This avoids the rough edges the CUE project has documented around nested task discovery, awkward package overlays, and large command structures. citeturn9view0turn22view1turn20view0

For node declarations, the most robust MVP schema is a **struct-keyed registry**, not a list. The CUE project’s `cue cmd` analysis explicitly notes that tasks cannot be declared in lists today and that lists of tasks can hurt composability. Even though your router registry is data rather than tasks, the same lesson applies: use stable field names for nodes, because they are easier to reference, override, and score deterministically. citeturn21view9turn21view6

A node should declare at least these categories of information: **objective support**, **capabilities**, **requirements**, **priority**, **execution reference**, and **evidence schema**. The objective and requirement portions should be unified with the concrete request, and the evidence schema should be the contract the leaf flow must satisfy. Tagged inputs for leaves should stay in normal top-level fields, because CUE’s injection system only works on fields marked with `@tag` that are not inside comprehensions, lists, or optional fields. citeturn12view2

For **multi-node unison**, the cleanest MVP model is “one primary executor, zero or more auxiliary validators or enrichers.” CUE’s unification model is ideal here: unification recursively checks for conflicts; `and()` can unify a list of constraints; and `matchN` can enforce “exactly one,” “at least one,” or “all of” style invariants. In practical terms, let the router unify the selected nodes’ requirements and evidence contracts before any execution begins, then require exactly one primary execution node after scoring and allow compatible auxiliary nodes only if they do not create conflicts. citeturn31view0turn31view2turn31view1

The right moment to add **Go `tools/flow`** is when your MVP stops being satisfied by that two-phase model. Specifically, move when you need the final unified workflow value as the canonical output, when you need runtime graph introspection through `Tasks()` and `UpdateFunc`, when hidden-task discovery matters, or when long-running services become first-class. Until then, `cue cmd` leaves plus JSON-emitting adapters are enough. citeturn14view0turn13view0turn5view4turn39view0

## Minimal implementation sketch

A minimal repository layout should separate discovery, routing, and leaf execution cleanly:

```text
.agents/
  skills/
    repo-router/
      SKILL.md              # broad Codex discovery entry; may be generated
cue/
  router/
    main.cue               # plain CUE router, no tool imports
    objective.cue          # typed objective and requirement schemas
    evidence.cue           # normalized evidence schemas
  flows/
    search_rg_tool.cue     # selected leaf workflow
    lint_eslint_tool.cue   # selected leaf workflow
```

This layout intentionally does **not** assume one `_tool.cue` or one workflow file per Codex skill. Codex skill count should be driven by discovery ergonomics, while `_tool.cue` leaf count should be driven by execution-graph differences. Those are different optimization problems. citeturn3view4turn6view0

### Router example

The point of the router example is to keep the node catalog in definitions and hidden fields, so the only exported public value is the concrete plan. That mirrors the way CUE treats definitions as validation-only values and the way `cue cmd` excludes definitions and hidden fields from task discovery. The example also uses a struct-keyed registry and list functions such as `list.Contains` and `list.Max`, which are available in CUE’s standard packages. citeturn33search17turn12view1turn34view1turn34view0

```cue
package router

import "list"

#ObjectiveKind: "search" | "lint" | "refactor"

#Objective: {
	kind:         #ObjectiveKind
	planOnly:     bool | *true
	shellAllowed: bool | *false
	cwd:          string | *"."
}

#EvidenceShape: {
	kind: string
	data: _
}

#Node: {
	id:         string
	priority:   int
	objectives: [...#ObjectiveKind]
	requires: {
		shell: bool | *false
	}
	flow: string
	outputs: [string]: #EvidenceShape
	role: "primary" | "aux"
}

objective: #Objective

#registry: {
	rg: #Node & {
		id:         "rg"
		priority:   90
		objectives: ["search"]
		requires: { shell: true }
		flow: "rgSearch"
		role: "primary"
		outputs: result: {
			kind: "search.lines"
			data: [...{
				path: string
				line: int
				text: string
			}]
		}
	}

	eslint: #Node & {
		id:         "eslint"
		priority:   80
		objectives: ["lint"]
		requires: { shell: true }
		flow: "eslintLint"
		role: "primary"
		outputs: result: {
			kind: "lint.report"
			data: _
		}
	}
}

_candidates: {
	for name, n in #registry
	if list.Contains(n.objectives, objective.kind) &&
		(!n.requires.shell || objective.shellAllowed) {
		"\(name)": n
	}
}

_candidatePriorities: [for _, n in _candidates { n.priority }]
_maxPriority: list.Max(_candidatePriorities)

_selected: {
	for name, n in _candidates
	if n.priority == _maxPriority {
		"\(name)": n
	}
}

plan: {
	objective:  objective
	candidates: _candidates
	selected:   _selected
	execute:    !objective.planOnly
}
```

### Leaf flow example

The leaf example keeps shell usage confined to `tool/exec`, captures adapter output as bytes, unmarshals the result into a CUE value with `encoding/json.Unmarshal`, unifies it with a declared evidence schema, and prints normalized JSON using `tool/cli.Print`. That is the key MVP move: **make adapters emit JSON**, then let CUE validate and shape the observation. Official CUE docs show exactly this style of JSON conversion inside workflow commands. citeturn18view1turn18view3turn37view0turn36view1turn38search0

```cue
package flows

import (
	"encoding/json"
	"tool/cli"
	"tool/exec"
)

query: string @tag(query)
cwd:   string | *"." @tag(cwd)

#Evidence: {
	kind: "search.lines"
	data: [...{
		path: string
		line: int
		text: string
	}]
}

command: rgSearch: {
	run: exec.Run & {
		// Shell is an explicit adapter, not the router.
		cmd: ["sh", "-c", "skill-rg-adapter --query \"$QUERY\" --cwd \"$CWD\""]
		env: {
			QUERY: query
			CWD:   cwd
		}
		dir:    cwd
		stdout: bytes
		stderr: string
	}

	evidence: #Evidence & json.Unmarshal(run.stdout)

	emit: cli.Print & {
		text: json.Marshal({
			flow:     "rgSearch"
			success:  run.success
			evidence: evidence
			stderr:   run.stderr
		})
	}
}
```

In use, the plan-only phase would export the router plan, and the apply phase would run the selected leaf command. Because `cue cmd` is the side-effecting executor and `cue export` is the pure data evaluator, that split gives you the required plan-only mode without inventing an extra runtime. citeturn32search0turn32search3turn12view0

## Risk register

**Discovery fragmentation risk.** If you map every micro-flow to its own Codex skill, Codex may omit some skills from the initial shortlist because the initial skill list is description-budget-limited. The mitigation is to keep **few, broad `SKILL.md` entries** and let CUE do the fine-grained routing. citeturn3view4

**`cue cmd` package and overlay coupling.** The CUE project’s own `cue cmd` analysis says the current model—where workflows are declared in `_tool.cue` in the same package as their instance inputs—creates awkward package and overlay behavior, and constrains reuse. The mitigation is to make the MVP router and leaf flows rely primarily on **tagged inputs, file inputs, and adapter outputs**, rather than on deep overlaying of arbitrary target CUE packages. citeturn22view1turn20view0

**Task-discovery edge cases.** `cue help commands` says tasks are discovered from regular fields under `command`, excluding hidden fields and definitions, and official issues show problems around hidden-field tasks and nested tasks with incomplete identifiers. The mitigation is to keep the router’s registry as **definitions or hidden fields**, keep executable leaves flat and concrete, and avoid dynamically generating executable task names in a monolithic main command. citeturn12view1turn28view0turn9view0

**Control-flow and failure-model gaps.** The `cue cmd v2` analysis documents open questions around failure semantics, retries, timeouts, dependency readiness, and limiting parallelism. That does not block a small MVP, but it is a reason to keep early execution flows narrow and deterministic rather than building a large orchestrator in `_tool.cue`. citeturn22view0turn21view1

**Input and error UX roughness.** CUE injection is restricted to tagged fields outside comprehensions, lists, and optional fields, and the project’s analysis and issue tracker note rough error messages around workflow input validation. The mitigation is to validate objectives in the plain CUE planning layer first, so missing or malformed inputs fail before execution starts. citeturn12view2turn22view1turn10search1

**Pre-v1 and ecosystem-maturity risk.** CUE’s proposal repository explicitly says CUE has not reached v1 and does not yet have a compatibility guarantee. pkg.go.dev also marks `tools/flow` as not at a stable v1 version, and public pkg.go.dev data shows a modest 27 known importers for `tools/flow`. Combined with active `cue cmd v2` analysis and multiple open “Needs planning” issues around workflow behavior, that suggests a capable but not yet fully battle-hardened orchestration substrate. The mitigation is to keep the MVP architecture conservative and to avoid overcommitting to custom runner code too early. citeturn11view0turn19view0turn20view0turn27search3

**Documentation drift risk.** The workflow-command docs still mention setting `CUE_EXPERIMENT=cmdreferencepkg` to avoid older task-discovery behavior, while the experiments reference and the v0.16.0 release notes state that `cmdreferencepkg` became stable and always enabled in v0.16.0. That inconsistency is small, but it is a concrete sign that workflow-related documentation and behavior have had rough edges. citeturn12view1turn16view0turn17view0

**Debuggability risk.** CUE does offer a `CUE_DEBUG=toolsflow` flag that prints Mermaid task dependency graphs in `cue cmd`, but the project’s own analysis describes this as a primitive visualization. For MVP use that is helpful, not comprehensive. The mitigation is to keep flows small, preserve plan output as a first-class artifact, and move to a Go runner only if richer graph introspection becomes necessary. citeturn39view0turn21view4

## Final verdict

**Adopt with constraints.** CUE is suitable as the orchestration substrate for a **local Codex skill MVP** if you use it as a **typed router and planner first**, and only secondarily as a **leaf workflow executor**. The winning shape is a **central plain-CUE router with a nested node registry**, plus **thin executable `_tool.cue` leaves** that use `tool/exec` as an explicit shell adapter and normalize observations into declared evidence schemas, ideally by consuming JSON. That design respects Codex’s `SKILL.md` discovery boundary, preserves CUE as the policy authority, supports plan-only mode cleanly, and avoids the roughest `cue cmd` workflow traps. citeturn3view4turn6view0turn12view0turn37view0

You should **defer a Go `tools/flow` runner** until one of three things becomes true: you need custom task kinds or long-running services; you need the final unified CUE value as the authoritative result; or you need runtime graph introspection and control that `cue cmd` plus `CUE_DEBUG=toolsflow` cannot provide. Until then, the most defensible MVP is: **broad Codex discovery, central CUE routing, leaf `_tool.cue` execution, JSON-shaped evidence, and no monolithic executable router flow.** citeturn19view0turn13view0turn39view0turn20view0
# Report — Green-Light + Validated + Manifested Evidence Review

## Scope note

I found supporting source artifacts for the **control-plane / evidence / promotion / packet** model. I did **not** find an exact current AgentNode repo/source checkout in the accessible sources, so AgentNode-specific claims remain **conversation-context / inferred** unless backed by the cited artifacts below.

---

## Tier model

|                              Tier | Meaning                                                                | Trust level   |
| --------------------------------: | ---------------------------------------------------------------------- | ------------- |
|           **T0 — Root authority** | Contract/admission/policy boundary is explicit                         | Highest       |
| **T1 — Deterministic validation** | Machine-checkable gates, schemas, CUE, jq, validation reports          | High          |
|      **T2 — Manifested evidence** | Artifacts, manifests, hashes, packet metadata, required evidence refs  | High-medium   |
|        **T3 — Review/projection** | Human review packet, quick-review matrix, narrative report             | Medium        |
|            **T4 — Shortcut/debt** | Ambiguity, compressed slices, pending implementation, inferred closure | Risk register |

---

## Quick-review matrix

| Domain                    | Evidence extracted                                                                                                                                       |  Tier | Status                       | Shortcut / risk                                                                                  |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----: | ---------------------------- | ------------------------------------------------------------------------------------------------ |
| **Authority boundary**    | Authority is narrowed to contracts and legality; projections, adapters, runtimes, notebooks, hooks, MCP remain subordinate.                              |    T0 | **Green**                    | Good contract shape, but actual enforcement surface must stay explicit.                          |
| **Control-theory model**  | Policy intent → structural contracts → validation/reconciliation → control actions. Plant/state/observer/controller/actuator split is defined.           | T0/T1 | **Green**                    | Still needs concrete controller behavior per mismatch class.                                     |
| **Workflow order**        | Required order: capture repo facts → enrich diff → reconcile plan → run validation → assemble review packet → assemble evidence bundle → narrative last. |    T1 | **Green**                    | Risk if narrative/report is treated as proof instead of projection.                              |
| **Artifact model**        | `repo_state`, `diff_state`, `packet_plan`, `packet_run`, `workflow_state`, `validation_report`, `review_packet`, `evidence_bundle` are separated.        | T1/T2 | **Green**                    | Evidence bundle promotion criteria remain partly open.                                           |
| **Promotion model**       | Promotion plan requires validation refs and post-promotion gates: `main_authority_gate`, `main_contract_package_gate`, `main_artifact_conformance_gate`. |    T2 | **Green-lighted**            | Green-light is gated, not equivalent to full engine completion.                                  |
| **Implementation packet** | Scope lock, artifact paths, deliverables, evidence-required table, gate list, results, rollback, closeout state exist.                                   |    T2 | **Validated but not closed** | `Evidence gate status: PENDING`; full bounded-batch closeout needs more execution-side evidence. |
| **Runtime / flow engine** | Source model clearly distinguishes deterministic lane from exploratory/runtime lane.                                                                     | T1/T4 | **Not complete**             | Actual flow engine implementation is outside current proof unless separately present.            |
| **Shortcut inventory**    | Compressed slices, ambiguity, validation stubs, pending bridge validation, open evidence criteria.                                                       |    T4 | **Known debt**               | Acceptable for green-light; must be surfaced before hardening.                                   |

---

## Evidence inventory by domain

### 1. Authority / admissibility

**Extracted evidence**

* The consolidated proposal states that normative authority is intentionally narrow: **contracts and legality** decide valid boundary objects, admissibility, composition, and policy legality.
* Projection, generated config, drift checks, parity checks, adapters, runtimes, notebooks, hook executors, and MCP surfaces are explicitly downstream/subordinate.
* This supports the current “green-light” claim at the architectural-contract level. 

**Classification**

| Domain              |  Tier | Finding |
| ------------------- | ----: | ------- |
| Authority boundary  |    T0 | Strong  |
| Adapter containment | T0/T1 | Strong  |
| Projection role     |    T1 | Strong  |

**Shortcut exposed**

The authority model is proven as a **declared design contract**. It does not by itself prove that every runtime path enforces the contract.

---

### 2. Control model / validation semantics

**Extracted evidence**

The policy framework defines a four-layer stack:

1. policy intent
2. structural contracts
3. validation and reconciliation
4. control actions: `ALLOW`, `REPAIR`, `RETRY`, `DENY`, `QUARANTINE`, `PROMOTE`

It also maps the system as: plant = runtime, state = manifests/artifacts/handoff history, observer = validators/jq/event collectors, controller = policy engine, actuators = runner/repair/dispatch/handoff. 

**Classification**

| Domain                    | Tier | Finding                               |
| ------------------------- | ---: | ------------------------------------- |
| Policy stack              |   T0 | Strong                                |
| Validation/reconciliation |   T1 | Strong                                |
| Control action vocabulary |   T1 | Present but not fully operationalized |

**Shortcut exposed**

Mismatch handling exists as a vocabulary, but not all actions have proven implementation semantics.

---

### 3. Workflow order / evidence-before-narrative

**Extracted evidence**

The workflow model requires deterministic order:

> capture repo facts → enrich diff → reconcile plan → run validation → assemble review packet → assemble evidence bundle → narrative last

The same source explicitly separates desired workflow intent from observed execution state and keeps `packet_run` subordinate to `packet_plan`. 

**Classification**

| Domain                         |  Tier | Finding |
| ------------------------------ | ----: | ------- |
| Workflow order                 |    T1 | Strong  |
| Desired vs observed separation | T1/T2 | Strong  |
| Narrative-last rule            |    T1 | Strong  |

**Shortcut exposed**

Current “validated” status must not be inferred from narrative summaries. It needs attached validation/report artifacts.

---

### 4. Artifact / evidence model

**Extracted evidence**

The artifact model separates:

* `repo_state`
* `diff_state`
* `packet_plan`
* `packet_run`
* `workflow_state`
* `validation_report`
* `review_packet`
* `evidence_bundle`

The source explicitly says this prevents a free-form summary from standing in for repo status, changed files, validation, workflow progress, and human review all at once. 

**Classification**

| Domain               | Tier | Finding |
| -------------------- | ---: | ------- |
| Artifact taxonomy    |   T1 | Strong  |
| Evidence bundle role |   T2 | Present |
| Review packet role   |   T3 | Present |

**Shortcut exposed**

The model is correct, but the **exact promotion criteria for evidence bundles** remain a known unresolved area in the consolidated proposal. 

---

### 5. Promotion / manifested gate evidence

**Extracted evidence**

The promotion plan is concrete and declares:

* `promotion_mode`: `patch_promotion`
* target branch: `main`
* required evidence refs:

  * request validation
  * contract bindings validation
  * batch validation
  * integration gate validation
  * promotion validation
  * surface inputs
  * deliverable dependency DAG
  * implement response validation
* post-promotion gates:

  * `main_authority_gate`
  * `main_contract_package_gate`
  * `main_artifact_conformance_gate`
* rollback mode: retain integration worktree and reject promotion. 

**Classification**

| Domain                      |  Tier | Finding |
| --------------------------- | ----: | ------- |
| Required evidence refs      |    T2 | Strong  |
| Post-promotion replay gates | T1/T2 | Strong  |
| Rollback boundary           |    T2 | Present |

**Shortcut exposed**

This proves the **promotion contract** is manifested. It does not prove every referenced evidence artifact is current, complete, or produced by the final runtime.

---

### 6. Implementation packet / closeout evidence

**Extracted evidence**

The implementation packet contains:

* artifact paths
* execution context
* scope lock
* issue map
* work queue
* evidence-required table
* gates
* execution commands
* results
* rollback
* closeout decision

It marks D1 and D2 evidence as met, but D3 remains pending: response contract validity and loop bridge validity. It also marks the evidence gate as `PENDING`, and the closeout decision as `NEEDS_INFO`. 

**Classification**

| Domain            | Tier | Finding      |
| ----------------- | ---: | ------------ |
| Manifested packet |   T2 | Strong       |
| Evidence table    |   T2 | Mixed        |
| Closeout          |   T4 | Not complete |

**Shortcut exposed**

This is the clearest “green-light shortcut” area: the packet is **valid enough to proceed**, but not fully closed. The proof surface itself admits pending bridge/evidence work.

---

## Shortcut / ambiguity register

| ID | Shortcut taken                                     | Why acceptable for green-light                   | Why not acceptable for hardening                                |
| -- | -------------------------------------------------- | ------------------------------------------------ | --------------------------------------------------------------- |
| S1 | Compressed slices                                  | Faster route to observable green state           | May hide implicit assumptions between slices                    |
| S2 | Contract proof before engine proof                 | Correct if objective is architecture green-light | Not sufficient for production flow runtime                      |
| S3 | Validation stubs / partial validation              | Allows manifest shape and gate wiring to land    | Must be replaced by real validation execution                   |
| S4 | Evidence bundle criteria still open                | Acceptable if surfaced as open question          | Promotion cannot become automatic until criteria are closed     |
| S5 | Narrative report used as review aid                | Useful for operator compression                  | Cannot become source of truth                                   |
| S6 | AgentNode-specific source not directly parsed here | Best-effort from available artifacts             | Needs repo/source checkout or exact patch source for hard proof |
| S7 | D3 pending in implementation packet                | Explicitly declared; no hidden failure           | Blocks full closeout                                            |

---

## Bottom-line classification

| Claim                        | Status                                                                                     |
| ---------------------------- | ------------------------------------------------------------------------------------------ |
| **Green-light reached**      | Yes, at contract / architecture / promotion-shape level.                                   |
| **Validated**                | Partially. Validation surfaces and required refs exist, but some evidence remains pending. |
| **Manifested**               | Yes. Promotion plan and implementation packet are concrete manifested artifacts.           |
| **Flow engine complete**     | Not proven. Treat as out-of-scope or pending.                                              |
| **Ready for hardening pass** | Yes. The next pass should target shortcuts, ambiguity, and missing evidence.               |

---

## Recommended next report artifact

Create:

```text
docs/reports/green-light-evidence-review.md
```

Minimum sections:

```text
# Green-Light Evidence Review

## 1. Scope
## 2. Source Inventory
## 3. Tier Model
## 4. Quick-Review Matrix
## 5. Evidence Extracts by Domain
## 6. Manifested Artifacts
## 7. Validation Status
## 8. Shortcut / Ambiguity Register
## 9. Hardening Queue
## 10. Final Gate Readiness
```

## Hardening queue

1. **Close D3 evidence**

   * response contract validity
   * loop bridge validity
   * bridge validator output

2. **Materialize evidence bundle criteria**

   * define required files
   * define admissibility rules
   * define promotion blockers

3. **Separate green-light from production-complete**

   * `green_light: true`
   * `validated: partial|full`
   * `manifested: true`
   * `engine_complete: false|unknown|true`

4. **Add a shortcut register as a first-class artifact**

   * do not bury shortcuts in prose
   * emit JSON/NDJSON alongside markdown

5. **Add a quick-review matrix projection**

   * markdown for humans
   * JSON for controller / future agent use

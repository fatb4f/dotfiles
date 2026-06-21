---
name: Closed-loop implementation
about: Frame implementation as input -> transform -> output -> eval/sensor -> error signal -> control action -> next state
title: "<type>(<surface>): <objective>"
labels: ""
assignees: ""
---

# Closed-loop implementation packet

## Objective

```text
<one sentence describing the intended state transition>
```

## Current state

```text
<what is true now>
```

## Target next state

```text
<what must be true after this issue is implemented>
```

## Non-goals

```text
<what must not be changed, generalized, or pulled into scope>
```

---

# Authority boundary

```text
This issue may modify dotfiles desired state only through bounded source surfaces.

chezmoi source files are desired-state authority.
WezTerm Lua modules are runtime/workspace projection surfaces.
Generated/session output is observed evidence, not authority.

Workers may produce evidence.
Assertions decide admissibility.
Feedback decides admit/revise/reject.
Transitions bind semantic/runtime/material state.
Materialization requires an admitted transition.
Observed state feeds the next loop.
```

Default non-goals:

```text
- do not introduce raw repo firehose acquisition
- do not treat generated/session output as authority
- do not bypass validation or sensor evidence
- do not materialize before evaluation passes
- do not broaden bounded workspace work into unrelated dotfiles refactor
```

---

# 1. Input

Authoritative inputs available to the implementation agent.

```text
issues:
  - #<n>

files:
  - <path>
  - <path>

contracts:
  - <schema / invariant / gate>

commands:
  - <validation command>
```

Constraints:

```text
- <constraint>
- <constraint>
```

---

# 2. Transform

Allowed implementation operations.

```text
allowed:
  - <edit / move / generate / validate / document>

forbidden:
  - <raw acquisition / broad refactor / unrelated cleanup / authority leak>
```

Expected transition shape:

```text
input
  -> transform
  -> output
```

---

# 3. Output

Expected material output.

```text
files changed:
  - <path>
  - <path>

artifacts generated:
  - <path>

docs updated:
  - <path>
```

The output must not be considered complete unless it is backed by evaluation evidence.

---

# 4. Eval / sensor

Validation commands:

```bash
<command>
<command>
```

Required observations:

```text
- <observable condition>
- <observable condition>
```

Sensor evidence to report back:

```text
validation:
  - command: <command>
    result: pass|fail
    evidence: <short summary>

repo state:
  - <observed state>
```

---

# 5. Error signal

Known failure modes this issue must detect.

```text
error signals:
  - <failure mode>
  - <failure mode>
  - <failure mode>
```

If any error signal is observed:

```text
decision:
  - reject transition
  - preserve current state
  - report blocker
```

---

# 6. Control action

Decision rule.

```text
admit if:
  - all required validation passes
  - target next state is observed
  - no forbidden surface was introduced
  - no unresolved error signal remains

revise if:
  - implementation is structurally close but validation/evidence is incomplete

reject if:
  - authority boundary is violated
  - unrelated scope is introduced
  - validation fails
```

Admitted action:

```text
<commit / PR / issue update / generated artifact / migration step>
```

---

# 7. Next state

After implementation, the repository must be in this state:

```text
<final next-state contract>
```

Follow-up routing:

```text
if complete:
  - close this issue

if incomplete:
  - leave open with observed error signal

if new scope discovered:
  - create separate issue
```

---

# Evidence report format

The implementation response must include:

```text
summary:
  - <what changed>

validation:
  - <command>: pass|fail

observed next state:
  - <state>

error signals:
  - none
  - or list blockers

control decision:
  - admit|revise|reject
```

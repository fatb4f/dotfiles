# Proposal: Static Root Registry for Dotfiles Agent Routing

Status: proposal requiring review
Decision state: not accepted, not implemented
Scope: dotfiles Codex / AGENTS.md / skill routing / context carry-over reduction

## Problem

Codex currently tends to carry large context frames across work sessions, even when the effective routing surface is mostly stable.

In the dotfiles repo, the root `AGENTS.md`, intermediary `AGENTS.md` files, and installed skill surfaces change infrequently compared to ordinary implementation work. Re-discovering or carrying this routing context repeatedly creates unnecessary context pressure.

The desired behavior is not broad recursive discovery. The desired behavior is:

```text
root route selection
→ selected downstream contract
→ selected skill/task
→ targeted pattern/eval load
→ bounded final artifact
```

## Proposal

Introduce a static, versioned root registry that summarizes the downstream routing graph.

The root node should not require Codex to discover past the root by default. Instead, Codex should read the root registry, select a domain/task contract, and load only the selected downstream authority.

## Current shape

The repo already has the right human-readable routing shape:

```text
AGENTS.md
  root router

cue.mods/AGENTS.md
  Hookrail/CUE domain router

chezmoi/AGENTS.md
  chezmoi domain router

shell-wrap/AGENTS.md
  Bashly/shell-wrapper domain router
```

Each intermediary router points to an associated skill and bounded task set.

## Target shape

```text
root AGENTS.md
  points to static root registry

root registry
  owns stable downstream graph summary

nested AGENTS.md
  remains present as fallback and local landmark

local CUE node / contract
  owns machine-readable domain/task contract

skill/*
  owns agent-facing task affordance

patterns/evals
  own constraints, invariants, proofs, and final artifact checks
```

## Key invariant

```text
Codex should not be required to discover past the root node.
```

When the registry can answer the route, nested `AGENTS.md` files are fallback landmarks, not mandatory discovery targets.

## Proposed root registry contents

The registry should include, at minimum:

```text
registry version
domain id
domain path
fallback AGENTS.md path
local CUE node / contract path
associated skill
available task ids
keyword surface
pattern authority paths
eval authority paths
forbidden cross-domain loads
```

Example domains:

```text
chezmoi
hookrailCue
shellWrap
gitWorkflow
```

## Carry-over replacement

Instead of carrying large context frames, carry a compact contract object:

```text
registryVersion
selectedDomain
selectedTask
requiredLoads
forbiddenLoads
finalArtifactKind
evalGate
```

This object should be small enough to survive compaction and sufficient to resume the task without rediscovering the repo graph.

## Non-goals

This proposal does not require:

```text
new runtime router
recursive agent calls
agent-sdk revival
Go tools/flow runner
dynamic filesystem sweep
mandatory nested AGENTS.md discovery
large context frame generation
```

## Review questions

1. Should the root registry live in CUE, Markdown, or both?
2. Should nested `AGENTS.md` files be generated from the registry or remain manually maintained fallback landmarks?
3. What is the minimum viable registry schema?
4. Which task ids must be represented first?
5. What evals should prove Codex stops at root unless fallback is required?
6. What should count as a stale registry condition?
7. What is the smallest carry-over contract that preserves task continuity?

## Proposed first review slice

Add a docs-only proposal file describing:

```text
problem
current routing shape
target registry shape
non-goals
review questions
acceptance criteria
```

Do not implement the registry yet.

## Proposed acceptance criteria for review

The proposal is review-ready when it clearly states:

```text
root registry is the stable graph
nested AGENTS.md files are fallback landmarks
Codex should not discover past root by default
carry-over should use contract handles, not context frames
simple evals should catch recursive discovery and wrong-domain loading
```

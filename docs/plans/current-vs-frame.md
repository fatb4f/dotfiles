• Current State

  Dotfiles Hookrail already has the right execution spine:

  - cue.mods/hookrail owns the hook schemas, manifest projection, capture policy, trace row, and closeout logic.
  - shell-wrap/src/hookrail is a thin Bashly adapter that reads stdin, enriches input, asks CUE for projections, and persists artifacts.
  - The stop hook already has a declarative closeout gate in CUE via #GitCloseoutReason and #HookProjection.
  - Validation is already CUE-driven through hookrail doctor.

  What it does not yet have is a typed, machine-readable authority map for the agent-facing operating model:

  - active source surfaces
  - projected/deployed surfaces
  - legacy surfaces
  - preferred observation tools
  - forbidden fallback paths
  - validation commands
  - skill routing
  - materialization rules

  So the current dotfiles state is “good hook/runtime contract, missing registry/router layer.”

  What Should Be Ported From frame

  Port the declarative control-plane shape, not the runtime machinery.

  Use the frame patterns as a model for these pieces:

  - #AgentContract as the top-level registry object
  - surfaces.active, surfaces.preferred, surfaces.fallback, surfaces.legacy
  - observation policy
  - gitWorkflow
  - turnStart
  - validation
  - skillRouting
  - authorityBoundaries
  - a projection layer like #AuthoritySummary / #ForbiddenConstraints

  That is the useful part of frame: a typed map that tells Codex and Hookrail what exists, what is preferred, what is forbidden, and what commands are
  authoritative.

  What Should Not Be Ported

  Do not port the frame control-plane failure modes:

  - any sidecar behavior that tries to influence internal reasoning or planning
  - any MCP transport logic that cleans or normalizes returned objects before the agent sees them
  - any hidden planner/observer runtime that becomes a second control system
  - any old repo-git / repo-rg fallback architecture as an active path
  - any frame-specific runtime examples, old naming, or archived migration scaffolding

  The important boundary is:

  - raw observations may be captured
  - typed projections may be produced in CUE
  - the hook layer must not become the planner

  Recommended Minimal Port

  For dotfiles, I would port only this subset first:

  - surfaces
  - observation
  - gitWorkflow
  - validation
  - skillRouting
  - authorityBoundaries

  Then add a projection export such as:

  - #AuthoritySummary
  - #PreferredObservationTools
  - #ForbiddenFallbackPaths
  - #ValidationCommands

  That gives Hookrail a typed registry without importing the old frame sidecar behavior.

  Net Assessment

  - Dotfiles is already strong on hook validation and projection.
  - Frame is the right source for the registry shape.
  - The safe port is declarative policy only.
  - The unsafe port is any runtime that reintroduces planner-adjacent sidecar behavior.

  If you want, I can next turn this into a concrete dotfiles cue schema layout: one file for the registry, one for projections, one for validation surfaces,
  and one for generated docs.

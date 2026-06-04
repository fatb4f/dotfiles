#!/usr/bin/env sh
set -eu

pattern='cue-flow|cueFlow|FlowContract|flow_graph|go-flow-runner|finalValueContainsFill|runnerMayCallTaskFill'

if rg "$pattern" cue docs AGENTS.cue AGENTS.md; then
  echo "RALPH vocabulary check failed: legacy task-graph terms remain." >&2
  exit 1
fi

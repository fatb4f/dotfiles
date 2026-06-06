package manifests

localNodeContextNormalization: {
	id: "local-node-context-normalization"

	generatedBy: "R"

	inputs: [
		"nodes/chezmoi",
		"nodes/workspace/AGENTS.cue",
		"nodes/workspace/projections.cue",
		"nodes/workspace/patterns/wezterm_workspace.cue",
		"nodes/workspace/patterns/nvim_smart_splits.cue",
	]

	outputs: [
		".codex/context.cue",
		".codex/nodes/schema.cue",
		".codex/nodes/chezmoi.cue",
		".codex/nodes/projections.cue",
		".codex/nodes/wezterm_workspace.cue",
		".codex/nodes/nvim_smart_splits.cue",
	]

	claims: [
		".codex/nodes is normalized local node-context cache",
		".codex/nodes does not grant authority, load admissibility, mutation admissibility, execution permission, or policy",
		".codex/context.cue, when present, is a generated rollup/index over local context and not an authority surface",
	]
}

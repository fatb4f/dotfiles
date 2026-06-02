package flow

import projections "github.com/fatb4f/dotfiles/cue/patterns/projections"

#FlowTask: {
	kind: "gopls"

	moduleDir: string
	checkedFiles: [...string]

	workspaceSummary?: string
	diagnostics?: string
	evidence?: #FlowEvidence
}

flow: #FlowTask & {
	moduleDir: "shell-wrap/src/hookrail"
	checkedFiles: [
		"cmd/hookrail-flow/main.go",
		"internal/flowproof/flow.go",
		"internal/flowproof/mcp.go",
		"internal/flowproof/flow_test.go",
	]
}

report: #FlowReport & {
	task:               flow
	evidence:           flow.evidence
	normalizedResponse: projections.cueFlowPromotedProjectionBindingSlice.fixtures.good.normalizedResponse
	diagnosticResponse: projections.cueFlowPromotedProjectionBindingSlice.fixtures.bad.keywordRelevance.normalizedResponse
}

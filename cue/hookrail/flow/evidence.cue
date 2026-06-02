package flow

#FlowEvidence: {
	schemaVersion: "cuerail.hookrailFlowEvidence.v1"
	source:        "gopls-mcp"
	status:        "ok"

	moduleDir: string
	checkedFiles: [...string]

	workspaceSummary: string
	diagnostics:      string
}

#FlowReport: {
	schemaVersion: "cuerail.hookrailFlowReport.v1"
	taskKind:      "gopls"
	task:          #FlowTask
	evidence:      #FlowEvidence
}

package flow

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

#FlowEvidence: {
	schemaVersion: "cuerail.hookrailFlowEvidence.v1"
	source:        "gopls-mcp"
	status:        "ok"

	moduleDir: string
	checkedFiles: [...string]

	workspaceSummary: string
	diagnostics:      string
	runtimeTrace:     #RuntimeTraceBundle
}

#ContextSizeEstimate: {
	method: string
	bytes:  int
	lines:  int
	files:  int
}

#RuntimeTrace: {
	runID:                       string
	selectedPatternIDs?:          [...string]
	promotionOutcome:            domain.#PromotionGateOutcome
	exposedFiles:                 [...domain.#LoadedFileEvidence]
	deniedLoads:                 [...domain.#DeniedLoadEvidence]
	relationRefs:                domain.#RelationRefList
	factRefs:                    domain.#FactRefList
	adapterActionClassification: string
	broadInputSurface:           #ContextSizeEstimate
	projectedContextSurface:     #ContextSizeEstimate
}

#RuntimeTraceBundle: {
	schemaVersion: "cuerail.runtimeTraceBundle.v1"
	method:        "rough byte/line/file estimate; not tokenizer exact"
	good:          #RuntimeTrace
	rejected:      #RuntimeTrace
}

#FlowReport: {
	schemaVersion:      "cuerail.hookrailFlowReport.v1"
	taskKind:           "gopls"
	task:               #FlowTask
	evidence:           #FlowEvidence
	normalizedResponse: domain.#NormalizedRootResponse
	diagnosticResponse: domain.#NormalizedRootResponse
}

package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

import workflows "github.com/fatb4f/dotfiles/cue/patterns/workflows"

#WorkflowSlice: {
	schemaVersion: "cuerail.workflowSlice.v1"
	selected:      workflows.generatedCliChange
	involvedDomainCards: {
		sourceCode: domain.sourceCode
		shellWrap:  domain.shellWrap
		cue:        domain.cue
		git:        domain.git
	}
}

generatedCliChangeSlice: #WorkflowSlice & {
	selected: workflows.generatedCliChange
}

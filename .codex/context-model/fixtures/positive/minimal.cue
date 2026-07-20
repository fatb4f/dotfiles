package positive

import model "github.com/fatb4f/dotfiles/context-model:contextmodel"

minimal: model.#ContextState & {
	request: {
		requestID: "issue-54"
		prompt:    "Implement the provisional CUE context model."
		repository: {
			repository: "fatb4f/dotfiles"
			root:       "."
			revision:   "main"
		}
		allowedPaths:           [".codex/context-model"]
		requestedProjectionIDs: ["agent-context-resolver"]
	}
	inventory: model.rootSeed.inventory
	observations: {
		"prompt.issue-54": {
			kind:        "prompt"
			subject:     "issue-54"
			facts:       {objective: "implement-cue-model"}
			diagnostics: []
			provenance: {
				semanticRole:   "evidence"
				artifactClass:  "runtime_observation"
				claimAuthority: "none"
			}
		}
	}
	providerObservations: []
	evidence: {
		"evidence.issue-54": {
			summary:        "The prompt explicitly selects the CUE seed objective."
			observationIDs: ["prompt.issue-54"]
			provenance: {
				semanticRole:   "evidence"
				artifactClass:  "runtime_observation"
				claimAuthority: "candidate"
			}
		}
	}
	hypotheses: {
		"hypothesis.context-model": {
			kind:        "implementation-objective"
			statement:   "The context-model source is the relevant mutation surface."
			state:       "accepted"
			evidenceIDs: ["evidence.issue-54"]
			confidence:  1
			derivedBy:   "dspy.context-establishment"
		}
	}
	selected: {
		fragments: [{
			fragmentID:  "resolver.lifecycle"
			reason:      "The resolver lifecycle constrains the refactor."
			evidenceIDs: ["evidence.issue-54"]
		}]
		files: [{
			path:        ".codex/context-model/model.cue"
			reason:      "The issue requires a CUE root seed."
			evidenceIDs: ["evidence.issue-54"]
		}]
		providers: []
		workflows: [{
			workflowID:  "context-establishment"
			reason:      "The reactive workbook establishes context."
			evidenceIDs: ["evidence.issue-54"]
		}]
	}
	gaps:      {}
	conflicts: {}
	sufficiency: {
		state:                 "sufficient"
		reasons:               ["The objective and bounded mutation surface are explicit."]
		blockingGapIDs:        []
		unresolvedConflictIDs: []
	}
}

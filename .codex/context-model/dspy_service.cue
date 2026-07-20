package contextmodel

import "strings"

// Provisional transport authority for an s6-supervised DSPy/Codex inference
// service. The service proposes a candidate decision; the Marimo workbook keeps
// authority for evidence admission, sufficiency derivation, and projection.

#DspyCorrelation: close({
	sessionID: #NonEmptyString
	turnID:    #NonEmptyString
	role:      "correlation_only"
})

#DspyInferenceDeadline: close({
	budgetMs:           int & >=100 & <=9000
	interruptReserveMs: int & >=100 & <=2000

	_totalMs: budgetMs + interruptReserveMs
	_totalMs: <=9500
})

#DspyInferenceExpectations: close({
	dspyProgramDigest:    #Digest
	decisionSchemaDigest: #Digest
	serviceConfigDigest:  #Digest
})

#DspyInferenceInputs: close({
	request:      close(#ContextRequest)
	inventory:    close(#ContextInventory)
	observations: close({[#ID]: close(#SourceObservation)})
	evidence:     close({[#ID]: close(#Evidence)})
	codeIntel:    close({[#Path]: _})
})

#DspyDecisionSelection: {
	reason:      #NonEmptyString
	evidenceIDs: #NonEmptyIDs
}

#DspyFragmentDecisionSelection: close({
	#DspyDecisionSelection
	ids: [...#ID]
})

#DspyFileDecisionSelection: close({
	#DspyDecisionSelection
	ids: [...#Path]
})

#DspyProviderDecisionSelection: close({
	#DspyDecisionSelection
	ids: [...#ID]
})

#DspyWorkflowDecisionSelection: close({
	#DspyDecisionSelection
	ids: [...#ID]
})

// This mirrors the strict Python ContextDecision transport. It intentionally
// excludes observations, admitted state, sufficiency summaries, and projections.
#ContextDecision: close({
	hypotheses:         close({[#ID]: #ContextHypothesis})
	fragments:          #DspyFragmentDecisionSelection
	files:              #DspyFileDecisionSelection
	providers:          #DspyProviderDecisionSelection
	workflows:          #DspyWorkflowDecisionSelection
	gaps:               close({[#ID]: #ContextGap})
	conflicts:          close({[#ID]: #ContextConflict})
	sufficiencyState:   "insufficient" | "provisional" | "sufficient"
	sufficiencyReasons: [...#NonEmptyString] & [_, ...]
})

#DspyRuntimeIdentity: close({
	serviceID:             #ID
	serviceVersion:        #NonEmptyString
	dspyProgramDigest:     #Digest
	decisionSchemaDigest:  #Digest
	serviceConfigDigest:   #Digest
	model:                 #NonEmptyString
	reasoningEffort:       "minimal" | "low" | "medium" | "high" | "xhigh"
	openaiCodexVersion:    #NonEmptyString
	codexRuntimeVersion:   #NonEmptyString
	transport:             "openai_codex_python_sdk"
	sdkManagedAppServer:   true
	persistentClient:      true
	threadMode:            "fresh_ephemeral"
	threadPersisted:       false
	parentThreadInherited: false
})

#DspyQueueState: close({
	depth:              int & >=0
	capacity:           int & >0
	activeTurns:        int & >=0
	maxConcurrentTurns: int & >0

	depth:       <=capacity
	activeTurns: <=maxConcurrentTurns
})

#DspyFailureKind:
	"deadline_exceeded" |
		"interrupted" |
		"busy" |
		"service_unavailable" |
		"authentication_unavailable" |
		"schema_mismatch" |
		"invalid_model_output" |
		"request_rejected" |
		"runtime_error"

#DspyFailurePhase: "queue" | "startup" | "inference" | "validation" | "shutdown"

#DspyTransportFailure: close({
	kind:            #DspyFailureKind
	phase:           #DspyFailurePhase
	message:         #NonEmptyString
	retryable:       bool
	diagnosticCode?: #ID
})

#DspyInferenceResultBase: {
	requestID:   #ID
	correlation: #DspyCorrelation
	inputDigest: #Digest
	runtime:     #DspyRuntimeIdentity
	queue:       #DspyQueueState
	durationMs:  int & >=0
}

#DspyInferenceCompleted: close({
	#DspyInferenceResultBase
	schema:            "dotfiles.dspy-inference-result.v0"
	status:            "completed"
	candidateDecision: #ContextDecision
})

#DspyInferenceFailed: close({
	#DspyInferenceResultBase
	schema:  "dotfiles.dspy-inference-result.v0"
	status:  "failed"
	failure: #DspyTransportFailure
})

#DspyInferenceResult: #DspyInferenceCompleted | #DspyInferenceFailed

#DspyInferenceRequest: close({
	schema:      "dotfiles.dspy-inference-request.v0"
	requestID:   #ID
	_requestID:  requestID
	correlation: #DspyCorrelation
	deadline:    #DspyInferenceDeadline
	expected:    #DspyInferenceExpectations
	inputDigest: #Digest
	inputs: #DspyInferenceInputs & {
		request: {requestID: _requestID}
	}

	_observationIDs: [for observationID, _ in inputs.observations {observationID}]
	_evidenceIDs:    [for evidenceID, _ in inputs.evidence {evidenceID}]

	_evidenceObservationRefs: [for _, item in inputs.evidence {
		for observationID in item.observationIDs {
			[for knownID in _observationIDs if knownID == observationID {knownID}] & [_, ...]
		}
	}]
	_codeIntelPathRefs: [for path, _ in inputs.codeIntel {
		[for allowedPath in inputs.request.allowedPaths if allowedPath == "." || path == allowedPath || strings.HasPrefix(path, allowedPath + "/") {allowedPath}] & [_, ...]
	}]
})

// Validation relation joining one closed request to one closed service result.
// It is not itself transmitted, so the relation remains open only for hidden
// referential-integrity derivations.
#DspyInferenceExchange: {
	request: #DspyInferenceRequest
	result: #DspyInferenceResult & {
		requestID:   request.requestID
		correlation: request.correlation
		inputDigest: request.inputDigest
		runtime: {
			dspyProgramDigest:    request.expected.dspyProgramDigest
			decisionSchemaDigest: request.expected.decisionSchemaDigest
			serviceConfigDigest:  request.expected.serviceConfigDigest
		}
	}

	if result.status == "completed" {
		_candidate:            result.candidateDecision
		_inventoryFragmentIDs: [for fragmentID, _ in request.inputs.inventory.fragments {fragmentID}]
		_inventoryProviderIDs: [for providerID, _ in request.inputs.inventory.providers {providerID}]
		_inventoryWorkflowIDs: [for workflowID, _ in request.inputs.inventory.workflows {workflowID}]
		_evidenceIDs:          [for evidenceID, _ in request.inputs.evidence {evidenceID}]

		_fragmentRefs: [for fragmentID in _candidate.fragments.ids {
			[for knownID in _inventoryFragmentIDs if knownID == fragmentID {knownID}] & [_, ...]
		}]
		_providerRefs: [for providerID in _candidate.providers.ids {
			[for knownID in _inventoryProviderIDs if knownID == providerID {knownID}] & [_, ...]
		}]
		_workflowRefs: [for workflowID in _candidate.workflows.ids {
			[for knownID in _inventoryWorkflowIDs if knownID == workflowID {knownID}] & [_, ...]
		}]
		_fileBoundaryRefs: [for path in _candidate.files.ids {
			[for allowedPath in request.inputs.request.allowedPaths if allowedPath == "." || path == allowedPath || strings.HasPrefix(path, allowedPath + "/") {allowedPath}] & [_, ...]
		}]
		_decisionEvidenceRefs: [
			for group in [_candidate.fragments, _candidate.files, _candidate.providers, _candidate.workflows] {
				for evidenceID in group.evidenceIDs {
					[for knownID in _evidenceIDs if knownID == evidenceID {knownID}] & [_, ...]
				}
			},
			for _, hypothesis in _candidate.hypotheses {
				for evidenceID in hypothesis.evidenceIDs {
					[for knownID in _evidenceIDs if knownID == evidenceID {knownID}] & [_, ...]
				}
			},
			for _, conflict in _candidate.conflicts {
				for evidenceID in conflict.evidenceIDs {
					[for knownID in _evidenceIDs if knownID == evidenceID {knownID}] & [_, ...]
				}
			},
		]
	}
}

#DspyServiceIsolation: close({
	sandbox:                 "read_only"
	approvalMode:            "deny_all"
	hooksEnabled:            false
	shellEnabled:            false
	unifiedExecEnabled:      false
	appsEnabled:             false
	mcpEnabled:              false
	webSearchEnabled:        false
	multiAgentEnabled:       false
	browserEnabled:          false
	computerEnabled:         false
	imageGenerationEnabled:  false
	inheritUserInstructions: false
})

#DspyServiceConfig: close({
	schema:    "dotfiles.dspy-codex-service-config.v0"
	serviceID: "dspy-codexd"
	socket: close({
		name:                    #Path
		directoryMode:           "0700"
		socketMode:              "0600"
		peerCredentialsRequired: true
	})
	protocol: close({
		framing:       "length_prefixed_json"
		requestSchema: "dotfiles.dspy-inference-request.v0"
		resultSchema:  "dotfiles.dspy-inference-result.v0"
	})
	supervision: close({
		manager:               "s6"
		readinessNotification: true
	})
	limits: close({
		maxRequestBytes:    int & >=1024 & <=1048576
		maxResponseBytes:   int & >=1024 & <=1048576
		maxInferenceMs:     int & >=100 & <=9000
		maxQueueDepth:      int & >=0 & <=128
		maxConcurrentTurns: int & >0 & <=16
	})
	isolation: #DspyServiceIsolation
	readinessRequirements: close({
		dspyProgramLoaded:    true
		sdkClientInitialized: true
		accountAuthenticated: true
		isolationApplied:     true
		socketListening:      true
	})
})

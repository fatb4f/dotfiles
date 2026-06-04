package projections

import domain "github.com/fatb4f/dotfiles/cue/patterns/domain"

_validationAssessment: cueFlowValidationAssessmentSlice
_runID:                "agentflow-premutation-gate-001"
_runArtifactDir:       "var/run/hookrail/runs/\(_runID)"
_traceArtifactPath:    "\(_runArtifactDir)/flow-trace.json"
_reportArtifactPath:   "\(_runArtifactDir)/validation-report.json"
_latestTraceAlias:     "var/run/hookrail/flow-trace.latest.json"
_latestReportAlias:    "var/run/hookrail/validation-report.latest.json"

cueFlowValidationReportManifest: domain.#ValidationReportManifest & {
	reportID: "cue-flow-validation-report.latest"
	generatedFrom: {
		projection: "cueFlowValidationReportManifest"
		command:    "cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json"
	}
	runID: _runID
	artifacts: {
		trace: {
			path:        _traceArtifactPath
			latestAlias: _latestTraceAlias
		}
		validationReport: {
			path:        _reportArtifactPath
			latestAlias: _latestReportAlias
		}
	}
	validationAssessmentRef: "cueFlowValidationAssessmentSlice"
	validationContractRef:   "domain.#RootValidationContract"
	observedFacts:           _validationAssessment.observedFacts
	gateResults: {
		authorityBinding:            _validationAssessment.validationGates.authorityBinding.outcome
		promotionBehavior:           _validationAssessment.validationGates.promotionBehavior.outcome
		exposureBinding:             _validationAssessment.validationGates.exposureBinding.outcome
		thinAdapterBoundary:         _validationAssessment.validationGates.thinAdapterBoundary.outcome
		runtimeReductionObservation: _validationAssessment.validationGates.runtimeReductionObservation.outcome
	}
	overallOutcome: _validationAssessment.outcome
	sourceArtifacts: [
		"docs/architecture/agentnode-green-light-review.md",
		_traceArtifactPath,
		_reportArtifactPath,
		_latestTraceAlias,
		_latestReportAlias,
		"cue/patterns/domain/schema.cue",
		"cue/patterns/projections/validation-assessment-slice.cue",
	]
	validationCommands: [
		"cue vet .",
		"cue vet ./cue/agentnode/...",
		"cue vet ./nodes/workspace/...",
		"cue vet ./cue/patterns/...",
		"cue export ./cue/patterns/projections -e cueFlowFactRootedRelationSlice --out json",
		"cue export ./cue/patterns/projections -e cueFlowAuthorizationEvidenceSlice --out json",
		"cue export ./cue/patterns/projections -e cueFlowPromotionByUnificationSlice --out json",
		"cue export ./cue/patterns/projections -e cueFlowPromotedProjectionBindingSlice --out json",
		"cue export ./cue/patterns/projections -e cueFlowValidationAssessmentSlice --out json",
		"cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json",
		"go test ./... (from shell-wrap/src/hookrail)",
	]
	exportCommands: [
		"cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json",
		"cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json > var/run/hookrail/validation-report.latest.json",
	]
	runtimeEvidence: {
		acceptedExposedFiles:  _validationAssessment.observedFacts.facts["review.accepted_exposed_file_count"].value
		rejectedExposedFiles:  _validationAssessment.observedFacts.facts["review.rejected_exposed_file_count"].value
		rejectedDeniedLoads:   _validationAssessment.observedFacts.facts["review.rejected_denied_load_count"].value
		broadSurfaceBytes:     _validationAssessment.observedFacts.facts["review.broad_surface_bytes"].value
		broadSurfaceLines:     _validationAssessment.observedFacts.facts["review.broad_surface_lines"].value
		broadSurfaceFiles:     _validationAssessment.observedFacts.facts["review.broad_surface_files"].value
		projectedSurfaceBytes: _validationAssessment.observedFacts.facts["review.projected_surface_bytes"].value
		projectedSurfaceLines: _validationAssessment.observedFacts.facts["review.projected_surface_lines"].value
		projectedSurfaceFiles: _validationAssessment.observedFacts.facts["review.projected_surface_files"].value
		byteReductionPercent:  _validationAssessment.observedFacts.facts["review.reduction_bytes_percent"].value
		lineReductionPercent:  _validationAssessment.observedFacts.facts["review.reduction_lines_percent"].value
		fileReductionPercent:  _validationAssessment.observedFacts.facts["review.reduction_files_percent"].value
		estimatorMethod:       _validationAssessment.observedFacts.facts["estimator.method_is_rough_not_tokenizer_exact"].value
	}
	contextReduction: {
		broad: {
			bytes: runtimeEvidence.broadSurfaceBytes
			lines: runtimeEvidence.broadSurfaceLines
			files: runtimeEvidence.broadSurfaceFiles
		}
		projected: {
			bytes: runtimeEvidence.projectedSurfaceBytes
			lines: runtimeEvidence.projectedSurfaceLines
			files: runtimeEvidence.projectedSurfaceFiles
		}
		reductionPercent: {
			bytes: runtimeEvidence.byteReductionPercent
			lines: runtimeEvidence.lineReductionPercent
			files: runtimeEvidence.fileReductionPercent
		}
	}
	roughEdges: _validationAssessment.roughEdges
	nextHardening: [
		"Add comparison tooling over persisted run artifacts once multiple concrete runs exist.",
		"Add an exact tokenizer or better estimator if rough byte/line/file estimates stop being predictive.",
		"Add more real task-pattern runs.",
		"Harden the negative-path matrix from observed traces.",
		"Normalize projectedPrompt versus promptProjection if the duplication remains after consumer integration.",
		"Add a CI wrapper for the module-local Go test and the CUE exports.",
	]
	rationale: _validationAssessment.outcome.rationale
}

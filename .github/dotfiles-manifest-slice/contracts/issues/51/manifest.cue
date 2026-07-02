package contract

import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

_implementationWorkflow: [
	{order: 1, id: "#MakeDotfilesPrimitive", constructor: impl.#MakeDotfilesPrimitive, instantiateAt: "_primitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: impl.#MakeObservedSurface, instantiateAt: "_observed"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: impl.#MakeAdmissibleSurface, instantiateAt: "_admissible"},
	{order: 4, id: "#MakePredicateSet", constructor: impl.#MakePredicateSet, instantiateAt: "_predicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: impl.#MakePromotionCandidate, instantiateAt: "_promotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: impl.#MakeSurfaceSet, instantiateAt: "_surfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: impl.#MakeNegativeFixture, instantiateAt: "_negativeFixtures"},
	{order: 8, id: "#MakeBottomCheckPlan", constructor: impl.#MakeBottomCheckPlan, instantiateAt: "_bottomCheckPlans"},
	{order: 9, id: "#MakeBottomCheckProof", constructor: impl.#MakeBottomCheckProof, instantiateAt: "checks/_negativeBottomChecks"},
	{order: 10, id: "#MakeValidationPlan", constructor: impl.#MakeValidationPlan, instantiateAt: "_validation"},
	{order: 11, id: "#MakeCompletionReport", constructor: impl.#MakeCompletionReport, instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#DotfilesConfigSurface"
			role: "bounded issue 51 FIFO preview implementation surface"
			requiredFields: ["path", "role"]
			constraints: [
				"edits must stay inside declared dotfiles target paths",
				"runtime observations are evidence only",
				"projection artifacts are evidence only",
				"issue-template contract issue paths are not target surfaces for this slice",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name: "#ObservedDotfilesSurface"
			target: "#DotfilesConfigSurface"
			paths: [
				"chezmoi/private_dot_config/xplr/init.lua",
				"chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua",
				"chezmoi/private_dot_local/bin/executable_term-xplr-preview",
				"docs/xplr-smart-splits-mux-rpc-workflow.md",
			]
			evidence: "repo-local FIFO preview implementation files"
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name: "#AdmissibleDotfilesSurface"
			target: "#DotfilesConfigSurface"
			allows: [
				"move readiness proof into the preview reader after FIFO acquisition",
				"gate xplr StartFifo on reader-owned readiness",
				"restart or verify the preview reader before reusing a cached preview pane",
				"prevent xplr preview state drift when preview admission fails",
			]
			forbids: [
				"targeting .github/ISSUE_TEMPLATE/contracts/issues for this dotfiles slice",
				"treating pane creation alone as FIFO reader readiness",
				"reusing cached preview panes without reader liveness proof",
				"setting xplr preview state as authority before preview admission succeeds",
			]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name: "#DotfilesSlicePredicates"
			predicates: [
				{id: "target-paths-declared", rule: "all materialized edits must be under declared dotfiles target paths"},
				{id: "issue-template-paths-pruned", rule: "issue-template contract issue paths are not generated target surfaces"},
				{id: "reader-owned-readiness", rule: "preview readiness must be emitted by the preview reader after FIFO acquisition"},
				{id: "cached-pane-not-reader-proof", rule: "cached pane identity is not sufficient reader liveness proof"},
				{id: "xplr-state-not-authority", rule: "xplr preview state must not drift when preview admission fails"},
				{id: "projection-evidence-only", rule: "projection artifacts remain evidence"},
			]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name: "#DotfilesImplementationCandidate"
			from: "#ObservedDotfilesSurface"
			to: "#AdmissibleDotfilesSurface"
			intent: ["correct issue 51 FIFO preview readiness and stale reader semantics"]
			nonGoals: [
				"adding issue-template contract issue slices",
				"using preview-tabbed.xplr as the default preview dependency",
				"moving preview ownership into Neovim",
				"adding image or PDF preview protocols in this slice",
			]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#AdmissibleDotfilesSurface"]
		observed: ["#ObservedDotfilesSurface"]
		candidates: ["#DotfilesImplementationCandidate"]
		fixtures: ["_negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["dotfilesImplementationCueBlockSlice"]
	}
}

_negativeFixtures: []
_bottomCheckPlans: []

_validation: {
	in: {
		name: "dotfilesValidationPlan"
		commands: []
	}
}

_completion: {
	in: {
		name: "dotfilesCompletionReportContract"
		sections: ["summary", "implementation blocks", "validation", "evidence"]
	}
}

dotfilesImplementationCueBlockSlice: [
	{workflow: _implementationWorkflow},
	{primitives: _primitives},
	{observed: _observed},
	{admissible: _admissible},
	{predicates: _predicates},
	{promotion: _promotion},
	{surfaces: _surfaces},
	{negativeFixtures: _negativeFixtures},
	{bottomCheckPlans: _bottomCheckPlans},
	{validation: _validation},
	{completion: _completion},
]

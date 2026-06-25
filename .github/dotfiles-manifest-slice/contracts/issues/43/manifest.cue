package issue43

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

_workflowIndex: [for step in _implementationWorkflow {
	order: step.order
	id: step.id
	instantiateAt: step.instantiateAt
}]

_issue: {
	number: 43
	title: "dotfiles: route xplr project-tree intents through smart-splits mux RPC"
	path: ".github/dotfiles-manifest-slice/contracts/issues/43/manifest.cue"
}

_targetPaths: [
	"chezmoi/private_dot_config/wezterm/modules/workspaces/xplr_rpc.lua",
	"chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua",
	"chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua",
	"chezmoi/private_dot_config/wezterm/wezterm.lua",
	"chezmoi/private_dot_config/nvim/lua/workflow/mux_rpc.lua",
	"chezmoi/private_dot_config/nvim/lua/workflow/init.lua",
	"chezmoi/private_dot_config/xplr/init.lua",
	".github/dotfiles-manifest-slice/contracts/issues/43/manifest.cue",
	".github/dotfiles-manifest-slice/contracts/issues/43/checks/bottom.cue",
]

_primitives: [
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#XplrProjectTreeIntent"
			role: "bounded xplr file-open and explorer-layout intent"
			requiredFields: ["op", "path or kind", "project root", "Neovim socket"]
			constraints: [
				"open paths must stay inside TERM_PROJECT_ROOT",
				"layout kinds are hide, reveal, narrow, or wide",
				"intents are validated by WezTerm before Neovim dispatch",
			]
			closed: true
		}
	},
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#SmartSplitsMuxRpc"
			role: "socket-backed Neovim RPC executor for smart-splits mux operations"
			requiredFields: ["dispatch operation", "validated payload", "mux execution result"]
			constraints: [
				"Neovim hosts smart-splits.mux",
				"WezTerm does not reimplement generic smart-splits pane mechanics",
				"xplr does not depend directly on smart-splits.nvim",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name: "#ObservedDotfilesMuxSurfaces"
			target: "#XplrProjectTreeIntent"
			paths: _targetPaths
			evidence: "repo-local WezTerm, Neovim, xplr, and issue manifest files"
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name: "#AdmissibleMuxRpcRouting"
			target: "#SmartSplitsMuxRpc"
			allows: [
				"WezTerm validates xplr open and layout intents",
				"Neovim dispatches validated mux operations through smart-splits.mux",
				"xplr emits bounded TERM_XPLR_RPC operations",
				"WezTerm palette entries reuse the same routing surface",
			]
			forbids: [
				"duplicate project or session topology authority outside WezTerm",
				"direct xplr dependency on smart-splits.nvim",
				"WezTerm pane math replacing smart-splits mux mechanics",
				"generated artifacts as authority",
			]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name: "#MuxRpcRoutingPredicates"
			predicates: [
				{id: "project-root-contained", rule: "file-open paths must be rejected outside TERM_PROJECT_ROOT"},
				{id: "known-layout-kind", rule: "layout routing must reject unknown layout kinds"},
				{id: "socket-present", rule: "missing Neovim socket must be rejected before dispatch"},
				{id: "smart-splits-executor", rule: "focus and resize execution remains owned by smart-splits.mux"},
				{id: "generated-evidence-only", rule: "generated and runtime artifacts are evidence only"},
			]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name: "#MuxRpcRoutingCandidate"
			from: "#ObservedDotfilesMuxSurfaces"
			to: "#AdmissibleMuxRpcRouting"
			intent: [
				"Route xplr file-open and layout intents through WezTerm validation into the socket-backed Neovim smart-splits mux RPC surface.",
			]
			nonGoals: [
				"Neovim project or session picker",
				"duplicate project or session topology authority outside WezTerm",
				"direct xplr dependency on smart-splits.nvim",
				"WezTerm reimplementation of smart-splits pane mechanics",
				"generated artifacts as authority",
			]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#AdmissibleMuxRpcRouting"]
		observed: ["#ObservedDotfilesMuxSurfaces"]
		candidates: ["#MuxRpcRoutingCandidate"]
		fixtures: ["_negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: [
			"normalizedDotfilesIssueManifest",
			"dotfilesValidationPlan",
			"dotfilesCompletionReportContract",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "outside-project-root-rejected"
			input: {op: "open", path: "/tmp/outside-project"}
			expect: "bottom"
			reason: "xplr open must not dispatch paths outside TERM_PROJECT_ROOT"
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "unknown-layout-kind-rejected"
			input: {op: "layout", kind: "fullscreen"}
			expect: "bottom"
			reason: "layout kind must be one of hide, reveal, narrow, or wide"
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "missing-nvim-socket-rejected"
			input: {op: "open", path: "README.md", socket: ""}
			expect: "bottom"
			reason: "missing Neovim socket must stop dispatch"
		}
	},
]

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "outside-project-root-rejected-bottoms"
			fixture: "outside-project-root-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "unknown-layout-kind-rejected-bottoms"
			fixture: "unknown-layout-kind-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "missing-nvim-socket-rejected-bottoms"
			fixture: "missing-nvim-socket-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		name: "dotfilesValidationPlan"
		commands: [
			"cd .github && cue vet ./dotfiles-manifest-slice/contracts/issues/43",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/43 -e normalizedDotfilesIssueManifest",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/43 -e dotfilesValidationPlan",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/43 -e dotfilesCompletionReportContract",
		]
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		name: "dotfilesCompletionReportContract"
		sections: [
			"summary",
			"manifest workflow",
			"target surfaces",
			"materialized config changes",
			"public eval surfaces",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}

issue: _issue

normalizedDotfilesIssueManifest: {
	issue: _issue
	workflow: _workflowIndex
	primitives: [for item in _primitives {item.out}]
	observed: [for item in _observed {item.out}]
	admissible: [for item in _admissible {item.out}]
	predicates: [for item in _predicates {item.out}]
	promotion: [for item in _promotion {item.out}]
	surfaces: _surfaces.out
	negativeFixtures: [for item in _negativeFixtures {item.out}]
	bottomCheckPlans: [for item in _bottomCheckPlans {item.out}]
}

dotfilesValidationPlan: _validation.out

dotfilesCompletionReportContract: _completion.out

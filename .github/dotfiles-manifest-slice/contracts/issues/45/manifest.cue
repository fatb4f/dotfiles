package issue45

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
	order:         step.order
	id:            step.id
	instantiateAt: step.instantiateAt
}]

_issue: {
	number: 45
	title:  "dotfiles: gate Neovim QoL against WezTerm/xplr workflow authority"
	path:   ".github/dotfiles-manifest-slice/contracts/issues/45/manifest.cue"
}

_targetPaths: [
	"docs/" +
	"xplr-" +
	"smart-splits-mux-rpc-workflow.md",
	"chezmoi/private_dot_config/nvim/**",
	"chezmoi/private_dot_config/wezterm/**",
	"chezmoi/private_dot_config/xplr/**",
	".github/dotfiles-manifest-slice/contracts/issues/45/manifest.cue",
	".github/dotfiles-manifest-slice/contracts/issues/45/checks/bottom.cue",
]

_primitives: [
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#NeovimQolBoundaryGate"
			role: "editor-local discovery and invocation-only command boundary"
			requiredFields: ["host", "scope", "project topology ownership", "workspace persistence"]
			constraints: [
				"Neovim may expose buffer, diagnostic, quickfix, symbol, command, and keymap discovery",
				"Neovim may invoke WezTerm or sessionizer commands without owning their topology",
				"project and session topology remains owned by WezTerm",
			]
			closed: true
		}
	},
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#WeztermXplrAuthoritySplit"
			role: "project/session authority, tree UI intent, and pane mechanics boundary"
			requiredFields: ["WezTerm session role", "xplr intent role", "pane executor role"]
			constraints: [
				"WezTerm owns workspace selection and SwitchToWorkspace routing",
				"xplr emits bounded open and layout intent only",
				"smart-splits owns pane focus and resize mechanics",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name:     "#ObservedWorkflowBoundarySurfaces"
			target:   "#NeovimQolBoundaryGate"
			paths:    _targetPaths
			evidence: "repo-local workflow documentation plus WezTerm, Neovim, xplr, and issue-local CUE surfaces"
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:   "#AdmissibleNeovimQolBoundary"
			target: "#NeovimQolBoundaryGate"
			allows: [
				"editor-local picker surfaces for buffers, diagnostics, quickfix, symbols, commands, and keymaps",
				"socket-backed RPC execution after WezTerm validation",
				"invocation-only bridge commands that call WezTerm or sessionizer surfaces",
				"issue-local evidence and validation contracts",
			]
			forbids: [
				"Neovim ownership of project or session topology",
				"Neovim workspace ranking or persistence",
				"xplr bypassing WezTerm validation for pane operations",
				"runtime or projected files defining workflow decisions",
			]
		}
	},
	impl.#MakeAdmissibleSurface & {
		in: {
			name:   "#AdmissibleWeztermXplrSplit"
			target: "#WeztermXplrAuthoritySplit"
			allows: [
				"WezTerm project launch and workspace switching",
				"WezTerm validation before Neovim RPC dispatch",
				"xplr focused path selection and bounded layout intent",
				"smart-splits pane focus and resize execution",
			]
			forbids: [
				"project/session selection implemented inside Neovim",
				"xplr direct pane focus or resize integration",
				"generated projections promoted beyond evidence",
			]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name: "#WorkflowBoundaryPredicates"
			predicates: [
				{id: "neovim-editor-local-only", rule: "Neovim QoL surfaces must be editor-local or invocation-only"},
				{id: "wezterm-topology-owner", rule: "WezTerm remains project/session topology and SwitchToWorkspace owner"},
				{id: "xplr-bounded-intent", rule: "xplr emits only open or layout intent through WezTerm"},
				{id: "smart-splits-pane-executor", rule: "pane focus and resize execution remains in smart-splits"},
				{id: "projections-evidence-only", rule: "generated and runtime projections remain evidence only"},
			]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name: "#NeovimQolBoundaryCandidate"
			from: "#ObservedWorkflowBoundarySurfaces"
			to:   "#AdmissibleNeovimQolBoundary"
			intent: [
				"Gate Neovim quality-of-life picker and command additions so they stay editor-local or invocation-only.",
				"Keep issue 44 aligned with the issue 43 WezTerm, tree UI, and pane executor workflow.",
			]
			nonGoals: [
				"new Neovim quality-of-life plugins",
				"new WezTerm sessionizer behavior",
				"new xplr keybindings",
				"project/session selection implemented inside Neovim",
				"xplr direct pane bridge",
				"runtime cache promoted to persistent decision source",
				"generated projections promoted beyond evidence",
			]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#AdmissibleNeovimQolBoundary", "#AdmissibleWeztermXplrSplit"]
		observed: ["#ObservedWorkflowBoundarySurfaces"]
		candidates: ["#NeovimQolBoundaryCandidate"]
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
			name: "neovim-topology-owner-rejected"
			input: {
				host:                   "neovim"
				scope:                  "project-session"
				ownsProjectTopology:    true
				persistsWorkspaceModel: true
			}
			expect: "bottom"
			reason: "Neovim QoL must not own project/session topology or persist workspace models"
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "xplr-direct-pane-bridge-rejected"
			input: {
				host:                 "xplr"
				intent:               "layout"
				route:                "direct-pane-plugin"
				directPaneDependency: true
			}
			expect: "bottom"
			reason: "xplr must emit bounded intent through WezTerm instead of calling pane mechanics directly"
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "generated-decision-source-rejected"
			input: {
				path:           "cache/project-sessions.json"
				isGenerated:    true
				decisionSource: true
			}
			expect: "bottom"
			reason: "generated projections and runtime state are evidence only"
		}
	},
]

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "neovim-topology-owner-bottoms"
			fixture:      "neovim-topology-owner-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "xplr-direct-pane-bridge-bottoms"
			fixture:      "xplr-direct-pane-bridge-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "generated-decision-source-bottoms"
			fixture:      "generated-decision-source-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		name: "dotfilesValidationPlan"
		commands: [
			"cd .github && cue vet ./dotfiles-manifest-slice/contracts/issues/45",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/45 -e normalizedDotfilesIssueManifest",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/45 -e dotfilesValidationPlan",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/45 -e dotfilesCompletionReportContract",
			"cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/45/checks -e '_negativeBottomChecks.neovim-topology-owner-rejected'",
			"cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/45/checks -e '_negativeBottomChecks.xplr-direct-pane-bridge-rejected'",
			"cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/45/checks -e '_negativeBottomChecks.generated-decision-source-rejected'",
			"cd .github && ! rg '[Nn]eovim project picker|[w]orkspace/session topology authority|x[p]lr.*smart-splits|[g]enerated.*authority' ./dotfiles-manifest-slice/contracts/issues/45",
		]
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		name: "dotfilesCompletionReportContract"
		sections: [
			"summary",
			"manifest workflow",
			"authority matrix",
			"forbidden attractors",
			"negative checks",
			"validation",
			"evidence",
			"issue 44 alignment result",
		]
	}
}

issue: _issue

normalizedDotfilesIssueManifest: {
	issue:    _issue
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

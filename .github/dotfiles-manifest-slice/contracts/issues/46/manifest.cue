package issue46

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
	number: 46
	title:  "dotfiles: resolve WezTerm IDE launch from configured active workspace"
	path:   ".github/dotfiles-manifest-slice/contracts/issues/46/manifest.cue"
}

_targetPaths: [
	"chezmoi/private_dot_config/wezterm/modules/workspaces/controller.lua",
	".github/WORKSPACE_IDE_VERIFICATION.md",
	".github/dotfiles-manifest-slice/contracts/issues/46/manifest.cue",
	".github/dotfiles-manifest-slice/contracts/issues/46/checks/bottom.cue",
]

_primitives: [
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#WeztermIdeLaunchSessionResolution"
			role: "active workspace IDE launch session resolver"
			requiredFields: ["active workspace", "pane cwd", "configured sessions_by_workspace index", "runtime session cache"]
			constraints: [
				"cwd-detected configured project sessions take precedence over active workspace lookup",
				"active workspace lookup uses the configured sessions_by_workspace index before launch validation",
				"runtime session cache is seeded only after a configured session validates",
				"unconfigured workspaces keep the explicit launch error",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name:     "#ObservedWeztermIdeLaunchSurfaces"
			target:   "#WeztermIdeLaunchSessionResolution"
			paths:    _targetPaths
			evidence: "WezTerm workspace controller, manual verification checklist, and issue-local CUE contracts"
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:   "#AdmissibleActiveWorkspaceIdeLaunch"
			target: "#WeztermIdeLaunchSessionResolution"
			allows: [
				"pane cwd project detection before workspace-based resolution",
				"configured sessions_by_workspace lookup for the active workspace",
				"runtime session cache seeding after configured session validation",
				"existing explicit error for unconfigured active workspaces",
			]
			forbids: [
				"runtime session cache as persistent project/session authority",
				"workspace lookup overriding cwd-detected project precedence",
				"cache seeding before configured session validation",
				"implicit project creation for unconfigured workspaces",
			]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name: "#IdeLaunchWorkspacePredicates"
			predicates: [
				{id: "cwd-detected-precedence", rule: "cwd-detected configured project sessions must be selected before active workspace lookup"},
				{id: "configured-workspace-resolution", rule: "active workspace launch may resolve from configured sessions_by_workspace"},
				{id: "runtime-cache-not-authority", rule: "runtime cache cannot make an unconfigured workspace launchable"},
				{id: "post-validation-cache-seed", rule: "runtime cache is seeded only after configured session validation"},
				{id: "unconfigured-workspace-error", rule: "unconfigured active workspaces keep the explicit IDE launch error"},
			]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name: "#ActiveWorkspaceIdeLaunchCandidate"
			from: "#ObservedWeztermIdeLaunchSurfaces"
			to:   "#AdmissibleActiveWorkspaceIdeLaunch"
			intent: [
				"Resolve Launch project IDE from the configured active WezTerm workspace when the runtime session cache has not been populated yet.",
				"Keep cwd-detected project precedence and preserve explicit failures for unconfigured workspaces.",
			]
			nonGoals: [
				"central project registry redesign",
				"sessionizer plugin replacement",
				"new project module format",
				"Neovim project/session authority",
				"runtime cache as persistent authority",
			]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#AdmissibleActiveWorkspaceIdeLaunch"]
		observed: ["#ObservedWeztermIdeLaunchSurfaces"]
		candidates: ["#ActiveWorkspaceIdeLaunchCandidate"]
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
			name: "runtime-cache-authority-rejected"
			input: {
				cwdDetected:         false
				configuredWorkspace: false
				runtimeCached:       true
				result:              "configured-workspace"
			}
			expect: "bottom"
			reason: "runtime cache must not make an unconfigured workspace a project session"
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "workspace-overrides-cwd-rejected"
			input: {
				cwdDetected:         true
				configuredWorkspace: true
				result:              "configured-workspace"
			}
			expect: "bottom"
			reason: "active workspace lookup must not override cwd-detected project precedence"
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "prevalidation-cache-seed-rejected"
			input: {
				configuredResolved: true
				validationPassed:   false
				seedRuntimeCache:   true
			}
			expect: "bottom"
			reason: "runtime cache must be seeded only after configured session validation"
		}
	},
]

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "runtime-cache-authority-bottoms"
			fixture:      "runtime-cache-authority-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "workspace-overrides-cwd-bottoms"
			fixture:      "workspace-overrides-cwd-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "prevalidation-cache-seed-bottoms"
			fixture:      "prevalidation-cache-seed-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		name: "dotfilesValidationPlan"
		commands: [
			"cd .github && cue vet ./dotfiles-manifest-slice/contracts/issues/46",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/46 -e normalizedDotfilesIssueManifest",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/46 -e dotfilesValidationPlan",
			"cd .github && cue export ./dotfiles-manifest-slice/contracts/issues/46 -e dotfilesCompletionReportContract",
			"cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/46/checks -e '_negativeBottomChecks.runtime-cache-authority-rejected'",
			"cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/46/checks -e '_negativeBottomChecks.workspace-overrides-cwd-rejected'",
			"cd .github && ! cue export ./dotfiles-manifest-slice/contracts/issues/46/checks -e '_negativeBottomChecks.prevalidation-cache-seed-rejected'",
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
			"runtime cache boundary",
			"negative checks",
			"validation",
			"manual verification",
			"forbidden attractors avoided",
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

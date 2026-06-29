package agentcontextresolver

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_pluginBundleRecommendationWorkflow: [
	{order: 1, id: "#MakePrimitive", constructor: impl.#MakePrimitive, instantiateAt: "_pluginBundlePrimitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: impl.#MakeObservedSurface, instantiateAt: "_pluginBundleObserved"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: impl.#MakeAdmissibleSurface, instantiateAt: "_pluginBundleAdmissible"},
	{order: 4, id: "#MakePredicateSet", constructor: impl.#MakePredicateSet, instantiateAt: "_pluginBundlePredicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: impl.#MakePromotionCandidate, instantiateAt: "_pluginBundlePromotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: impl.#MakeSurfaceSet, instantiateAt: "_pluginBundleSurfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: impl.#MakeNegativeFixture, instantiateAt: "_pluginBundleNegativeFixtures"},
	{order: 8, id: "#MakeBottomCheckPlan", constructor: impl.#MakeBottomCheckPlan, instantiateAt: "_pluginBundleBottomCheckPlans"},
	{order: 9, id: "#MakeValidationPlan", constructor: impl.#MakeValidationPlan, instantiateAt: "_pluginBundleValidation"},
	{order: 10, id: "#MakeCompletionReport", constructor: impl.#MakeCompletionReport, instantiateAt: "_pluginBundleCompletion"},
]

_pluginBundleWorkflowIndex: [for step in _pluginBundleRecommendationWorkflow {
	order:         step.order
	id:            step.id
	instantiateAt: step.instantiateAt
}]

_pluginBundleRecommendationIssue: {
	number:            46
	title:             "agent-context-resolver: implement CUE-authored route matching and dependency closure"
	path:              ".codex/plugins/agent-context-resolver/contracts/agent-context-resolver/plugin_bundle_recommendations.cue"
	sourceTemplateRef: ".github/dotfiles-manifest-slice/contracts/issues/_template/manifest.cue"
}

_pluginBundleTargetPaths: [
	".codex/plugins/agent-context-resolver/contracts/agent-context-resolver/plugin_bundle_recommendations.cue",
	".codex/plugins/agent-context-resolver/contracts/agent-context-resolver/checks/checks.cue",
	".codex/plugins/agent-context-resolver/contracts/agent-context-resolver/**",
	".codex/plugins/agent-context-resolver/generated/*.json",
	".codex/plugins/agent-context-resolver/scripts/agent-context-resolver-hook",
	".codex/plugins/agent-context-resolver/scripts/resolve-agent-context",
]

_pluginBundlePrimitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#PluginBundleRouteCatalogue"
			role: "CUE-authored source of truth for exported prompt route, fragment, provider, route, and gate inventories"
			requiredFields: ["promptRoutes", "routes", "fragments", "providers", "gates", "exports"]
			constraints: [
				"CUE owns route catalogue semantics before bundle generation",
				"runtime consumes bundled JSON only",
				"generated JSON is projection evidence and not independent authority",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#PromptMatcherSemantics"
			role: "deterministic trigger language for route selection"
			requiredFields: ["all", "any", "none", "phrases", "wordTerms", "paths"]
			constraints: [
				"generic terms cannot select a route alone",
				"word terms require token boundaries or explicit path semantics",
				"negative terms must suppress otherwise matching routes",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#RouteDependencyClosure"
			role: "closed route graph projection for selected prompt routes"
			requiredFields: ["selectedRoutes", "dependsOn", "expandedRoutes", "sortOrder"]
			constraints: [
				"every emitted dependsOn target must be emitted in the same controller packet",
				"dependency expansion must be recursive",
				"route output remains sorted by sequence, priority, and id after expansion",
			]
			closed: true
		}
	},
]

_pluginBundleObserved: [
	impl.#MakeObservedSurface & {
		in: {
			name: "ObservedPluginBundleRuntime"
			role: "current sh and jq hook plus bundled generated JSON inventory files"
			factFields: ["prompt", "terms", "invokes", "dependsOn", "generatedJson", "runtimeRequirements"]
			constraints: _pluginBundleTargetPaths
		}
	},
]

_pluginBundleAdmissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:            "AdmissiblePluginBundleMatcher"
			role:            "CUE-exported route catalogue consumed by a small jq runtime matcher"
			observedSurface: "ObservedPluginBundleRuntime"
			requiredFields: ["all", "any", "none", "phrases", "wordTerms", "paths", "dependencyClosure"]
			rejectedFields: ["substringOnlyMatch", "cueAtRuntime", "providerExecution", "externalFactoryLookup", "generatedAuthority"]
			constraints: [
				"the hook must keep runtime dependencies to sh and jq",
				"cue export runs during bundle generation or validation only",
				"route matching must be path-aware and boundary-aware",
				"selected route graphs must be dependency-closed before emission",
			]
		}
	},
]

_pluginBundlePredicates: [
	impl.#MakePredicateSet & {
		in: {
			name:              "#PluginBundleMatcherPredicates"
			role:              "admissibility rules for prompt matching and route graph projection"
			observedSurface:   "ObservedPluginBundleRuntime"
			admissibleSurface: "AdmissiblePluginBundleMatcher"
			derivedPredicates: [
				"catalogue-source-is-cue-and-exported-json-is-projection",
				"runtime-dependencies-are-sh-and-jq-only",
				"generic-terms-cannot-trigger-alone",
				"word-terms-are-boundary-aware",
				"path-terms-are-path-aware",
				"negative-terms-suppress-matches",
				"emitted-routes-are-dependency-closed",
				"provider-declarations-are-not-executed-at-runtime",
			]
			constraints: [
				"predicate truth must derive from exported catalogue structure and hook output",
				"runtime observations are evidence only",
			]
		}
	},
]

_pluginBundlePromotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name:              "#PluginBundleMatcherImplementationCandidate"
			role:              "implementation slice for replacing raw contains matching with exported matcher semantics"
			observedSurface:   "ObservedPluginBundleRuntime"
			admissibleSurface: "AdmissiblePluginBundleMatcher"
			predicateSet:      "#PluginBundleMatcherPredicates"
			controlPredicates: [
				"generic-terms-cannot-trigger-alone",
				"emitted-routes-are-dependency-closed",
				"runtime-dependencies-are-sh-and-jq-only",
			]
			admissibilityEvidence: [
				"cue vet ./contracts/agent-context-resolver/plugin_bundle_recommendations.cue",
				"cue export ./contracts/agent-context-resolver/plugin_bundle_recommendations.cue -e pluginBundleRecommendationManifest",
				"hook smoke tests for positive and negative prompts",
			]
			constraints: [
				"do not run CUE inside the prompt hook",
				"do not execute provider tools from the hook",
				"do not depend on external repository checkouts at runtime",
			]
		}
	},
]

_pluginBundleSurfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["AdmissiblePluginBundleMatcher"]
		observed: ["ObservedPluginBundleRuntime"]
		candidates: ["#PluginBundleMatcherImplementationCandidate"]
		fixtures: [
			"negative.genericProviderTermAccepted",
			"negative.danglingDependencyAccepted",
			"negative.cueRuntimeDependencyAccepted",
		]
		checks: [
			"_negativeBottomChecks.genericProviderTermAccepted",
			"_negativeBottomChecks.danglingDependencyAccepted",
			"_negativeBottomChecks.cueRuntimeDependencyAccepted",
		]
		publicExports: [
			"pluginBundleRecommendationManifest",
			"pluginBundleRecommendationValidationPlan",
			"pluginBundleRecommendationCompletionReportContract",
		]
	}
}

_pluginBundleNegativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name:     "genericProviderTermAccepted"
			violates: "generic-terms-cannot-trigger-alone"
			refusal:  "require a phrase, path-aware match, word-boundary match, or required term group before selecting provider-catalogue routes"
			input: {
				prompt: "Update profile provider config"
				terms: ["provider"]
				substringOnlyMatch: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "danglingDependencyAccepted"
			violates: "emitted-routes-are-dependency-closed"
			refusal:  "expand selected routes recursively to include every dependsOn target before emitting a controller packet"
			input: {
				selectedRoutes: ["dotfiles.provider-catalogue.inspect", "dotfiles.plugin-bundle.plan"]
				missingRoutes: ["dotfiles.issue.inspect"]
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "cueRuntimeDependencyAccepted"
			violates: "runtime-dependencies-are-sh-and-jq-only"
			refusal:  "run cue export during generation or validation, then commit bundled JSON for hook runtime"
			input: {
				runtimeRequires: ["sh", "jq", "cue"]
				cueAtRuntime: true
			}
		}
	},
]

_pluginBundleBottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "genericProviderTermAccepted"
			fixture:      "negative.genericProviderTermAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/agent-context-resolver/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "danglingDependencyAccepted"
			fixture:      "negative.danglingDependencyAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/agent-context-resolver/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "cueRuntimeDependencyAccepted"
			fixture:      "negative.cueRuntimeDependencyAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/agent-context-resolver/checks"
		}
	},
]

_pluginBundleValidation: impl.#MakeValidationPlan & {
	in: {
		path:              "contracts/agent-context-resolver/plugin_bundle_recommendations.cue"
		validBaselineExpr: "pluginBundleRecommendationManifest"
		publicExpr:        "pluginBundleRecommendationValidationPlan"
		bottomChecks: [
			"genericProviderTermAccepted",
			"danglingDependencyAccepted",
			"cueRuntimeDependencyAccepted",
		]
		checkFile:        "./contracts/agent-context-resolver/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: "[s]ubstringOnlyMatchAccepted: true|[c]ueAtRuntimeAccepted: true|[g]eneratedAuthorityAccepted: true"
	}
}

_pluginBundleCompletion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for item in _pluginBundlePrimitives {item.out.name}]
		surfaces: [
			_pluginBundleObserved[0].out.name,
			_pluginBundleAdmissible[0].out.name,
			_pluginBundlePromotion[0].out.name,
		]
		fixtures: [for item in _pluginBundleNegativeFixtures {item.out.id}]
		checks: [for item in _pluginBundleBottomCheckPlans {item.out.name}]
		commands: _pluginBundleValidation.out.commands
		evidence: [
			"github issue template workflow at .github/dotfiles-manifest-slice/contracts/issues/_template/manifest.cue",
			"plugin-local constructor library under contracts/meta/impl",
			"review findings for substring matching and dangling route dependencies",
		]
	}
}

pluginBundleRecommendationManifest: {
	issue:    _pluginBundleRecommendationIssue
	workflow: _pluginBundleWorkflowIndex
	primitives: [for item in _pluginBundlePrimitives {item.out}]
	observed: [for item in _pluginBundleObserved {item.out}]
	admissible: [for item in _pluginBundleAdmissible {item.out}]
	predicates: [for item in _pluginBundlePredicates {item.out}]
	promotion: [for item in _pluginBundlePromotion {item.out}]
	surfaces: _pluginBundleSurfaces.out
	negativeFixtures: [for item in _pluginBundleNegativeFixtures {item.out}]
	bottomCheckPlans: [for item in _pluginBundleBottomCheckPlans {item.out}]
}

pluginBundleRecommendationValidationPlan: _pluginBundleValidation.out

pluginBundleRecommendationCompletionReportContract: _pluginBundleCompletion.out

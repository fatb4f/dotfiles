package codeintel

import (
	impl "github.com/fatb4f/factory/contracts/meta"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

// source: contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue
#CodeIntelBoundary: close({
	generatedAuthority?:              false
	mcpOutputIsAuthority?:            false
	lspDiagnosticsAreAuthority?:      false
	weztermTypesAreAuthority?:        false
	luaWorkflowGeneratedAsAuthority?: false
	resolverContractsLeak?:           false
})

codeIntelBoundary: #CodeIntelBoundary & {
	generatedAuthority:              false
	mcpOutputIsAuthority:            false
	lspDiagnosticsAreAuthority:      false
	weztermTypesAreAuthority:        false
	luaWorkflowGeneratedAsAuthority: false
	resolverContractsLeak:           false
}

_materializedBundleShape: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/plugin-bundle/code-intel/src/contracts/code-intel"
	contracts: {
		root: "contracts/plugin-bundle/code-intel/src/contracts/code-intel"
		cuePackages: [
			{id: "codeintel", path: "manifest.cue"},
			{id: "codeintelchecks", path: "checks/manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
			"checks/manifest.cue",
		]
	}
	generated: {
		root:         "contracts/plugin-bundle/generated/code-intel"
		evidenceOnly: true
		artifacts: [
			{path: "contracts/plugin-bundle/generated/code-intel/.codex-plugin/plugin.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/skills/SKILL.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/hooks/hooks.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/code-intel/scripts/README.md", required: true, evidenceOnly: true},
		]
	}
	contractProjection: {
		pluginName: "code-intel"
	}
	generatedProjection: {
		pluginName: "code-intel"
	}
	validation: {
		commands: [
			"cue vet ./contracts/plugin-bundle/code-intel/src/contracts/code-intel",
			"cue vet ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks",
			"cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e codeIntelBoundaryReport",
			"cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e codeIntelImplementationRecommendations",
		]
		negativeChecks: ["codeIntelShapeDrift"]
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "code-intel"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/src/manifest.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride:          false
	}
	bundleLocalShapeOverride: false
}

normalizedMaterializedBundleShapeManifest: _materializedBundleShape

materializedBundleShapeValidationPlan: close({
	path:     _materializedBundleShape.srcRoot
	positive: _materializedBundleShape.validation.commands
	negative: [
		"! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted",
	]
})

materializedBundleShapeCompletionReportContract: close({
	bundleID:      _materializedBundleShape.manifest.bundleID
	templateShape: _materializedBundleShape.manifest.srcRootShapeAuthority
	srcRoot:       _materializedBundleShape.srcRoot
	sourceRoot:    _materializedBundleShape.srcRoot
	validation:    materializedBundleShapeValidationPlan
	finalResult:   "code-intel internal contract conforms to the template-defined src-root shape"
})

_negativeBottomChecks: {
	generatedAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "generatedAsAuthority"
			input: {
				evidence: "generated code-intel artifacts are inadmissible as authority"
				value: {
					generatedAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects generated authority"
					value:    #CodeIntelBoundary
				}
			}
		}
	}).out.generatedAsAuthority
	mcpOutputAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "mcpOutputAsAuthority"
			input: {
				evidence: "MCP output is inadmissible as authority"
				value: {
					mcpOutputIsAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects MCP authority"
					value:    #CodeIntelBoundary
				}
			}
		}
	}).out.mcpOutputAsAuthority
	lspDiagnosticsAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "lspDiagnosticsAsAuthority"
			input: {
				evidence: "LSP diagnostics are inadmissible as authority"
				value: {
					lspDiagnosticsAreAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects LSP diagnostics authority"
					value:    #CodeIntelBoundary
				}
			}
		}
	}).out.lspDiagnosticsAsAuthority
	weztermTypesAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "weztermTypesAsAuthority"
			input: {
				evidence: "WezTerm types are inadmissible as authority"
				value: {
					weztermTypesAreAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects WezTerm type authority"
					value:    #CodeIntelBoundary
				}
			}
		}
	}).out.weztermTypesAsAuthority
	luaWorkflowGeneratedAsAuthority!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "luaWorkflowGeneratedAsAuthority"
			input: {
				evidence: "generated Lua workflow artifacts are inadmissible as authority"
				value: {
					luaWorkflowGeneratedAsAuthority: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects generated Lua workflow authority"
					value:    #CodeIntelBoundary
				}
			}
		}
	}).out.luaWorkflowGeneratedAsAuthority
	resolverContractsLeak!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "resolverContractsLeak"
			input: {
				evidence: "resolver contracts are inadmissible as code-intel authority"
				value: {
					resolverContractsLeak: true
				}
			}
			target: {
				name: "#CodeIntelBoundary"
				contract: {
					evidence: "code-intel boundary rejects resolver contract leakage"
					value:    #CodeIntelBoundary
				}
			}
		}
	}).out.resolverContractsLeak
}

codeIntelBoundaryReport: {
	schema:    "factory.plugin-bundle.code-intel.boundary-report.v1"
	status:    "admitted"
	authority: codeIntelBoundary
	checks: [
		"generatedAsAuthority",
		"mcpOutputAsAuthority",
		"lspDiagnosticsAsAuthority",
		"weztermTypesAsAuthority",
		"luaWorkflowGeneratedAsAuthority",
		"resolverContractsLeak",
	]
}

// source: contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue
#NonEmptyString: string & !=""
#ContainedPath:  string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

#Provider: close({
	id:   #NonEmptyString
	kind: "mcp" | "lsp" | "types" | "workflow"
	paths: [...#ContainedPath] & [_, ...]
	authority:    false
	evidenceOnly: true
})

#LuaEntrypoint: close({
	id:       #NonEmptyString
	language: "lua"
	path:     #ContainedPath
	domain:   "nvim" | "wezterm" | "dotfiles"
	provider: "lua-language-server"
	typeOverlays: [...#NonEmptyString]
	authority: "dotfiles-source"
})

#LuaFirstStep: close({
	order:     int & >0
	id:        #NonEmptyString
	goal:      #NonEmptyString
	authority: "dotfiles-source" | "evidence-only"
})

#CodeIntelLuaFirstWorkflow: close({
	schema: "factory.plugin-bundle.code-intel.lua-first-workflow.v1"
	id:     #NonEmptyString
	intent: #NonEmptyString
	entrypoints: [...#LuaEntrypoint] & [_, ...]
	providers: [...#Provider] & [_, ...]
	steps: [...#LuaFirstStep] & [_, ...]
	authority: close({
		owns: [...#NonEmptyString] & [_, ...]
		doesNotOwn: [...#NonEmptyString] & [_, ...]
	})
})

codeIntelLuaFirstWorkflow: #CodeIntelLuaFirstWorkflow & {
	id:     "dotfiles-code-intel-lua-first"
	intent: "Resolve dotfiles Lua surfaces before generic repository context."
	entrypoints: [
		{id: "nvim-init", language: "lua", path: ".config/nvim/init.lua", domain: "nvim", provider: "lua-language-server", typeOverlays: ["nvim-vim-types"], authority: "dotfiles-source"},
		{id: "nvim-lua-modules", language: "lua", path: ".config/nvim/lua", domain: "nvim", provider: "lua-language-server", typeOverlays: ["nvim-vim-types"], authority: "dotfiles-source"},
		{id: "wezterm-config", language: "lua", path: ".config/wezterm/wezterm.lua", domain: "wezterm", provider: "lua-language-server", typeOverlays: ["wezterm-types"], authority: "dotfiles-source"},
	]
	providers: [
		{id: "mcp-tool-registry", kind: "mcp", paths: ["generated/mcp/tool-registry.json"], authority: false, evidenceOnly: true},
		{id: "mcp-context-projection", kind: "mcp", paths: ["generated/mcp/context-projection.json"], authority: false, evidenceOnly: true},
		{id: "cue-lsp", kind: "lsp", paths: ["generated/lsp/cue-lsp.json"], authority: false, evidenceOnly: true},
		{id: "lua-language-server", kind: "lsp", paths: ["generated/lsp/lua-language-server.json", "generated/lsp/provider-routing.json"], authority: false, evidenceOnly: true},
		{id: "wezterm-types", kind: "types", paths: ["generated/types/wezterm/wezterm.lua", "generated/types/wezterm/events.lua", "generated/types/wezterm/config-builder.lua"], authority: false, evidenceOnly: true},
		{id: "nvim-vim-types", kind: "types", paths: ["generated/types/nvim/vim.lua"], authority: false, evidenceOnly: true},
	]
	steps: [
		{order: 1, id: "collect-lua-entrypoints", goal: "Resolve Lua entrypoints before generic dotfiles paths.", authority: "dotfiles-source"},
		{order: 2, id: "load-type-overlays", goal: "Attach Neovim and WezTerm type overlays as read-only evidence.", authority: "evidence-only"},
		{order: 3, id: "route-provider", goal: "Select lua-language-server or cue-lsp by path and language.", authority: "evidence-only"},
		{order: 4, id: "project-diagnostics", goal: "Project diagnostics as evidence, not mutation authority.", authority: "evidence-only"},
	]
	authority: {
		owns: ["code-intel bundle workflow shape", "provider ordering for Lua-first dotfiles work"]
		doesNotOwn: ["fatb4f/dotfiles source authority", "runtime execution", "truth of LSP diagnostics", "WezTerm runtime behavior", "Neovim runtime behavior"]
	}
}

// source: contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue
#RecommendationTargetPath: #ContainedPath

#CodeIntelRecommendation: close({
	id:       #NonEmptyString
	priority: "high" | "medium" | "low"
	targets: [...#RecommendationTargetPath] & [_, ...]
	observed:       #NonEmptyString
	recommendation: #NonEmptyString
	validation: [...#NonEmptyString] & [_, ...]
})

#CodeIntelRecommendationManifest: close({
	schema:         "factory.plugin-bundle.code-intel.recommendations.v1"
	sourceTemplate: #ContainedPath
	targetRoot:     #ContainedPath
	workflow: [...close({
		order:         int & >0
		id:            #NonEmptyString
		instantiateAt: #NonEmptyString
	})] & [_, ...]
	primitives: [...#NonEmptyString] & [_, ...]
	observedSurfaces: [...close({
		id: #NonEmptyString
		paths: [...#RecommendationTargetPath] & [_, ...]
		evidence: #NonEmptyString
	})] & [_, ...]
	predicates: [...close({
		id:   #NonEmptyString
		rule: #NonEmptyString
	})] & [_, ...]
	recommendations: [...#CodeIntelRecommendation] & [_, ...]
	nonGoals: [...#NonEmptyString] & [_, ...]
})

codeIntelImplementationRecommendations: #CodeIntelRecommendationManifest & {
	schema:         "factory.plugin-bundle.code-intel.recommendations.v1"
	sourceTemplate: "contracts/meta/scripts/scaffold-contract-slice"
	targetRoot:     "contracts/plugin-bundle/code-intel/src"
	workflow: [
		{order: 1, id: "#MakeDotfilesPrimitive", instantiateAt: "primitives"},
		{order: 2, id: "#MakeObservedSurface", instantiateAt: "observedSurfaces"},
		{order: 3, id: "#MakePredicateSet", instantiateAt: "predicates"},
		{order: 4, id: "#MakePromotionCandidate", instantiateAt: "recommendations"},
		{order: 5, id: "#MakeValidationPlan", instantiateAt: "recommendations.validation"},
	]
	primitives: [
		"generated runtime artifacts remain evidence-only under the source contract surfaces",
		"installable generated bundle roots must keep the template projection shape",
		"source validation paths must target the nested code-intel package that owns the materialized bundle shape",
	]
	observedSurfaces: [
		{
			id: "resolved-lua-first-workflow-contract-drift"
			paths: [
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
				"generated/workflows/lua-first/workflow.json",
				"generated/workflows/lua-first/entrypoints.json",
			]
			evidence: "workflow JSON now uses the CUE-owned entrypoints, providers, steps, and structured authority shape"
		},
		{
			id: "resolved-negative-bottom-checks-proving"
			paths: [
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks/manifest.cue",
			]
			evidence: "negative boundary checks are exported through concrete bottom-proof constructors and validation commands"
		},
		{
			id: "resolved-wezterm-overlay-routing"
			paths: [
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
				"generated/workflows/lua-first/workflow.json",
				"generated/lsp/lua-language-server.json",
				"generated/types/wezterm/wezterm.lua",
				"generated/types/wezterm/events.lua",
				"generated/types/wezterm/config-builder.lua",
			]
			evidence: "WezTerm provider and LSP surfaces list the complete overlay set"
		},
		{
			id: "generated-root-parity-restored"
			paths: [
				"contracts/plugin-bundle/code-intel/src/manifest.cue",
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
				"justfile",
			]
			evidence: "installable generated payload inventory is limited to the scaffold projection shared with agent-context-resolver"
		},
	]
	predicates: [
		{id: "generated-root-parity-validates", rule: "code-intel generated root must not contain contracts, generated runtime evidence, or manifest.json"},
		{id: "generated-payload-inventory-complete", rule: "plugin-bundle source shape must list the scaffold installable payload as evidence-only generated artifacts"},
		{id: "source-validation-targets-owner-package", rule: "materialized bundle shape exports must be read from the nested code-intel source package"},
	]
	recommendations: [
		{
			id:       "preserve-generated-root-parity"
			priority: "medium"
			targets: [
				"contracts/plugin-bundle/code-intel/src/manifest.cue",
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
				"justfile",
			]
			observed:       "the code-intel generated root now has the same scaffold projection directories as agent-context-resolver."
			recommendation: "Keep generated-root validation focused on .codex-plugin, skills, hooks, and scripts; do not reintroduce installable-root contracts, generated, or manifest.json payloads."
			validation: [
				"test ! -e contracts/plugin-bundle/generated/code-intel/manifest.json",
				"test ! -e contracts/plugin-bundle/generated/code-intel/contracts",
				"test ! -e contracts/plugin-bundle/generated/code-intel/generated",
			]
		},
		{
			id:       "preserve-generated-payload-inventory"
			priority: "medium"
			targets: [
				"contracts/plugin-bundle/code-intel/src/manifest.cue",
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
			]
			observed:       "the installable code-intel payload includes only the scaffold projection files."
			recommendation: "List only the scaffold projection files in the generated artifact inventory."
			validation: [
				"cue export ./contracts/plugin-bundle/code-intel/src -e pluginBundleContract",
				"cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e normalizedMaterializedBundleShapeManifest",
			]
		},
		{
			id:       "preserve-resolved-workflow-and-bottom-check-gates"
			priority: "medium"
			targets: [
				"SKILL.md",
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue",
				"contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks/manifest.cue",
			]
			observed:       "previous workflow-schema and bottom-check drift has been resolved under the scaffold-aligned source root."
			recommendation: "Keep validation commands pointed at contracts/plugin-bundle/code-intel/src/contracts/code-intel and its checks package."
			validation: [
				"cue vet ./contracts/plugin-bundle/code-intel/src/contracts/code-intel",
				"cue vet ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks",
				"! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.generatedAsAuthority",
			]
		},
	]
	nonGoals: [
		"promote generated code-intel outputs to source authority",
		"merge code-intel with the agent-context-resolver bundle",
		"change dotfiles source behavior from this bundle",
		"treat LSP diagnostics as mutation authority",
	]
}

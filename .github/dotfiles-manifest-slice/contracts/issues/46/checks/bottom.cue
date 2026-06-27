package checks

import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

#LaunchSessionResolution: {
	cwdDetected:         bool | *false
	configuredWorkspace: bool | *false
	runtimeCached:       bool | *false
	result:              "cwd-detected" | "configured-workspace" | "unconfigured-error"

	if cwdDetected {
		result: "cwd-detected"
	}

	if !cwdDetected {
		if configuredWorkspace {
			result: "configured-workspace"
		}
		if !configuredWorkspace {
			runtimeCached: false
			result:        "unconfigured-error"
		}
	}
}

#RuntimeCacheSeedGate: {
	configuredResolved: bool | *false
	validationPassed:   bool | *false
	seedRuntimeCache:   bool | *false

	if seedRuntimeCache {
		configuredResolved: true
		validationPassed:   true
	}
}

_negativeBottomChecks: {
	"runtime-cache-authority-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "runtime-cache-authority-rejected"
			input: {
				evidence: "runtime cache must not make an unconfigured workspace launchable"
				value: {
					cwdDetected:         false
					configuredWorkspace: false
					runtimeCached:       true
					result:              "configured-workspace"
				}
			}
			target: {
				name: "#LaunchSessionResolution"
				contract: {
					evidence: "unconfigured active workspaces must keep the explicit IDE launch error"
					value: #LaunchSessionResolution & {
						cwdDetected:         false
						configuredWorkspace: false
						runtimeCached:       true
						result:              "configured-workspace"
					}
				}
			}
		}
	}
	"workspace-overrides-cwd-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "workspace-overrides-cwd-rejected"
			input: {
				evidence: "cwd-detected project sessions must take precedence"
				value: {
					cwdDetected:         true
					configuredWorkspace: true
					result:              "configured-workspace"
				}
			}
			target: {
				name: "#LaunchSessionResolution"
				contract: {
					evidence: "configured active workspace lookup cannot override cwd-detected project precedence"
					value: #LaunchSessionResolution & {
						cwdDetected:         true
						configuredWorkspace: true
						result:              "configured-workspace"
					}
				}
			}
		}
	}
	"prevalidation-cache-seed-rejected": impl.#MakeBottomCheckProof & {
		in: {
			name: "prevalidation-cache-seed-rejected"
			input: {
				evidence: "runtime cache seeding requires a validated configured session"
				value: {
					configuredResolved: true
					validationPassed:   false
					seedRuntimeCache:   true
				}
			}
			target: {
				name: "#RuntimeCacheSeedGate"
				contract: {
					evidence: "runtime session cache is written only after configured session validation succeeds"
					value: #RuntimeCacheSeedGate & {
						configuredResolved: true
						validationPassed:   false
						seedRuntimeCache:   true
					}
				}
			}
		}
	}
}
